import { ChatOpenAI } from '@langchain/openai';
import { ChatPromptTemplate } from '@langchain/core/prompts';
import { StringOutputParser, CommaSeparatedListOutputParser } from '@langchain/core/output_parsers';

import { StructuredOutputParser } from 'langchain/output_parsers';
import { z } from 'zod';
// create model
const model = new ChatOpenAI({
  temperature: 0.7,
  openAIApiKey: 'lm-studio',
  configuration: {
    baseURL: 'http://localhost:1234/v1',
  },
});

async function callStringOutputParser() {
// create prompt
  const prompt =
    ChatPromptTemplate.fromTemplate('You\'re a comedian, tell a ' +
      'joke based on the following {input}');

  const parser = new StringOutputParser();

  const chain = prompt.pipe(model).pipe(parser);

  return await chain.invoke({
    input: 'dog',
  });

}


async function callListOutputParser() {
  const prompt =
    ChatPromptTemplate.fromTemplate('Provide 5 synonyms' +
      ', seperated by commas, for the following word {word}');

  const parser = new CommaSeparatedListOutputParser();

  const chain = prompt.pipe(model).pipe(parser);

  return await chain.invoke({
    word: 'love',
  });

}


async function callStructuredOutputParser() {

  const prompt =
    ChatPromptTemplate.fromTemplate(`
    Extract information from the following phrase. 
    Instructions: {format_instructions}. 
    Phrase: {phrase}`);

  const parser = StructuredOutputParser.fromNamesAndDescriptions({
    name: 'The name of the person',
    age: 'The age of the person',
  });

  const chain = prompt.pipe(model).pipe(parser);

  return await chain.invoke({
    phrase: 'Max is 29 years old.',
    format_instructions: parser.getFormatInstructions(),
  });

}

async function callZodOutputParser() {

  const prompt =
    ChatPromptTemplate.fromTemplate(`
    Extract information from the following phrase.  
    Instructions: {format_instructions}. 
    Phrase: {phrase}`);

  const parser = StructuredOutputParser.fromZodSchema(z.object({
    name: z.string().describe('name of the recipe'),
    ingredients: z.array(z.string()).describe('ingredients'),
  }));

  const chain = prompt.pipe(model).pipe(parser);

  return await chain.invoke({
    phrase: 'The ingredients of a Spaghetti Bolognese recipe are tomatoes, minced beef, garlic, wine and herbs',
    format_instructions: parser.getFormatInstructions(),
  });

}


const response = async () => await callZodOutputParser();


response().then((results) => console.log(results));
