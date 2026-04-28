export class PromptTemplates {
  static readonly extractTopics = `
You are an expert content analyzer. Extract only 5 high-level topics from this document chunk.

**GUIDELINES:**
- Identify 3-7 broad conceptual areas based on content density and complexity
- Focus on overarching themes, not granular details or specific examples  
- Capture distinct subject domains that would help categorize this content
- Use concise, descriptive phrases that reflect the core concepts
- Prioritize topics that represent substantial portions of the text

**OUTPUT FORMAT:**
- Lowercase phrases separated by commas
- No articles (a, an, the) unless essential for clarity
- 2-5 words per topic maximum
- Most important topics first

**TEXT:**
{text}

**STRUCTURE GUIDANCE:** {instructions}

You must respond with ONLY the requested content. No explanations, no additional text, no formatting unless explicitly specified.

If formatting guidelines are provided, follow them exactly. If no formatting is specified, respond with plain text only - no markdown, no bullets, no bold text, no styling.
**TOPICS:**
`;

  //TODO: add prompt here
  static readonly generateAdaptiveQuestions = `
    
  `;


  static readonly evaluateAnswer = `
  You are an evaluator. Given a quiz question, the correct answer, and a user's attempt, determine if the user's answer is correct.

  Question: {question}
  Correct Answer: {answer}
  User's Attempt: {attempt}
  
  Respond with only "true" or "false".`;

  static readonly extractWeakTopics = `
  Given the following list of incorrectly answered quiz questions, extract the ONLY 5 extremely specific sub topic each question is testing. Respond with a comma-separated list of topics, avoiding vague categories.

  context:
  {context}

  Questions:
  {questions}
  
  Comma-separated topics:`;

  static readonly generateAnalysis = `
You are a supportive educational coach providing personalized feedback after reviewing a student's quiz performance. Write a concise, 4-sentence analysis that focuses on growth, encouragement, and actionable next steps.

Performance Context:
- Accuracy: {accuracy}%
- Areas needing attention: {topics}
- Difficulty Level: {difficulty}/10

Guidelines:
- Speak directly to the student in first person ("I noticed..." "You show..." "I recommend...")
- Do not repeat or summarize the stats directly
- Focus on what their performance reveals about their understanding and learning habits
- Offer clear, specific advice for how they can improve in the identified weak areas
- Acknowledge effort and encourage progress, even if the results are below expectations
- Be constructive, realistic, and motivational — like a mentor who sees their potential

Write as if you're having a one-on-one conversation with the student after reviewing their work. Avoid generic phrases and deliver insightful, actionable feedback that supports their learning journey. Respond with only the analysis.`;
  static readonly generateAnswer = `
 Generate a CLEAR & SIMPLE answer for the question below:
- Think through the question based strictly on the context.
- Answer with exactly one sentence/phrase.

Question:
{question}

Context:
{context}

  You must respond with ONLY the answer of the question. No explanations, no additional text.

**ANSWER:**
  `;

  static readonly generateDistractors = `
Generate 3 Multiple Choice distractors for the question below:
- Use the answer of the question below as a to better structure the distractors.
- Think through the question based strictly on the context.
- Keep it short and direct.
- Return each distractor numbered.
- The distractors must be:
  • Plausible, but clearly incorrect.
  • Topically related, but distinct from the correct answer.
  - Distractors must be exactly one sentence/phrase, depending on the answer
  - Not duplicates or variations of the correct answer. 

Question:
{question}

Answer:
{answer}

Context:
{context}

**DISTRACTORS:**

You must respond with ONLY the requested distractors. No explanations, no additional text before the distractors.
respond with plain text only - no markdown, no bullets, no bold text, no styling.
  `;


  static readonly extractTitle = `
You are an expert content curator. Generate a precise, informative title for this text below.

**REQUIREMENTS:**
- 4-12 words that capture the core subject matter
- Professional yet accessible tone
- Specific enough to distinguish from similar content
- Include key domain/field if relevant (e.g., "Data Analysis," "Marketing Strategy")
- Avoid generic words like "Overview," "Introduction," "Guide"

**OPTIMIZATION:**
- Lead with the most important concept
- Use active language when possible
- Include quantitative elements if they're central (dates, numbers, percentages)
- Balance specificity with broad appeal

**TEXT:**
{text}

  You must respond with ONLY the requested content. No explanations, no additional text, no formatting unless explicitly specified.
 respond with plain text only - no markdown, no bullets, no bold text, no styling, no quotations.
**TITLE:**
`;
  static readonly extractDescription = `
You are an expert content curator. Create a simple 1-3 sentence description of the text below. Write in plain text with no formatting, line breaks, or special characters.
Keep it short, keep it simple. Just write about the main subject matter and its context. Write in a descriptive form, no headings. no formatting

TEXT:
{text}

 respond with plain text only - no markdown, no bullets, no bold text, no styling. ensure your response does not exceed 3 sentences and does not include any (backword/n) in it
DESCRIPTION:
`;
  static readonly extractSummary = `
You are an expert text summarizer. Create a comprehensive summary preserving critical information from the provided text chunk.

**KEY REQUIREMENTS:**
- Retain all facts, figures, dates, names, and specific details
- Preserve technical terms, definitions, and quantitative data
- Lead with most important concepts and conclusions
- Maintain logical flow and cause-effect relationships
- Target 30-40% of original length while capturing 90%+ of meaningful content
- Eliminate redundancy and verbose explanations
- Ensure summary stands alone and maintains original tone/intent
- Prioritize actionable information over abstract generalizations

**TEXT:**
{text}

You must respond with ONLY the requested content. No explanations, no additional text, no formatting unless explicitly specified.

If formatting guidelines are provided, follow them exactly. If no formatting is specified, respond with plain text only - no markdown, no bullets, no bold text, no styling.
**SUMMARY:**
`;
  static readonly generateQuestions = `
  Generate EXACTLY {questions} quiz questions based off the following context:
  
  {context}
  
  Based on Bloom's Taxonomy ({level}), 
  use these instructions to structure the questions:
  {structure}

  You must respond with ONLY the requested question. No explanations, no additional text before the questions.
  return each question on a new line - no markdown, no bullets, no bold text, no styling.
  `;
}