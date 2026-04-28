# qCraft

## The Adaptive Quiz App

qCraft is a **text-based quiz generator** that extracts content from **PDFs, PPTX files, and scanned documents** to generate quiz questions. It evaluates user responses and dynamically generates new quizzes based on areas of weakness, ensuring **adaptive learning**.

## Features

- ✅ Extracts text from **PDF, PPTX, and scanned documents (OCR)**
- ✅ Generates **multiple-choice and open-ended questions**
- ✅ Evaluates user answers using **AI-driven semantic matching**
- ✅ Adapts quizzes based on user performance
- ✅ Works **offline**, with no reliance on OpenAI API

## Project Structure

This project is divided into two repositories:

1. **qEngine** – Backend (Python + Machine Learning)
2. **qCraft** – Mobile App (Flutter)

## Getting Started

### Setting Up the Backend (qEngine)

1. Clone the repository:
   ```
   git clone https://github.com/Lukas-io/qEngine.git
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

### Setting Up the Mobile App (qCraft)

1. Clone the repository:
   ```
   git clone https://github.com/Lukas-io/qCraft.git
   cd qCraft
   ```

2. Install Flutter dependencies:
   ```
   flutter pub get
   ```

3. Run the app:
   ```
   flutter run
   ```

## Tech Stack

* **Backend:** Python, FastAPI, Hugging Face Transformers, Tesseract OCR
* **Mobile:** Flutter, Dart, GetIt (DI), BLoC (State Management)
* **Database:** Firebase/PostgreSQL (TBD)

## Contributing

Contributions are welcome! Fork the repo and submit a PR.

## License

This project is licensed under the MIT License.