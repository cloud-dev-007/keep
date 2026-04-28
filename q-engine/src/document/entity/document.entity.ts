import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class Document {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  title?: string;

  @Column({ nullable: true })
  description?: string;

  @Column('text', { array: true, nullable: true })
  topics?: string[];

  @Column()
  formatType: string;

  @Column()
  fileName: string;

  @Column()
  filePath: string;

  @Column({ nullable: true })
  pageCount: number;

  @CreateDateColumn()
  createdAt: Date;
}