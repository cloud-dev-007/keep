class ApiEndpoints {
  // Compile-time configurable base URL. Override at build time, e.g.:
  //   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/
  //   flutter build apk --dart-define=API_BASE_URL=https://qcraft.example.com/
  //
  // Defaults to localhost so dev "just works" against `npm run start:dev`.
  // NB: the URL must end with a trailing slash to compose correctly with
  // the path constants below.
  static const baseApiUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/',
  );

  //-------------------- DOCUMENTS --------------------//
  static const uploadDocument = 'document/upload';
  static const document = 'document';

  //-------------------- QUIZ --------------------//
  static const quiz = 'quiz';
  static const createQuiz = 'quiz/create';
  static const generateQuiz = 'quiz/generate/{id}';
  static const evaluateQuiz = 'quiz/evaluate';
}
