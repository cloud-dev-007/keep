import { PGVectorStore } from '@langchain/community/vectorstores/pgvector';
import { HuggingFaceTransformersEmbeddings } from '@langchain/community/embeddings/huggingface_transformers';
import { PoolConfig } from 'pg';
import { Document } from '@langchain/core/documents';
import { Injectable, OnModuleInit } from '@nestjs/common';

@Injectable()
export class VectorStoreService implements OnModuleInit {
  private vectorStore: PGVectorStore;
  private embedder: HuggingFaceTransformersEmbeddings;

  async onModuleInit() {
    // 1. Initialize HuggingFace embedder
    this.embedder = new HuggingFaceTransformersEmbeddings({
      model: 'BAAI/bge-large-en-v1.5',
      maxConcurrency: 2,
    });

    // 2. Initialize PGVectorStore with embedder
    this.vectorStore = await PGVectorStore.initialize(this.embedder, {
      postgresConnectionOptions: {
        user: process.env.DB_USER ?? 'postgres',
        host: process.env.DB_HOST ?? 'localhost',
        database: process.env.DB_NAME ?? 'postgres',
        password: process.env.DB_PASSWORD ?? 'pass123',
        port: parseInt(process.env.DB_PORT ?? '5432'),
      } as PoolConfig,
      tableName: 'vectorstore',
    });
  }

  async similaritySearch(queryText: string, topK?: number, noteId?: number) {
    const filter = noteId != null ? { filter: { lectureNoteId: noteId } } : undefined;
    return await this.vectorStore.similaritySearch(queryText, topK, filter as any);
  }


  async addDocuments(docs: Document[], lectureNoteId: number) {
    // 3. Attach metadata to each doc and prepare custom IDs
    // const ids: string[] = [];

    docs.forEach((doc, i) => {
      doc.metadata = {
        ...doc.metadata,
        lectureNoteId,
        chunkIndex: i,
        page: doc.metadata?.pageNumber ?? null,
      };

      // ids.push(`note_${lectureNoteId}_chunk_${i}`);
    });
    // 4. Add documents to the vector store with custom IDs
    return await this.vectorStore.addDocuments(docs);
  }

}