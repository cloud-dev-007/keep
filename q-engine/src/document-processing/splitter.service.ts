import { Injectable } from '@nestjs/common';
import { RecursiveCharacterTextSplitter } from 'langchain/text_splitter';
import type { Document } from 'langchain/document';

@Injectable()
export class DocumentSplitterService {
  private readonly splitter = new RecursiveCharacterTextSplitter({
    chunkSize: 1000,
    chunkOverlap: 200,
  });

  async split(documents: Document[]): Promise<Document[]> {
    return await this.splitter.splitDocuments(documents);
  }
}