import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { Quiz } from './quiz.entity';
import { QuizQuestion } from './quiz-question.entity';
import { QuizAttempt } from './quiz-attempt.entity';

@Entity()
export class QuizOption {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  value: string;

  @Column()
  isAnswer: boolean;

  @ManyToOne(() => QuizQuestion, quiz => quiz.options)
  question: QuizQuestion;

}