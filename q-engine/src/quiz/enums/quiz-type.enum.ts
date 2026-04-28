export enum QuizType {
  MCQ = 'MCQ',
  FillInTheBlank = 'FillInTheBlank',
  TrueFalse = 'TrueFalse',
  Theory = 'Theory',
  Any = 'Any',
}

export function shuffleArray<T>(array: T[]): T[] {
  const shuffled = [...array];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
}