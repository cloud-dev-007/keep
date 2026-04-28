# qEngine
## The AI-Powered Backend for qCraft

qEngine is the **backend service for qCraft**, responsible for **extracting text, generating quiz questions, evaluating user responses, and adapting quizzes based on weaknesses**. It leverages **machine learning** and **NLP models** to provide an intelligent and dynamic quiz experience.

## Features

- ✅ Extracts text from **PDF, PPTX, and scanned documents (OCR with Tesseract)**
- ✅ Generates **multiple-choice and open-ended quiz questions**
- ✅ Uses **AI-powered evaluation** to assess user responses
- ✅ Dynamically adapts quiz difficulty based on user performance
- ✅ Fast and efficient API with **FastAPI**

## Tech Stack

* **Language:** Python
* **Framework:** FastAPI
* **ML Models:** Hugging Face Transformers (T5, BERT), Sentence-BERT (SBERT)
* **OCR:** Tesseract
* **Database:** PostgreSQL/Firebase (TBD)

## Getting Started

### Setting Up the Project

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/qEngine.git
   cd qEngine
   ```

2. Create a virtual environment:
   ```
   python -m venv venv  
   source venv/bin/activate  # On Windows: venv\Scripts\activate  
   ```

3. Install dependencies:
   ```
   pip install -r requirements.txt  
   ```

### Running the API

1. Start the FastAPI server:
   ```
   uvicorn main:app --reload
   ```

2. Open the interactive API docs at:
   * Swagger UI: `http://127.0.0.1:8000/docs`
   * ReDoc: `http://127.0.0.1:8000/redoc`

## Contributing

Contributions are welcome! Fork the repo and submit a PR.

## License

This project is licensed under the MIT License.
