import { Module } from '@nestjs/common';
import { DocumentController } from './document.controller';
import { Document } from './entity/document.entity';
import { DocumentService } from './document.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LangchainModule } from '../langchain/langchain.module';
import { DocumentProcessingModule } from '../document-processing/document-processing.module';

@Module({
  imports: [TypeOrmModule.forFeature([Document]), LangchainModule, DocumentProcessingModule],
  controllers: [DocumentController],
  providers: [DocumentService],
  exports: [DocumentService],
})
export class DocumentModule {
}
