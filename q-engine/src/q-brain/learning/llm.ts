import { ChatOpenAI } from '@langchain/openai';

const model = new ChatOpenAI({
  temperature: 0.7,
  openAIApiKey: 'lm-studio',
  verbose: true,
  configuration: {
    baseURL: 'http://localhost:1234/v1',
  },
});

void (async () => {
  const res = await model.invoke('hey');
  console.log(res.content);
})();
