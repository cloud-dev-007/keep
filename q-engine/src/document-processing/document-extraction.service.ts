import { Injectable } from '@nestjs/common';
import { CommaSeparatedListOutputParser } from '@langchain/core/output_parsers';
import { ChatPromptTemplate } from '@langchain/core/prompts';
import { LangchainService } from '../langchain/langchain.service';
import { PromptTemplates } from '../langchain/prompt.templates';

@Injectable()
export class DocumentExtractionService {
  constructor(private readonly langchain: LangchainService) {
  }


  async extractTopics(text: string): Promise<string[]> {
    const template = ChatPromptTemplate.fromTemplate(PromptTemplates.extractTopics);

    const parser = new CommaSeparatedListOutputParser();

    return await this.langchain.run<string[]>({
      template,
      input: { text, instructions: parser.getFormatInstructions() },
      parser,
    });
  }

  async extractTitle(text: string): Promise<string> {
    const template = ChatPromptTemplate.fromTemplate(PromptTemplates.extractTitle);

    return await this.langchain.run<string>({
      template,
      input: { text },
    });
  }

  async extractDescription(text: string): Promise<string> {
    const template = ChatPromptTemplate.fromTemplate(PromptTemplates.extractDescription);

    return await this.langchain.run<string>({
      template,
      input: { text },
    });
  }

  async extractSummary(text: string): Promise<string> {
    const MAX_TOKENS = 4000;
    const CHUNK_SIZE = 2000; // Smaller chunks for better summarization
    const MAX_RECURSION = 3; // Prevent infinite loops

    if (!text) {
      throw new Error('Input text cannot be empty');
    }

    // Rough token estimation (4 chars per token)
    const getTokenCount = (text: string) => Math.ceil(text.length / 4);

    // Return if already under limit
    if (getTokenCount(text) < MAX_TOKENS) {
      return text;
    }

    // Split into chunks
    const chunkSize = CHUNK_SIZE * 4; // Convert to characters
    const chunks: string[] = [];

    for (let i = 0; i < text.length; i += chunkSize) {
      chunks.push(text.slice(i, i + chunkSize));
    }

    // Summarize each chunk
    const template = ChatPromptTemplate.fromTemplate(PromptTemplates.extractSummary);
    const summaries: string[] = [];

    for (const chunk of chunks) {
      try {
        const summary = await this.langchain.run<string>({
          template,
          input: { text: chunk },
        });
        summaries.push(summary);
      } catch (error) {
        console.error('Failed to summarize chunk:', error);
        // If summarization fails, use the original chunk
        summaries.push(chunk);
      }
    }

    // Combine summaries
    const combinedText = summaries.join('\n\n');

    // Recursively process if still too long, but limit recursion depth
    if (getTokenCount(combinedText) >= MAX_TOKENS && MAX_RECURSION > 0) {
      return await this.extractSummary(combinedText);
    }

    return combinedText;
  }
}

