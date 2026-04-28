import { Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { Quiz } from './quiz.entity';
import { QuestionAttempt } from './question-attempt.entity';

@Entity()
export class QuizAttempt {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Quiz, quiz => quiz.history)
  @JoinColumn()

  quiz: Quiz;

  @OneToMany(() => QuestionAttempt, attempt => attempt.history, { cascade: true })
  attempts: Array<QuestionAttempt>;

  @Column({ type: 'float', nullable: true })
  accuracy: number;

  @Column({ type: 'int', nullable: true })
  timeTaken?: number;

  @Column('text', { array: true, nullable: true })
  weakTopics: string[];

  @Column({ type: 'text', nullable: true })
  analysis: string;

  @Column({ nullable: true })
  difficulty: number;

  @CreateDateColumn()
  createdAt: Date;
}