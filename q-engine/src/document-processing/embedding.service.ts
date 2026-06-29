// document-processing/embedding.service.ts
import { Injectable, OnModuleInit } from '@nestjs/common';
import { HuggingFaceTransformersEmbeddings } from '@langchain/community/embeddings/huggingface_transformers';
import type { Document } from 'langchain/document';

@Injectable()
export class EmbeddingService implements OnModuleInit {
  public embedder: HuggingFaceTransformersEmbeddings;

  async onModuleInit() {
    // Small (384-dim, ~130MB) CPU-friendly model. bge-large (1.3GB) OOM-crashes
    // small hosts when embedding large documents (hundreds of chunks). Quality
    // is plenty for quiz generation, which mostly retrieves chunks by document
    // id rather than by similarity. Must match VectorStoreService's model.
    this.embedder = new HuggingFaceTransformersEmbeddings({
      model: 'Xenova/bge-small-en-v1.5',
      maxConcurrency: 2,
    });
  }

  async embedText(text: string) {
    return await this.embedder.embedQuery(text);
  }

  // async embedDocuments(documents: Document[]): Promise<Array<{ embedding: number[]; metadata: any }>> {
  //   const texts = documents.map((doc) => doc.pageContent);
  //   const metadata = documents.map((doc) => doc.metadata);
  //
  //   const embeddings = await this.embedder.embedDocuments(texts);
  //
  //   return embeddings.map((embedding, i) => ({
  //     embedding,
  //     metadata: metadata[i],
  //   }));
  // }
}