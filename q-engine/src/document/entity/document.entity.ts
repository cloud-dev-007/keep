import { Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { User } from '../../auth/user.entity';

@Entity()
export class Document {
  @PrimaryGeneratedColumn()
  id: number;

  // Owner. Nullable so the migration can add the column to any legacy rows.
  @ManyToOne(() => User, { onDelete: 'CASCADE', nullable: true })
  user?: User;

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