import { Entity, PrimaryGeneratedColumn, Column, OneToMany, CreateDateColumn, ManyToMany, JoinTable } from 'typeorm';
import { QuizQuestion } from './quiz-question.entity';
import { Document } from '../../document/entity/document.entity';
import { QuizType } from '../enums/quiz-type.enum';
import { QuizAttempt } from './quiz-attempt.entity';

@Entity()
export class Quiz {
  @PrimaryGeneratedColumn()
  id: number;


  @Column({ nullable: true })
  title: string;

  @Column()
  difficulty: number;

  @Column({ nullable: true })
  duration?: number;

  @Column()
  noOfQuestions: number;

  @Column({ nullable: true })
  isAdaptive?: boolean;

  @Column({
    type: 'enum',
    enum: QuizType,
  })
  type: QuizType;

  @OneToMany(() => QuizQuestion, question => question.quiz, { cascade: true })
  questions: QuizQuestion[];

  @OneToMany(() => QuizAttempt, history => history.quiz, { cascade: true })
  history: QuizAttempt[];

  @ManyToMany(() => Document)
  @JoinTable()
  documents: Document[];

  @CreateDateColumn()
  createdAt: Date;

} 