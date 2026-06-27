// lectureNote.retriever.ts
import { Document } from 'langchain/document';
import { DataSource } from 'typeorm';
import { BaseRetriever } from '@langchain/core/retrievers';

export class DocumentRetriever extends BaseRetriever {
  lc_namespace = ['documentProcessing', 'retrievers', 'documentRetriever'];

  constructor(
    private readonly dataSource: DataSource,
    private readonly lectureNoteId: number,
    private readonly tableName: string = 'vectorstore',
  ) {
    super();
  }

  async retrieveRelevantDocuments(_query?: string): Promise<Document[]> {

    // NB: langchain's PGVectorStore stores content in "text" and metadata in
    // "metadata" (not the Python PGVector "document"/"cmetadata" names). Using
    // the wrong columns silently yields no context, which makes the LLM fall
    // back to generic (Bloom's-taxonomy) questions regardless of the upload.
    const rows = await this.dataSource.query(
      `
          SELECT text, metadata
          FROM ${this.tableName}
          WHERE metadata->>'lectureNoteId' = $1
          ORDER BY (metadata->>'chunkIndex')::int ASC
      `,
      [this.lectureNoteId.toString()],
    );

    return rows.map((row: any) => {
      return new Document({
        pageContent: row.text,
        metadata: row.metadata,
      });
    });
  }
}