import { BadRequestException, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';

import { Document } from './entity/document.entity';
import { extname } from 'path';
import { DocumentExtractionService } from '../document-processing/document-extraction.service';
import { DocumentLoader } from '../document-processing/document.loader';
import { DocumentSplitterService } from '../document-processing/splitter.service';
import { VectorStoreService } from '../document-processing/vector-store.service';

@Injectable()
export class DocumentService {

  private readonly logger = new Logger(DocumentService.name);

  constructor(
    @InjectRepository(Document) private readonly documentRepository: Repository<Document>,
    private readonly documentLoader: DocumentLoader,
    private readonly splitter: DocumentSplitterService,
    private readonly vectorStore: VectorStoreService,
    private readonly documentExtractor: DocumentExtractionService,
  ) {};

  async getAllDocuments(ids?: Array<number>) {
    const where = ids && ids.length > 0 ? { id: In(ids) } : {};
    return await this.documentRepository.find({
      where,
      order: { createdAt: 'DESC' },
    });
  }

  async updateDocument(id: number, updateData: Partial<Document>) {
    await this.documentRepository.update(id, updateData);
    return await this.findOne(id);
  }


  async uploadDocuments(files: Array<Express.Multer.File>) {
    const supportedExtensions = ['.pdf', '.docx', '.doc', '.pptx', '.txt'];

    const savedDocs = files.map((file) => {
        const format = extname(file.path);
        const fileExtension = format.toLowerCase();
        if (!supportedExtensions.includes(fileExtension)) {
          throw new BadRequestException(`Unsupported file type: ${fileExtension}`);
        }
        return this.documentRepository.create({
          formatType: format,
          fileName: file.originalname,
          filePath: file.path,
        });
      },
    );
    const documents = await this.documentRepository.save(savedDocs);

    // Process and embed in the background so the upload response returns immediately
    for (const doc of documents) {
      this.processAndEmbedDocument(doc.id).catch((err) => {
        this.logger.error(`Failed to process document ${doc.id}`, err.stack);
      });
    }

    return documents;
  }

  async processAndEmbedDocument(documentId: number): Promise<Document> {
    // 1. Fetch document from DB
    const document = await this.findOne(documentId);

    if (!document) {
      throw new NotFoundException('Document not found');
    }

    this.logger.log(`Document found for document_${documentId}`);

    const fileExtension = document.formatType;
    // 2. Load document using LangChain document loader
    const rawDocuments = await this.documentLoader.load(document.filePath, fileExtension).catch((err) => {
      this.logger.error(`Failed to load document ${fileExtension}`);
      throw Error(err);
    });
    document.pageCount = rawDocuments.pageCount;
    this.logger.log(`Document loaded successfully for document_${documentId} with ${rawDocuments.pageCount} raw chunks`);


    const chunks = await this.splitter.split(rawDocuments.documents).catch((err) => {
      this.logger.error(`Failed to split document "${documentId}`);
      throw new Error(`${err.message}`);
    });
    this.logger.log(`Document successfully split chunks ${chunks.length}`);

    // 4. Embed each chunk and save to vector store
    const storedVectors = await this.vectorStore.addDocuments(chunks, documentId).catch((err) => {
      const error = `Failed to embed and store chunks for document "${documentId}": ${err.message}`;
      this.logger.error(error);
      throw new Error(`Failed to embed and store chunks for document "${documentId}": ${err.message}`);
    });
    this.logger.log(`Document saved in vector store ${storedVectors}`);

    // 5. Join all text content from chunks
    const mainText = chunks.map(chunk => chunk.pageContent).join('\n');

    const allText = await this.documentExtractor.extractSummary(mainText).catch((err) => {
      const error = `Failed to extract topics for document "${documentId}": ${err.message}`;
      this.logger.error(error);
      throw new Error(`Failed to extract topics for document "${documentId}": ${err.message}`);
    });
    this.logger.log(`Successfully summarized the document `);


    document.topics = await this.documentExtractor.extractTopics(allText).catch((err) => {
      const error = `Failed to extract topics for document "${documentId}": ${err.message}`;
      this.logger.error(error);
      throw new Error(`Failed to extract topics for document "${documentId}": ${err.message}`);
    });
    this.logger.log(`Successfully extracted the topics ${document.topics}`);


    document.description = await this.documentExtractor.extractDescription(allText).catch((err) => {
      const error = `Failed to extract description for document "${documentId}": ${err.message}`;
      this.logger.error(error);
      throw new Error(`Failed to extract description for document "${documentId}": ${err.message}`);
    });
    this.logger.log(`Document successfully split chunks ${document.description}`);


    document.title = await this.documentExtractor.extractTitle(allText).catch((err) => {
      const error = `Failed to extract title for document "${documentId}": ${err.message}`;
      this.logger.error(error);
      throw new Error(`Failed to extract title for document "${documentId}": ${err.message}`);
    });
    this.logger.log(`Successfully extract title for document "${document.title}"`);


    await this.updateDocument(documentId, document).catch((err) => {
      const error = `Failed to update document "${documentId}" with extracted metadata: ${err.message}`;
      this.logger.error(error);
      throw new Error(`${err.message}`);
    });
    this.logger.log(`Document successfully updated the properties for id: ${documentId}`);


    return document;
  }

  async findOne(id: number) {
    const document = await this.documentRepository.findOne({ where: { id } });
    if (!document) {
      throw new NotFoundException(`Document with id ${id} not found`);
    }
    return document;
  }

  async removeDocument(id: number) {
    const document = await this.findOne(id);
    return await this.documentRepository.remove(document);
  }
}
