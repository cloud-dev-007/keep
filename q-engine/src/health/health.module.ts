import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TerminusModule } from '@nestjs/terminus';
import { HealthController } from './health.controller';
import { LangchainModule } from '../langchain/langchain.module';

@Module({
  imports: [TerminusModule, HttpModule, LangchainModule],
  controllers: [HealthController],
})
export class HealthModule {}
