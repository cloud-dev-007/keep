export enum BloomTaxonomyLevel {
  REMEMBERING = 'remembering',
  UNDERSTANDING = 'understanding',
  APPLYING = 'applying',
  ANALYZING = 'analyzing',
  EVALUATING = 'evaluating',
  CREATING = 'creating', // Optional if you’re not using level 6
}

export const BloomTaxonomyInstructions: Record<BloomTaxonomyLevel, string> = {
  [BloomTaxonomyLevel.REMEMBERING]:
    'Create simple recall-based questions. Ask for definitions, facts, terms, or basic concepts.' +
    ' Example: "What is...?", "When did...?"',

  [BloomTaxonomyLevel.UNDERSTANDING]:
    'Create questions that check comprehension. Ask to explain, summarize, or interpret. Example: ' +
    '"Explain why...", "Summarize the purpose of..."',

  [BloomTaxonomyLevel.APPLYING]:
    'Create questions that ask how knowledge is used in real scenarios. Focus on application of concepts. ' +
    'Example: "How would you use...?", "What would happen if...?"',

  [BloomTaxonomyLevel.ANALYZING]:
    'Create questions that involve breaking down information, identifying causes, making inferences.' +
    ' Example: "What are the components of...?", "Why did... happen?"',

  [BloomTaxonomyLevel.EVALUATING]:
    'Create questions that require judgment or justification of a decision.' +
    ' Example: "Do you agree with...?", "Which is more effective and why?"',

  [BloomTaxonomyLevel.CREATING]:
    'Create open-ended questions requiring generation of new ideas or proposals.' +
    ' Example: "Design a solution for...", "What would you create to solve...?"',
};

export function getBloomLevel(difficulty: number): BloomTaxonomyLevel {
  if (difficulty <= 2) return BloomTaxonomyLevel.REMEMBERING;
  if (difficulty <= 4) return BloomTaxonomyLevel.UNDERSTANDING;
  if (difficulty <= 6) return BloomTaxonomyLevel.APPLYING;
  if (difficulty <= 8) return BloomTaxonomyLevel.ANALYZING;
  return BloomTaxonomyLevel.EVALUATING;
}

export function getLevelInstructions(difficulty: number): string {
  const level = getBloomLevel(difficulty);
  return BloomTaxonomyInstructions[level];
}