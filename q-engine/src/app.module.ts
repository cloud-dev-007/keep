import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DocumentModule } from './document/document.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LangchainModule } from './langchain/langchain.module';
import { QuizModule } from './quiz/quiz.module';
import { DocumentProcessingModule } from './document-processing/document-processing.module';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { HealthModule } from './health/health.module';
import { dataSourceOptions } from './data-source';
import { AuthModule } from './auth/auth.module';
import { JwtAuthGuard } from './auth/jwt-auth.guard';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ThrottlerModule.forRoot([
      {
        ttl: parseInt(process.env.THROTTLE_TTL ?? '60', 10) * 1000,
        limit: parseInt(process.env.THROTTLE_LIMIT ?? '120', 10),
      },
    ]),
    TypeOrmModule.forRoot({
      ...dataSourceOptions,
      autoLoadEntities: true,
      // Allow dev-only schema sync via env, default off in prod.
      synchronize:
        process.env.DB_SYNCHRONIZE === 'true' &&
        process.env.NODE_ENV !== 'production',
      // Run pending migrations on boot in non-dev or when explicitly asked.
      migrationsRun: process.env.DB_MIGRATIONS_RUN === 'true',
    }),
    AuthModule,
    DocumentModule,
    LangchainModule,
    QuizModule,
    DocumentProcessingModule,
    HealthModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    // Auth runs after throttling. Routes opt out with @Public().
    { provide: APP_GUARD, useClass: JwtAuthGuard },
  ],
})
export class AppModule {}
