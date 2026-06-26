import { Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';
import { ChatOpenAI } from '@langchain/openai';
import { PromptTemplate } from '@langchain/core/prompts';
import { BaseTransformOutputParser } from '@langchain/core/output_parsers';
import { AIMessageChunk } from '@langchain/core/messages';
import { BaseChatPromptTemplate } from '@langchain/core/dist/prompts/chat';
import { StructuredOutputParser } from 'langchain/output_parsers';


@Injectable()
export class LangchainService {
  private readonly logger = new Logger(LangchainService.name);
  private readonly llm: ChatOpenAI;
  // Exposed for the health controller — read-only.
  public readonly baseURL: string;
  public readonly model: string;
  public readonly apiKey: string;

  constructor() {
    this.baseURL = process.env.LLM_BASE_URL ?? 'http://localhost:1234/v1';
    this.apiKey = process.env.LLM_API_KEY ?? '';
    this.model = process.env.LLM_MODEL ?? '';
    const temperature = parseFloat(process.env.LLM_TEMPERATURE ?? '0.4');
    const timeoutMs = parseInt(process.env.LLM_TIMEOUT_MS ?? '120000', 10);
    const maxRetries = parseInt(process.env.LLM_MAX_RETRIES ?? '2', 10);

    this.llm = new ChatOpenAI({
      temperature,
      // ChatOpenAI requires an apiKey, but local servers (LM Studio / Ollama) ignore it.
      openAIApiKey: process.env.LLM_API_KEY ?? 'not-needed',
      // When unset (e.g. LM Studio auto-picks the loaded model) ChatOpenAI accepts
      // an empty/undefined model string.
      ...(this.model ? { model: this.model } : {}),
      timeout: timeoutMs,
      maxRetries,
      configuration: {
        baseURL: this.baseURL,
        // Use Node's native global fetch instead of the openai SDK's bundled
        // fetch shim. On Node 22 the shim intermittently throws "Premature
        // close" when reading remote LLM responses (e.g. Groq); the native
        // fetch reads the body reliably.
        fetch: (url: any, init?: any) => fetch(url, init),
      },
    });

    this.logger.log(
      `LLM configured: baseURL=${this.baseURL}, model=${this.model || '(server default)'}, timeout=${timeoutMs}ms`,
    );
  }

  async run<T = string>(options: {
    template: BaseChatPromptTemplate;
    input: Record<string, any>;
    parser?: BaseTransformOutputParser<T> | StructuredOutputParser<any>;
  }): Promise<T> {
    const { template, input, parser } = options;
    const chain = template.pipe(this.llm);

    let result;
    try {
      result = await chain.invoke(input);
    } catch (err: any) {
      this.logger.error(
        `LLM call failed (baseURL=${this.baseURL}): ${err?.message ?? err}`,
      );
      throw new ServiceUnavailableException(
        `LLM backend unavailable: ${err?.message ?? 'unknown error'}`,
      );
    }

    if (parser) {
      const text = typeof result?.content === 'string'
        ? result.content
        : JSON.stringify(result?.content ?? '');
      try {
        return await parser.parse(text);
      } catch (err: any) {
        this.logger.warn(
          `Output parser failed for text: ${text.slice(0, 200)}… (${err?.message ?? err})`,
        );
        throw err;
      }
    }

    const content = typeof result?.content === 'string'
      ? result.content
      : JSON.stringify(result?.content ?? '');
    return (content?.trim() || '') as T;
  }

  async stream<T = string>(options: {
    template: PromptTemplate;
    input: Record<string, any>;
    onToken: (chunk: AIMessageChunk) => void;
  }): Promise<string | void> {
    const { template, input, onToken } = options;


    const chain = template.pipe(this.llm);

    const stream = await chain.stream(input);

    let fullText = '';
    for await (const chunk of stream) {
      onToken(chunk);

      // For final parse, collect content if needed
      if ('content' in chunk) {
        fullText += chunk.content;
      }
    }

    return fullText;
  }

}
