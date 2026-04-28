import { Test, TestingModule } from '@nestjs/testing';
import { ClassSerializerInterceptor, INestApplication, ValidationPipe } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import * as request from 'supertest';
import { QuizController } from '../src/quiz/quiz.controller';
import { QuizService } from '../src/quiz/quiz.service';
import { ResponseInterceptor } from '../src/common/interceptors/response.interceptor';
import { GlobalExceptionFilter } from '../src/common/filters/exception.filter';
import { QuizType } from '../src/quiz/enums/quiz-type.enum';

/**
 * End-to-end test for the quiz HTTP surface, with the QuizService stubbed.
 * We deliberately don't wire the full AppModule (DB + LLM + vectorstore) so
 * the test can run without external infra — it verifies routing, validation,
 * and the response envelope only.
 */
describe('Quiz e2e (controller + filters + interceptors)', () => {
  let app: INestApplication;
  let quizService: { createQuiz: jest.Mock; getQuizzes: jest.Mock; evaluateAttempt: jest.Mock; generateQuiz: jest.Mock };

  beforeAll(async () => {
    quizService = {
      createQuiz: jest.fn().mockResolvedValue(7),
      getQuizzes: jest.fn().mockResolvedValue([{ id: 1 }]),
      evaluateAttempt: jest.fn().mockResolvedValue({ id: 1, accuracy: 80 }),
      generateQuiz: jest.fn().mockResolvedValue({ id: 1, questions: [] }),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [QuizController],
      providers: [{ provide: QuizService, useValue: quizService }],
    }).compile();

    app = module.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    app.useGlobalInterceptors(
      new ClassSerializerInterceptor(app.get(Reflector)),
      new ResponseInterceptor(),
    );
    app.useGlobalFilters(new GlobalExceptionFilter());
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /quiz returns the standard envelope', async () => {
    const res = await request(app.getHttpServer()).get('/quiz').expect(200);
    expect(res.body).toMatchObject({
      status: true,
      message: 'Successful',
      data: [{ id: 1 }],
    });
  });

  it('POST /quiz/create rejects an invalid body', async () => {
    const res = await request(app.getHttpServer())
      .post('/quiz/create')
      .send({ documentIds: [], questions: 0, difficulty: 99, type: 'BAD' })
      .expect(400);
    expect(res.body.status).toBe(false);
  });

  it('POST /quiz/create accepts a valid body and returns the new id', async () => {
    const res = await request(app.getHttpServer())
      .post('/quiz/create')
      .send({
        documentIds: [1, 2],
        questions: 5,
        difficulty: 4,
        type: QuizType.MCQ,
      })
      .expect(201);
    expect(res.body.data).toBe(7);
    expect(quizService.createQuiz).toHaveBeenCalled();
  });

  it('POST /quiz/evaluate validates nested attempts', async () => {
    await request(app.getHttpServer())
      .post('/quiz/evaluate')
      .send({ quizId: 1, attempts: [], difficulty: 3 })
      .expect(400);
  });

  it('POST /quiz/generate/:id forwards the optional history body', async () => {
    await request(app.getHttpServer())
      .post('/quiz/generate/42')
      .send({})
      .expect(201);
    expect(quizService.generateQuiz).toHaveBeenCalledWith(42, expect.anything());
  });
});
