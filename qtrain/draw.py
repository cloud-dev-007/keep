from graphviz import Digraph

# Create a more detailed diagram with system components and subprocesses
dot = Digraph(comment='LangChain + LLaMA Pipeline (Detailed)')

# Document Loading
dot.node('A1', 'Document Loader\n(PDF, DOCX, TXT, OCR)')
dot.node('A2', 'LangChain\nDocumentLoader API')

# Splitting
dot.node('B1', 'Text Chunking\n(RecursiveCharacterTextSplitter)')
dot.node('B2', 'Token-aware splitting\n(Ensure LLM compatibility)')

# Embedding
dot.node('C1', 'Transformer Encoder\n(BGE / MiniLM / SentenceTransformers)')
dot.node('C2', 'LangChain\nEmbeddings API')

# Vector Store
dot.node('D1', 'pgvector / FAISS\n(Vector Index)')
dot.node('D2', 'Store metadata\n(lectureId, page, topics)')

# Similarity Search
dot.node('E1', 'k-NN Search\n(Cosine Similarity)')
dot.node('E2', 'LangChain\nRetriever API')

# Prompt Construction
dot.node('F1', 'PromptTemplate\n(Inject context + task)')
dot.node('F2', 'Instructions\n(e.g., Bloom’s taxonomy, format rules)')

# LLM Inference
dot.node('G1', 'LLaMA 8B/13B\n(Decoder-only Transformer)')
dot.node('G2', 'Tokenization → Attention → Sampling')

# Output Parsing
dot.node('H1', 'Raw Output')
dot.node('H2', 'LangChain Output Parsers\n(JSON, List, Regex)')

# Connect nodes by stages
dot.edge('A1', 'A2')
dot.edge('A2', 'B1')
dot.edge('B1', 'B2')
dot.edge('B2', 'C1')
dot.edge('C1', 'C2')
dot.edge('C2', 'D1')
dot.edge('D1', 'D2')
dot.edge('D2', 'E1')
dot.edge('E1', 'E2')
dot.edge('E2', 'F1')
dot.edge('F1', 'F2')
dot.edge('F2', 'G1')
dot.edge('G1', 'G2')
dot.edge('G2', 'H1')
dot.edge('H1', 'H2')

# Save the source for conversion
drawio_detailed_xml = dot.source.replace('digraph', 'graph')  # draw.io expects <graph>

# Save to file
drawio_detailed_path = "architecture.xml"
with open(drawio_detailed_path, "w") as f:
    f.write(drawio_detailed_xml)

drawio_detailed_path
