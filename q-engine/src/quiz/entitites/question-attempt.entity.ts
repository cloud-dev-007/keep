import { Column, Entity, JoinColumn, ManyToOne, OneToOne, PrimaryGeneratedColumn } from 'typeorm';
import { QuizQuestion } from './quiz-question.entity';
import { QuizAttempt } from './quiz-attempt.entity';

@Entity()
export class QuestionAttempt {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => QuizQuestion, question => question.attempts, { nullable: false })
  @JoinColumn()
  question: QuizQuestion;

  @Column()
  value: string;

  @Column()
  correct: boolean;

  @ManyToOne(() => QuizAttempt, history => history.attempts)
  @JoinColumn()
  history: QuizAttempt;
}