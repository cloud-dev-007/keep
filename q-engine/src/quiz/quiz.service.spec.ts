import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { QuizService } from './quiz.service';
import { Quiz } from './entitites/quiz.entity';
import { QuizQuestion } from './entitites/quiz-question.entity';
import { QuizOption } from './entitites/quiz-option.entity';
import { QuizAttempt } from './entitites/quiz-attempt.entity';
import { QuestionAttempt } from './entitites/question-attempt.entity';
import { DocumentService } from '../document/document.service';
import { DocumentExtractionService } from '../document-processing/document-extraction.service';
import { LangchainService } from '../langchain/langchain.service';
import { VectorStoreService } from '../document-processing/vector-store.service';
import { QuizType } from './enums/quiz-type.enum';

/** A repository mock factory that mimics what TypeORM gives us. */
function repoMock<T extends object>() {
  return {
    find: jest.fn(),
    findOne: jest.fn(),
    create: jest.fn((data: Partial<T>) => data as T),
    save: jest.fn(async (data: any) => (Array.isArray(data) ? data : { id: 1, ...data })),
    update: jest.fn(),
    remove: jest.fn(),
  };
}

describe('QuizService', () => {
  let service: QuizService;
  let quizRepo: ReturnType<typeof repoMock<Quiz>>;
  let questionRepo: ReturnType<typeof repoMock<QuizQuestion>>;
  let optionRepo: ReturnType<typeof repoMock<QuizOption>>;
  let attemptRepo: ReturnType<typeof repoMock<QuizAttempt>>;
  let qAttemptRepo: ReturnType<typeof repoMock<QuestionAttempt>>;
  let langchain: { run: jest.Mock };
  let vectorStore: { similaritySearch: jest.Mock; onModuleInit: jest.Mock };
  let documentService: { getAllDocuments: jest.Mock };
  let documentExtractor: { extractTitle: jest.Mock };

  beforeEach(async () => {
    quizRepo = repoMock<Quiz>();
    questionRepo = repoMock<QuizQuestion>();
    optionRepo = repoMock<QuizOption>();
    attemptRepo = repoMock<QuizAttempt>();
    qAttemptRepo = repoMock<QuestionAttempt>();
    langchain = { run: jest.fn() };
    vectorStore = {
      similaritySearch: jest.fn().mockResolvedValue([]),
      onModuleInit: jest.fn().mockResolvedValue(undefined),
    };
    documentService = {
      getAllDocuments: jest.fn().mockResolvedValue([{ id: 1, topics: ['t'] }]),
    };
    documentExtractor = {
      extractTitle: jest.fn().mockResolvedValue('Generated Title'),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        QuizService,
        { provide: getRepositoryToken(Quiz), useValue: quizRepo },
        { provide: getRepositoryToken(QuizQuestion), useValue: questionRepo },
        { provide: getRepositoryToken(QuizOption), useValue: optionRepo },
        { provide: getRepositoryToken(QuizAttempt), useValue: attemptRepo },
        { provide: getRepositoryToken(QuestionAttempt), useValue: qAttemptRepo },
        { provide: DocumentService, useValue: documentService },
        { provide: DocumentExtractionService, useValue: documentExtractor },
        { provide: LangchainService, useValue: langchain },
        { provide: VectorStoreService, useValue: vectorStore },
        { provide: DataSource, useValue: { query: jest.fn().mockResolvedValue([]) } },
      ],
    }).compile();

    service = module.get<QuizService>(QuizService);
  });

  describe('createQuiz', () => {
    it('persists a quiz from a setup DTO and returns the new id', async () => {
      quizRepo.save.mockResolvedValueOnce({ id: 42 });
      // Mutate the value created by repo.create so save sees it; the mock
      // factory just returns the data, so we can grab the id from save.
      quizRepo.create.mockReturnValueOnce({ id: 42 } as any);

      const id = await service.createQuiz({
        documentIds: [1],
        questions: 5,
        difficulty: 3,
        type: QuizType.MCQ,
      } as any);

      expect(documentService.getAllDocuments).toHaveBeenCalledWith([1]);
      expect(quizRepo.save).toHaveBeenCalled();
      expect(id).toBe(42);
    });

    it('throws NotFoundException when no documents resolve', async () => {
      documentService.getAllDocuments.mockResolvedValueOnce([]);
      await expect(
        service.createQuiz({
          documentIds: [999],
          questions: 5,
          difficulty: 3,
          type: QuizType.MCQ,
        } as any),
      ).rejects.toBeInstanceOf(NotFoundException);
    });
  });

  describe('findOne', () => {
    it('throws NotFoundException for unknown ids', async () => {
      quizRepo.findOne.mockResolvedValueOnce(null);
      await expect(service.findOne(123)).rejects.toBeInstanceOf(NotFoundException);
    });
  });

  describe('generateQuestions', () => {
    it('parses a numbered LLM response into question rows', async () => {
      const fakeQuiz = {
        id: 1,
        difficulty: 3,
        noOfQuestions: 3,
        type: QuizType.MCQ,
        documents: [{ id: 1 }],
      } as any;

      // Stub the retriever path: we set up the DataSource to return rows.
      // The DocumentRetriever falls back to dataSource.query() — already mocked to [].

      langchain.run.mockResolvedValueOnce(
        '1. What is X?\n2. Define Y.\n3. Explain Z.',
      );
      questionRepo.save.mockImplementationOnce(async (rows: any[]) =>
        rows.map((r, i) => ({ id: i + 1, ...r })),
      );

      const result = await service.generateQuestions(fakeQuiz);
      expect(result).toHaveLength(3);
      expect(result[0].question).toBe('What is X?');
      expect(result[2].question).toBe('Explain Z.');
    });

    it('errors if the LLM returns no parseable questions', async () => {
      langchain.run.mockResolvedValueOnce('   '); // whitespace only
      const fakeQuiz = {
        id: 1,
        difficulty: 3,
        noOfQuestions: 3,
        type: QuizType.MCQ,
        documents: [{ id: 1 }],
      } as any;

      await expect(service.generateQuestions(fakeQuiz)).rejects.toThrow(
        /Question generation produced no output/,
      );
    });
  });

  describe('generateAnswer', () => {
    it('writes a free-text answer for non-MCQ quizzes', async () => {
      const question: any = { id: 1, question: 'What is X?', options: [] };
      langchain.run.mockResolvedValueOnce('X is a thing.');
      questionRepo.findOne.mockResolvedValueOnce(question);
      questionRepo.save.mockResolvedValueOnce(question);

      await service.generateAnswer(question, QuizType.Theory);

      expect(question.answer).toBe('X is a thing.');
      expect(optionRepo.save).not.toHaveBeenCalled();
    });

    it('creates 1 correct option + N distractors for MCQ', async () => {
      const question: any = { id: 1, question: 'What is X?' };
      questionRepo.findOne.mockResolvedValueOnce(question);
      questionRepo.save.mockResolvedValueOnce(question);

      // First call: answer. Second call: distractors.
      langchain.run
        .mockResolvedValueOnce('X is a foo.')
        .mockResolvedValueOnce('1. X is a bar.\n2. X is a baz.\n3. X is a qux.');

      await service.generateAnswer(question, QuizType.MCQ);

      // optionRepo.create called 4 times (3 distractors) + 1 correct.
      expect(optionRepo.create).toHaveBeenCalledTimes(4);
      const saved = (optionRepo.save as jest.Mock).mock.calls[0][0];
      expect(saved).toHaveLength(4);
      expect(saved.filter((o: any) => o.isAnswer)).toHaveLength(1);
    });

    it('still saves the correct option even if distractor LLM call fails', async () => {
      const question: any = { id: 1, question: 'What is X?' };
      questionRepo.findOne.mockResolvedValueOnce(question);
      questionRepo.save.mockResolvedValueOnce(question);

      langchain.run
        .mockResolvedValueOnce('X is a foo.') // answer
        .mockRejectedValueOnce(new Error('LLM down')); // distractors

      await service.generateAnswer(question, QuizType.MCQ);

      const saved = (optionRepo.save as jest.Mock).mock.calls[0][0];
      expect(saved).toHaveLength(1);
      expect(saved[0].isAnswer).toBe(true);
    });
  });

  describe('evaluateAttempt', () => {
    it('throws NotFoundException when the quiz id does not exist', async () => {
      quizRepo.findOne.mockResolvedValueOnce(null);
      await expect(
        service.evaluateAttempt({
          quizId: 99,
          attempts: [{ questionId: 1, value: 'x' }],
          difficulty: 3,
        } as any),
      ).rejects.toBeInstanceOf(NotFoundException);
    });

    it('uses the supplied `correct` flag without calling the LLM judge', async () => {
      quizRepo.findOne.mockResolvedValueOnce({ id: 1 });
      attemptRepo.create.mockReturnValueOnce({ id: 7 } as any);
      attemptRepo.save.mockResolvedValueOnce({ id: 7, accuracy: 100 } as any);
      questionRepo.findOne.mockResolvedValueOnce({ id: 1, question: 'q', answer: 'a' });
      qAttemptRepo.save.mockResolvedValueOnce([] as any);

      // Provide a correct=true flag so the LLM evaluator should NOT be called.
      await service.evaluateAttempt({
        quizId: 1,
        attempts: [{ questionId: 1, value: 'a', correct: true }],
        difficulty: 3,
      } as any);

      // Only the analysis-generation call should hit the LLM, not evaluation.
      expect(langchain.run).toHaveBeenCalledTimes(1);
    });

    it('falls back to incorrect when the LLM judge throws', async () => {
      quizRepo.findOne.mockResolvedValueOnce({ id: 1 });
      attemptRepo.create.mockReturnValueOnce({ id: 7 } as any);
      // Echo the saved entity so accuracy/analysis set by the service survive.
      attemptRepo.save.mockImplementationOnce(async (e: any) => e);
      questionRepo.findOne.mockResolvedValueOnce({ id: 1, question: 'q', answer: 'a' });
      qAttemptRepo.save.mockResolvedValueOnce([] as any);

      // First call: boolean evaluator throws. Second: weak topic extractor.
      // Third: analysis. We make the first throw.
      langchain.run
        .mockRejectedValueOnce(new Error('parser blew up'))
        .mockResolvedValueOnce(['weak-topic'])
        .mockResolvedValueOnce('analysis text');

      const result = await service.evaluateAttempt({
        quizId: 1,
        attempts: [{ questionId: 1, value: 'something' }],
        difficulty: 3,
      } as any);

      // Accuracy should be 0% because we defaulted to incorrect.
      expect(result.accuracy).toBe(0);
    });
  });
});
