import { Module } from '@nestjs/common';
import { DocumentLoader } from './document.loader';
import { DocumentExtractionService } from './document-extraction.service';
import { EmbeddingService } from './embedding.service';
import { DocumentSplitterService } from './splitter.service';
import { VectorStoreService } from './vector-store.service';
import { LangchainModule } from '../langchain/langchain.module';

@Module({
  imports: [LangchainModule],
  controllers: [],
  providers: [DocumentLoader, DocumentExtractionService, EmbeddingService, DocumentSplitterService, VectorStoreService],
  exports: [VectorStoreService, DocumentExtractionService, DocumentLoader, DocumentSplitterService],
})
export class DocumentProcessingModule {

}
