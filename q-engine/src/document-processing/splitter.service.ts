import { Injectable } from '@nestjs/common';
import { RecursiveCharacterTextSplitter } from 'langchain/text_splitter';
import type { Document } from 'langchain/document';

@Injectable()
export class DocumentSplitterService {
  // Larger chunks → far fewer of them per document, which keeps embedding
  // tractable on small CPU-only hosts (a 472-page PDF goes from ~838 chunks
  // to ~210). Still small enough for focused retrieval.
  private readonly splitter = new RecursiveCharacterTextSplitter({
    chunkSize: 4000,
    chunkOverlap: 400,
  });

  async split(documents: Document[]): Promise<Document[]> {
    return await this.splitter.splitDocuments(documents);
  }
}