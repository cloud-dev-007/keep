import { NestFactory, Reflector } from '@nestjs/core';
import { AppModule } from './app.module';
import { ClassSerializerInterceptor, Logger, ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';
import { GlobalExceptionFilter } from './common/filters/exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log'],
  });

  // ---- Security ------------------------------------------------------------
  // Helmet: secure headers. We disable contentSecurityPolicy so Swagger UI
  // can load its inline styles/scripts.
  app.use(helmet({ contentSecurityPolicy: false }));

  // CORS: comma-separated origins via env. "*" allows any origin (dev only).
  const corsOrigins = (process.env.CORS_ORIGINS ?? '*')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
  app.enableCors({
    origin: corsOrigins.includes('*') ? true : corsOrigins,
    credentials: true,
  });

  // ---- Global pipes / interceptors / filters -------------------------------
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: false,
    }),
  );
  app.useGlobalInterceptors(
    new ClassSerializerInterceptor(app.get(Reflector)),
    new ResponseInterceptor(),
  );
  app.useGlobalFilters(new GlobalExceptionFilter());

  // Graceful shutdown for Docker / orchestrators.
  app.enableShutdownHooks();

  // ---- Swagger / OpenAPI ---------------------------------------------------
  const swaggerConfig = new DocumentBuilder()
    .setTitle('qCraft API')
    .setDescription(
      'Adaptive quiz generation API. Upload documents, generate quizzes ' +
        'mapped to Bloom\'s taxonomy levels, evaluate attempts.',
    )
    .setVersion('1.0')
    .build();
  const swaggerDoc = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api/docs', app, swaggerDoc, {
    swaggerOptions: { persistAuthorization: true },
  });

  // ---- Listen --------------------------------------------------------------
  const port = parseInt(process.env.PORT ?? '3000', 10);
  await app.listen(port, '0.0.0.0');
  const logger = new Logger('Bootstrap');
  logger.log(`q-engine running on http://0.0.0.0:${port}`);
  logger.log(`Swagger UI:    http://0.0.0.0:${port}/api/docs`);
  logger.log(`Health check:  http://0.0.0.0:${port}/health`);
}

bootstrap();
