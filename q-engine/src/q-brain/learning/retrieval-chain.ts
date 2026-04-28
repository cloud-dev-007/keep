import { ChatOpenAI } from '@langchain/openai';

import { createStuffDocumentsChain } from 'langchain/chains/combine_documents';
import { ChatPromptTemplate } from '@langchain/core/prompts';

import { CheerioWebBaseLoader } from '@langchain/community/document_loaders/web/cheerio';
import { RecursiveCharacterTextSplitter } from 'langchain/text_splitter';

import { LlamaCppEmbeddings } from '@langchain/community/embeddings/llama_cpp';

import { MemoryVectorStore } from 'langchain/vectorstores/memory';
import { createRetrievalChain } from 'langchain/chains/retrieval';


const llamaPath = '/Users/lukasio/.lmstudio/models/lmstudio-community/Meta-Llama-3.1-8B-Instruct-GGUF/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf';


// create model
const model = new ChatOpenAI({
  temperature: 0.7,
  openAIApiKey: 'lm-studio',
  configuration: {
    baseURL: 'http://localhost:1234/v1',
  },
});

async function callDocumentSplitter() {
  // Create prompt
  const prompt = ChatPromptTemplate.fromTemplate(
    `Answer the user's question from the following context: 
  {context}
  Question: {input}`,
  );

  // Create Chain
  const chain = await createStuffDocumentsChain({
    llm: model,
    prompt,
  });


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
  const vectorStore = await MemoryVectorStore.fromDocuments(
    splitDocs,
    embeddings,
  );

  // Create a retriever from vector store
  const retriever = vectorStore.asRetriever({ k: 2 });

  // Create a retrieval chain
  const retrievalChain = await createRetrievalChain({
    combineDocsChain: chain,
    retriever,
  });

  return await retrievalChain.invoke({
    input: 'What is LCEL?',
  });
}


callDocumentSplitter().then(
  (response) => console.log(response),
);

