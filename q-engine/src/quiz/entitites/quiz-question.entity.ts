import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToMany, JoinColumn } from 'typeorm';
import { Quiz } from './quiz.entity';
import { QuizOption } from './quiz-option.entity';
import { QuestionAttempt } from './question-attempt.entity';

@Entity()
export class QuizQuestion {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  type: string;

  @Column('text')
  question: string;

  @Column('text', { nullable: true })
  answer?: string;

  @OneToMany(() => QuizOption, option => option.question, { cascade: true })
  options: QuizOption[];

  @ManyToOne(() => Quiz, quiz => quiz.questions)
  @JoinColumn()
  quiz: Quiz;

  @OneToMany(() => QuestionAttempt, attempt => attempt.question)
  attempts: QuestionAttempt[];
}