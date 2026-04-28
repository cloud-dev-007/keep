import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppController } from '../src/app.controller';
import { AppService } from '../src/app.service';

/**
 * Minimal smoke test for the AppController. We don't bring up the full
 * AppModule here because it requires a live Postgres + LLM. The integration
 * test for the quiz surface lives in quiz.e2e-spec.ts.
 */
describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [AppService],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('/ (GET) returns the hello message', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(200)
      .expect('Hello World!');
  });
});
