import { Module } from '@nestjs/common';
import { QuizController } from './quiz.controller';
import { QuizService } from './quiz.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Quiz } from './entitites/quiz.entity';
import { QuizQuestion } from './entitites/quiz-question.entity';
import { DocumentModule } from '../document/document.module';
import { LangchainModule } from '../langchain/langchain.module';
import { DocumentProcessingModule } from '../document-processing/document-processing.module';
import { QuizOption } from './entitites/quiz-option.entity';
import { QuizAttempt } from './entitites/quiz-attempt.entity';
import { QuestionAttempt } from './entitites/question-attempt.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Quiz, QuizQuestion, QuizOption, QuizAttempt, QuestionAttempt]),
    DocumentModule, LangchainModule, DocumentProcessingModule,
  ],
  controllers: [QuizController],
  providers: [QuizService],
})
export class QuizModule {
}
