import {
  Injectable,
  InternalServerErrorException,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, In, Repository } from 'typeorm';
import { QuestionAttemptDto, QuizAttemptDto, QuizSetupDto } from './quiz.dto';
import { Quiz } from './entitites/quiz.entity';
import { QuizQuestion } from './entitites/quiz-question.entity';
import { DocumentService } from '../document/document.service';
import { DocumentExtractionService } from '../document-processing/document-extraction.service';
import { ChatPromptTemplate } from '@langchain/core/prompts';
import { PromptTemplates } from '../langchain/prompt.templates';
import { LangchainService } from '../langchain/langchain.service';
import { DocumentRetriever } from '../document-processing/document.retriever';
import { VectorStoreService } from '../document-processing/vector-store.service';
import { getBloomLevel, getLevelInstructions } from './enums/bloom-taxonomy.enum';
import { QuizType } from './enums/quiz-type.enum';
import { QuizOption } from './entitites/quiz-option.entity';
import { QuestionAttempt } from './entitites/question-attempt.entity';
import { QuizAttempt } from './entitites/quiz-attempt.entity';
import { CommaSeparatedListOutputParser } from '@langchain/core/output_parsers';
import { BooleanOutputParser } from '../common/boolean.parser';

@Injectable()
export class QuizService {
  private readonly logger = new Logger(QuizService.name);

  constructor(
    @InjectRepository(Quiz)
    private readonly quizRepository: Repository<Quiz>,
    @InjectRepository(QuizQuestion)
    private readonly questionRepository: Repository<QuizQuestion>,
    @InjectRepository(QuizOption)
    private readonly optionRepository: Repository<QuizOption>,
    @InjectRepository(QuestionAttempt)
    private readonly questionAttemptRepository: Repository<QuestionAttempt>,
    @InjectRepository(QuizAttempt)
    private readonly quizAttemptRepository: Repository<QuizAttempt>,
    private readonly documentExtractor: DocumentExtractionService,
    private readonly documentService: DocumentService,
    private readonly langchainService: LangchainService,
    private readonly dataSource: DataSource,
    private readonly vectorStore: VectorStoreService,
  ) {
    // VectorStoreService implements OnModuleInit and is initialised
    // automatically by Nest — no manual bootstrap required here.
  }

  async getQuizzes(userId: number, ids?: number[]) {
    const where: any = { user: { id: userId } };
    if (ids && ids.length > 0) where.id = In(ids);
    try {
      return await this.quizRepository.find({
        where,
        relations: ['questions', 'documents', 'questions.options'],
        order: { createdAt: 'DESC', questions: { id: 'ASC' } },
      });
    } catch (err: any) {
      this.logger.error(
        `getQuizzes failed: ${err?.message ?? err}`,
        err?.stack,
      );
      throw new InternalServerErrorException('Failed to fetch quizzes');
    }
  }

  // userId is optional: internal callers omit it; HTTP callers pass it so a
  // user can only ever touch their own quizzes.
  async findOne(id: number, userId?: number) {
    const where: any = { id };
    if (userId != null) where.user = { id: userId };
    const quiz = await this.quizRepository.findOne({
      where,
      relations: ['documents', 'questions', 'questions.options'],
      order: { questions: { id: 'ASC' } },
    });
    if (!quiz) {
      throw new NotFoundException(`Quiz with id ${id} not found`);
    }
    return quiz;
  }

  async findOneQuestion(id: number) {
    const question = await this.questionRepository.findOne({ where: { id } });
    if (!question) {
      throw new NotFoundException(`Question with id ${id} not found`);
    }
    return question;
  }

  async generateTitle(quiz: Quiz, history?: QuizAttempt) {
    try {
      let allTopics: string;
      allTopics = quiz.documents.flatMap((doc) => doc.topics ?? []).join(', ');
      if (history) {
        allTopics = (history.weakTopics ?? []).join(',');
      }
      return await this.documentExtractor.extractTitle(allTopics);
    } catch (err: any) {
      this.logger.error(
        `Failed to extract title for quiz ${quiz.id}: ${err?.message ?? err}`,
        err?.stack,
      );
      // Fall back to a non-fatal title rather than abort the whole flow.
      return quiz.title ?? `Quiz ${quiz.id}`;
    }
  }

  async generateQuiz(quizId: number, userId: number, history?: QuizAttempt) {
    const quiz = await this.findOne(quizId, userId);

    quiz.isAdaptive = history != null;
    if (history) quiz.difficulty = 1;

    quiz.title = await this.generateTitle(quiz, history);
    quiz.questions = await this.generateQuestions(quiz, history);

    await this.updateQuiz(quizId, quiz);

    // Generate answers for each question. We swallow individual answer-gen
    // failures so a single bad question doesn't kill the whole quiz, but log
    // them loudly.
    for (const question of quiz.questions) {
      try {
        await this.generateAnswer(question, quiz.type);
      } catch (err: any) {
        this.logger.warn(
          `Answer generation failed for question ${question.id}: ${err?.message ?? err}`,
        );
      }
    }

    return quiz;
  }

