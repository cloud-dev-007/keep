import type { Document } from 'langchain/document';
import { PDFLoader } from '@langchain/community/document_loaders/fs/pdf';
import { TextLoader } from 'langchain/document_loaders/fs/text';
import { DocxLoader } from '@langchain/community/document_loaders/fs/docx';
import { PPTXLoader } from '@langchain/community/document_loaders/fs/pptx';
import { BaseDocumentLoader } from '@langchain/core/dist/document_loaders/base';

interface LoadResult {
  documents: Document[];
  pageCount: number;
}

export class DocumentLoader {
  async load(filePath: string, fileType: string): Promise<LoadResult> {
    let loader: BaseDocumentLoader;

    switch (fileType.toLowerCase()) {
      case '.pdf':
        loader = new PDFLoader(filePath);
        break;

      case '.txt':
        loader = new TextLoader(filePath);
        break;

      case '.docx':
        loader = new DocxLoader(filePath);
        break;

      case '.doc':
        loader = new DocxLoader(filePath, { type: 'doc' });
        break;

      case '.pptx':
        loader = new PPTXLoader(filePath);
        break;

      default:
        throw new Error(`Unsupported file type: ${fileType}`);
    }

    const documents = await loader.load();
    const pageCount = ['.pdf', '.docx', '.doc', '.pptx'].includes(fileType.toLowerCase())
      ? documents.length
      : 1;

    return { documents, pageCount };
  }
}