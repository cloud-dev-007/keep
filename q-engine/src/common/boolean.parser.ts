import { BaseMessage } from '@langchain/core/messages';
import type { Callbacks } from '@langchain/core/callbacks/manager';
import { BaseTransformOutputParser } from '@langchain/core/output_parsers';

export class BooleanOutputParser extends BaseTransformOutputParser<boolean> {
  lc_namespace = ['langchain', 'output_parsers'];

  constructor() {
    super();
  }

  static lc_name() {
    return 'BooleanOutputParser';
  }

  async* _transform(inputGenerator: AsyncGenerator<string | BaseMessage>): AsyncGenerator<boolean> {
    let accumulatedText = '';

    for await (const chunk of inputGenerator) {
      const text = typeof chunk === 'string' ? chunk : chunk.content.toString();
      accumulatedText += text;
    }

    // Parse the accumulated text as boolean
    const normalized = accumulatedText.trim().toLowerCase();

    // True values
    if (normalized === 'true' ||
      normalized === 'yes' ||
      normalized === '1' ||
      normalized === 'on' ||
      normalized === 'correct' ||
      normalized === 'right') {
      yield true;
      return;
    }

    // False values
    if (normalized === 'false' ||
      normalized === 'no' ||
      normalized === '0' ||
      normalized === 'off' ||
      normalized === 'incorrect' ||
      normalized === 'wrong') {
      yield false;
      return;
    }

    // If it's not a clear boolean, throw an error
    throw new Error(`Unable to parse "${accumulatedText}" as a boolean. Expected values like: true, false, yes, no, 1, 0`);
  }

  getFormatInstructions() {
    return 'Respond with a single word: \'true\' or \'false\', \'yes\' or \'no\', or \'1\' or \'0\'.';
  }

  async parse(text: string, callbacks?: Callbacks): Promise<boolean> {
    const normalized = text.trim().toLowerCase();

    // True values
    if (normalized === 'true' ||
      normalized === 'yes' ||
      normalized === '1' ||
      normalized === 'on' ||
      normalized === 'correct' ||
      normalized === 'right') {
      return true;
    }

    // False values
    if (normalized === 'false' ||
      normalized === 'no' ||
      normalized === '0' ||
      normalized === 'off' ||
      normalized === 'incorrect' ||
      normalized === 'wrong') {
      return false;
    }

    // If it's not a clear boolean, throw an error
    throw new Error(`Unable to parse "${text}" as a boolean. Expected values like: true, false, yes, no, 1, 0`);
  }

  _type() {
    return 'boolean_output_parser';
  }
}

// Usage example:
// const parser = new BooleanOutputParser();
// const result = await parser.parse("yes"); // returns true
// const instructions = parser.getFormatInstructions();