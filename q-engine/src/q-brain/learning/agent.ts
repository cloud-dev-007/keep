import { ChatOpenAI } from '@langchain/openai';
import { ChatPromptTemplate, MessagesPlaceholder } from '@langchain/core/prompts';
import { createOpenAIFunctionsAgent, AgentExecutor } from 'langchain/agents';
import { TavilySearch } from '@langchain/tavily';
import * as readline from 'node:readline';

async function main() {
// create model
  const model = new ChatOpenAI({
    temperature: 0.7,
    openAIApiKey: 'lm-studio',
    configuration: {
      baseURL: 'http://localhost:1234/v1',
    },
  });
  process.env.TAVILY_API_KEY = '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';

  const prompt =
    ChatPromptTemplate.fromMessages([[

      'system', 'You\'re a helpful assistant called Max.'],
      ['human', '{input}'],
      new MessagesPlaceholder('agent_scratchpad'),
    ]);

  const searchTool = new TavilySearch();

  const tools = [searchTool];

  const agent = await createOpenAIFunctionsAgent({
      llm: model,
      prompt,
      tools,
    },
  );


  const agentExecutor = new AgentExecutor({ agent, tools });


  const rl = readline.createInterface(
    {
      input: process.stdin,
      output: process.stdout,
    },
  );


  function askQuestion() {


    rl.question('User: ', async (input) => {

      if (input.toLowerCase() === 'exit') {
        rl.close();
        return;
      }


      const response = await agentExecutor.invoke({
        input,
      });


      console.log(`Agent: ${response.output}`);
      askQuestion();

    });
  }

  askQuestion();

}


main().then(r => {

});