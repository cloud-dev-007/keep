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

    const rows = await this.dataSource.query(
      `
          SELECT document, cmetadata
          FROM ${this.tableName}
          WHERE cmetadata->>'lectureNoteId' = $1
          ORDER BY (cmetadata->>'chunkIndex')::int ASC
      `,
      [this.lectureNoteId.toString()],
    );

    return rows.map((row: any) => {
      return new Document({
        pageContent: row.document,
        metadata: row.cmetadata,
      });
    });
  }
}