  async updateQuiz(id: number, updateData: Partial<Quiz>) {
    try {
      await this.quizRepository.save(updateData);
    } catch (err: any) {
      this.logger.error(
        `updateQuiz(${id}) failed: ${err?.message ?? err}`,
        err?.stack,
      );
      throw new InternalServerErrorException('Failed to update quiz');
    }
    return await this.findOne(id);
  }

  async updateQuestion(id: number, updateData: Partial<QuizQuestion>) {
    await this.questionRepository.save(updateData);
    return await this.findOneQuestion(id);
  }

  async evaluateAnswers(
    quizAttempt: QuizAttempt,
    answers: Array<QuestionAttemptDto>,
  ) {
    const incorrectQuestions: string[] = [];

    const savedAttempts = await Promise.all(
      answers.map(async (answer) => {
        const question = await this.findOneQuestion(answer.questionId);

        let isCorrect: boolean = false;
        if (typeof answer.correct !== 'boolean') {
          const booleanParser = new BooleanOutputParser();
          const template = ChatPromptTemplate.fromTemplate(
            PromptTemplates.evaluateAnswer,
          );
          try {
            isCorrect = await this.langchainService.run<boolean>({
              template,
              input: {
                question: question.question,
                answer: question.answer,
                attempt: answer.value,
              },
              parser: booleanParser,
            });
          } catch (err: any) {
            // If the LLM/parser fails, default to incorrect rather than
            // crashing the whole evaluation.
            this.logger.warn(
              `LLM evaluation failed for question ${question.id}, defaulting to incorrect: ${err?.message ?? err}`,
            );
            isCorrect = false;
          }
        }

        const finalCorrect = answer.correct ?? isCorrect;
        if (!finalCorrect) incorrectQuestions.push(question.question);

        return this.questionAttemptRepository.create({
          question: { id: question.id },
          history: { id: quizAttempt.id },
          value: answer.value,
          correct: finalCorrect,
        });
      }),
    );

    try {
      quizAttempt.attempts = await this.questionAttemptRepository.save(savedAttempts);
    } catch (err: any) {
      this.logger.error(
        `Failed to persist question attempts: ${err?.message ?? err}`,
        err?.stack,
      );
      throw new InternalServerErrorException('Failed to save attempts');
    }

    let weakTopics: string[] = [];
    const correctCount = answers.length - incorrectQuestions.length;
    quizAttempt.accuracy = (correctCount / answers.length) * 100;

    if (incorrectQuestions.length > 0) {
      try {
        const template = ChatPromptTemplate.fromTemplate(
          PromptTemplates.extractWeakTopics,
        );
        const commaSeparatedParser = new CommaSeparatedListOutputParser();
        const failedQuestions = incorrectQuestions.join(', ');
        const questionContext = await this.vectorStore.similaritySearch(
          failedQuestions,
          5,
        );
        weakTopics = await this.langchainService.run<string[]>({
          template,
          input: {
            questions: failedQuestions,
            context: questionContext.map((doc) => doc.pageContent).join('\n\n'),
          },
          parser: commaSeparatedParser,
        });
      } catch (err: any) {
        this.logger.warn(
          `Weak-topic extraction failed: ${err?.message ?? err}`,
        );
        weakTopics = [];
      }
    }

    return weakTopics;
  }

  async evaluateAttempt(attempt: QuizAttemptDto, userId: number) {
    const quiz = await this.quizRepository.findOne({
      where: { id: attempt.quizId, user: { id: userId } },
    });
    if (!quiz) {
      throw new NotFoundException(`Quiz with id ${attempt.quizId} not found`);
    }

    const quizAttempt = this.quizAttemptRepository.create({
      quiz,
      difficulty: attempt.difficulty,
      timeTaken: attempt.timeTaken,
    });

    // Persist first so the row gets an id. evaluateAnswers links each
    // QuestionAttempt to this attempt via its id — without a saved id TypeORM
    // throws UpdateValuesMissingError when saving the child attempts.
    await this.quizAttemptRepository.save(quizAttempt);

    quizAttempt.weakTopics = await this.evaluateAnswers(
      quizAttempt,
      attempt.attempts,
    );

    try {
      const analysisPrompt = ChatPromptTemplate.fromTemplate(
        PromptTemplates.generateAnalysis,
      );
      quizAttempt.analysis = await this.langchainService.run<string>({
        template: analysisPrompt,
        input: {
          topics: (quizAttempt.weakTopics ?? []).join(', '),
          difficulty: attempt.difficulty,
          accuracy: quizAttempt.accuracy,
        },
      });
    } catch (err: any) {
      this.logger.warn(
        `Analysis generation failed: ${err?.message ?? err}`,
      );
      quizAttempt.analysis = '';
    }

    return await this.quizAttemptRepository.save(quizAttempt);
  }

