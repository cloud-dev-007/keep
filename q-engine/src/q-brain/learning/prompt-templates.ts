import { ChatOpenAI } from '@langchain/openai';
import { ChatPromptTemplate } from '@langchain/core/prompts';

// create model
const model = new ChatOpenAI({
  temperature: 0.7,
  openAIApiKey: 'lm-studio',
  configuration: {
    baseURL: 'http://localhost:1234/v1',
  },
});

// create prompt
// const prompt =
//   ChatPromptTemplate.fromTemplate('You\'re a comedian, tell a ' +
//     'joke based on the following {input}');

const prompt =
  ChatPromptTemplate.fromMessages([[

    'system', 'You\'re a comedian, tell a ' +
    'joke based on the following {input}'],
    ['human', '{input}']]);

const chain = prompt.pipe(model);

const response = async () => await chain.invoke({
  input: 'dog',
});

console.log(response().then(result => {
  console.log(result.content);
}));