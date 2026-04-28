import {
  Body,
  Controller,
  Get,
  Logger,
  Param,
  ParseIntPipe,
  Post,
  Query,
} from '@nestjs/common';
import { QuizService } from './quiz.service';
import { QuizAttemptDto, QuizSetupDto } from './quiz.dto';
import { QuizAttempt } from './entitites/quiz-attempt.entity';
import { ApiOperation, ApiParam, ApiQuery, ApiTags } from '@nestjs/swagger';

@ApiTags('quiz')
@Controller('quiz')
export class QuizController {
  private readonly logger = new Logger(QuizController.name);

  constructor(private readonly quizService: QuizService) {}

  @Get()
  @ApiOperation({ summary: 'List quizzes (optionally filter by ids)' })
  @ApiQuery({ name: 'ids', required: false, type: [Number] })
  async getQuizzes(@Query('ids') ids?: Array<number>) {
    return this.quizService.getQuizzes(ids);
  }

  @Post('evaluate')
  @ApiOperation({ summary: 'Evaluate a completed quiz attempt' })
  async evaluateAttempt(@Body() attempt: QuizAttemptDto) {
    return this.quizService.evaluateAttempt(attempt);
  }

  @Post('create')
  @ApiOperation({ summary: 'Create a quiz definition (no questions yet)' })
  async createQuiz(@Body() quiz: QuizSetupDto) {
    return this.quizService.createQuiz(quiz);
  }

  @Post('generate/:id')
  @ApiOperation({
    summary:
      'Generate quiz questions + answers. Pass a previous attempt body to ' +
      'enter adaptive mode that focuses on weak topics.',
  })
  @ApiParam({ name: 'id', type: Number })
  async generateQuiz(
    @Param('id', ParseIntPipe) quizId: number,
    @Body() history?: QuizAttempt,
  ) {
    // The work is async + slow (LLM heavy); errors propagate via the global
    // exception filter. We log here for observability.
    return this.quizService.generateQuiz(quizId, history).catch((err) => {
      this.logger.error(
        `generateQuiz(${quizId}) failed: ${err?.message ?? err}`,
        err?.stack,
      );
      throw err;
    });
  }
}