  async generateAnswer(question: QuizQuestion, quizType: QuizType) {
    const relevantChunks = await this.vectorStore.similaritySearch(
      question.question,
      5,
    );

    const seen = new Set<string>();
    const uniqueChunks = relevantChunks.filter((doc) => {
      const text = doc.pageContent.trim();
      if (seen.has(text)) return false;
      seen.add(text);
      return true;
    });

    const context = uniqueChunks.map((doc) => doc.pageContent).join('\n\n');
    const answerTemplate = ChatPromptTemplate.fromTemplate(
      PromptTemplates.generateAnswer,
    );

    const answer = await this.langchainService.run<string>({
      template: answerTemplate,
      input: { question: question.question, context },
    });

    if (quizType !== QuizType.MCQ) {
      question.answer = answer;
    } else {
      const distractorTemplate = ChatPromptTemplate.fromTemplate(
        PromptTemplates.generateDistractors,
      );
      const answerOption = this.optionRepository.create({
        value: answer,
        question,
        isAnswer: true,
      });

      let distractors: string[] = [];
      try {
        const response = await this.langchainService.run<string>({
          template: distractorTemplate,
          input: { question: question.question, answer, context },
        });
        distractors = response
          .split(/\n?\d+\.\s*/)
          .map((d) => d.trim())
          .filter((d) => d.length > 0);
      } catch (err: any) {
        this.logger.warn(
          `Distractor generation failed for question ${question.id}: ${err?.message ?? err}`,
        );
      }

      // Always store the correct option even if distractors fail.
      const options = distractors.map((value) =>
        this.optionRepository.create({
          value,
          question,
          isAnswer: false,
        }),
      );
      options.push(answerOption);
      // Persist the correct answer as the canonical .answer field too.
      question.answer = answer;

      await this.optionRepository.save(options);
      question.options = options;
    }

    return this.updateQuestion(question.id, question);
  }

  async generateQuestions(quiz: Quiz, history?: QuizAttempt) {
    let context: string;

    if (history) {
      const contexts = await Promise.all(
        (history.weakTopics ?? []).map(async (topic) => {
          const relevantChunks = await this.vectorStore.similaritySearch(
            topic,
            5,
          );
          const seen = new Set<string>();
          const uniqueChunks = relevantChunks.filter((doc) => {
            const text = doc.pageContent.trim();
            if (seen.has(text)) return false;
            seen.add(text);
            return true;
          });
          return uniqueChunks.map((doc) => doc.pageContent).join('\n\n');
        }),
      );
      context = contexts.join('\n\n---\n\n');
    } else {
      const contexts = await Promise.all(
        quiz.documents.map(async (document) => {
          const retriever = new DocumentRetriever(this.dataSource, document.id);
          const docs = await retriever.retrieveRelevantDocuments();
          return docs.map((doc) => doc.pageContent).join('\n\n');
        }),
      );
      context = contexts.join('\n\n---\n\n');
    }

    const template = ChatPromptTemplate.fromTemplate(
      PromptTemplates.generateQuestions,
    );

    const response = await this.langchainService.run<string>({
      template,
      input: {
        context,
        questions: quiz.noOfQuestions,
        level: getBloomLevel(quiz.difficulty),
        structure: getLevelInstructions(quiz.difficulty),
        type: quiz.type,
      },
    });

    // Primary: numbered format "1. Question" as instructed in the prompt.
    // Fallback: plain double-newline separation in case the LLM ignores numbering.
    let questionList = response
      .split(/\n?\d+\.\s+/)
      .map((d) => d.trim())
      .filter((d) => d.length > 0);

    if (questionList.length <= 1) {
      questionList = response
        .split(/\n{2,}/)
        .map((d) => d.trim())
        .filter((d) => d.length > 0);
    }

    if (questionList.length === 0) {
      this.logger.error(
        `LLM returned no parseable questions for quiz ${quiz.id}: ${response.slice(0, 200)}`,
      );
      throw new InternalServerErrorException(
        'Question generation produced no output. Try again or check the LLM backend.',
      );
    }

    const questions = questionList.map((q: string) =>
      this.questionRepository.create({
        type: quiz.type,
        question: q,
        quiz,
      }),
    );

    return this.questionRepository.save(questions);
  }

  async createQuiz(quizSetup: QuizSetupDto, userId: number) {
    // Only the user's own documents are eligible as quiz sources.
    const documents = await this.documentService.getAllDocuments(
      userId,
      quizSetup.documentIds,
    );
    if (!documents || documents.length === 0) {
      throw new NotFoundException('No documents found for the provided ids');
    }

    const quiz = this.quizRepository.create({
      difficulty: quizSetup.difficulty,
      duration: quizSetup.duration,
      type: quizSetup.type,
      noOfQuestions: quizSetup.questions,
      documents,
      user: { id: userId },
    });
    await this.quizRepository.save(quiz);

    return this.findOne(quiz.id, userId);
  }
}
