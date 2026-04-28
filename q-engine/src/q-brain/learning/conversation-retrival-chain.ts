import { ChatOpenAI } from '@langchain/openai';

import { ChatPromptTemplate } from '@langchain/core/prompts';

import { CheerioWebBaseLoader } from '@langchain/community/document_loaders/web/cheerio';
import { RecursiveCharacterTextSplitter } from 'langchain/text_splitter';

import { MessagesPlaceholder } from '@langchain/core/prompts';
import { LlamaCppEmbeddings } from '@langchain/community/embeddings/llama_cpp';

import { AIMessage, HumanMessage } from '@langchain/core/messages';

import { MemoryVectorStore } from 'langchain/vectorstores/memory';
import { createRetrievalChain } from 'langchain/chains/retrieval';
import { createHistoryAwareRetriever } from 'langchain/chains/history_aware_retriever';


// Load data & create vector store
const createVectorStore = async () => {

  const llamaPath = '/Users/lukasio/.lmstudio/models/lmstudio-community/Meta-Llama-3.1-8B-Instruct-GGUF/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf';


  // Use Cheerio to scrape content from webpage and create documents
  const loader = new CheerioWebBaseLoader(
    'https://js.langchain.com/docs/how_to/#langchain-expression-language-lcel',
  );
  const docs = await loader.load();

  // Text Splitter
  const splitter = new RecursiveCharacterTextSplitter({
    chunkSize: 100,
    chunkOverlap: 20,
  });
  const splitDocs = await splitter.splitDocuments(docs);

  const embeddings = await LlamaCppEmbeddings.initialize({
    modelPath: llamaPath,
  });

  // Create Vector Store
  return await MemoryVectorStore.fromDocuments(
    splitDocs,
    embeddings,
  );
};


// Create chain
const createChain = async (vectorStore) => {
  // create model
  const model = new ChatOpenAI({
    temperature: 0.7,
    openAIApiKey: 'lm-studio',
    configuration: {
      baseURL: 'http://localhost:1234/v1',
    },
  });
  const retrieverPrompt = ChatPromptTemplate.fromMessages([
    new MessagesPlaceholder('chat_history'),
    ['user', '{input}'],
    [
      'user',
      'Given the above conversation, generate a search query to look up in order to get information relevant to the conversation',
    ],
  ]);


  // Create a retriever from vector store
  const retriever = vectorStore.asRetriever({ k: 2 });

  // This chain will return a list of documents from the vector store
  const chain = await createHistoryAwareRetriever({
    llm: model,
    retriever,
    rephrasePrompt: retrieverPrompt,
  });

  // Create a retrieval chain
  return await createRetrievalChain({
    combineDocsChain: chain,
    retriever,
  });


};

const response = async () => {
  const vectorStore = await createVectorStore();
  const chain = await createChain(vectorStore);

  const chatHistory = [
    new HumanMessage('Hello'),
    new AIMessage('Hi, how can I help you?'), new HumanMessage('My name is Leon'), new AIMessage('Hi Leon, how can I help you?'), new HumanMessage('What is LCEL?'),
    new AIMessage('LCEL stands for Langchain Expression Language')];

  return await chain.invoke({
    input: 'What is LCEL?',
    chat_history: chatHistory,
  });
};

response().then(result => {
  console.log(result);
});



