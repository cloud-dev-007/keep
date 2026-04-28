import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { QuizType } from './enums/quiz-type.enum';
import { Type } from 'class-transformer';

export class QuizSetupDto {
  @ApiProperty({ type: [Number], description: 'IDs of source documents' })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(20)
  @IsInt({ each: true })
  readonly documentIds: number[];

  @ApiProperty({ description: 'Number of questions to generate', minimum: 1, maximum: 50 })
  @IsInt()
  @Min(1)
  @Max(50)
  readonly questions: number;

  @ApiProperty({ description: 'Difficulty 1–10 (mapped to Bloom level)', minimum: 1, maximum: 10 })
  @IsInt()
  @Min(1)
  @Max(10)
  readonly difficulty: number;

  @ApiProperty({ required: false, description: 'Duration in seconds' })
  @IsOptional()
  @IsInt()
  @Min(0)
  readonly duration?: number;

  @ApiProperty({ enum: QuizType })
  @IsEnum(QuizType)
  readonly type: QuizType;
}

export class QuestionAttemptDto {
  @ApiProperty()
  @IsInt()
  readonly questionId: number;

  @ApiProperty({ description: 'The user-provided answer text' })
  @IsString()
  @MaxLength(2000)
  readonly value: string;

  @ApiProperty({ required: false, description: 'Pre-computed correctness — when omitted the LLM judges' })
  @IsOptional()
  @IsBoolean()
  readonly correct?: boolean;
}

export class QuizAttemptDto {
  @ApiProperty()
  @IsInt()
  readonly quizId: number;

  @ApiProperty({ type: [QuestionAttemptDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => QuestionAttemptDto)
  readonly attempts: Array<QuestionAttemptDto>;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  readonly accuracy?: number;

  @ApiProperty({ required: false, description: 'Seconds spent on the attempt' })
  @IsOptional()
  @IsInt()
  @Min(0)
  readonly timeTaken?: number;

  @ApiProperty({ description: 'Difficulty the attempt was taken at', minimum: 1, maximum: 10 })
  @IsInt()
  @Min(1)
  @Max(10)
  readonly difficulty: number;
}
