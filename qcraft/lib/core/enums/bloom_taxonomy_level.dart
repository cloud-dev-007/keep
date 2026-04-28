import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum BloomTaxonomyLevel {
  remembering('remembering'),
  understanding('understanding'),
  applying('applying'),
  analyzing('analyzing'),
  evaluating('evaluating'),
  creating('creating');

  final String value;

  const BloomTaxonomyLevel(this.value);
}

String getDifficultyLabel(num value) {
  if (value <= 3) {
    return 'Easy';
  } else if (value <= 7) {
    return 'Medium';
  } else {
    return 'Hard';
  }
}

BloomTaxonomyLevel getBloomLevel(num difficulty) {
  if (difficulty <= 2.0) return BloomTaxonomyLevel.remembering;
  if (difficulty <= 4.0) return BloomTaxonomyLevel.understanding;
  if (difficulty <= 6.0) return BloomTaxonomyLevel.applying;
  if (difficulty <= 8.0) return BloomTaxonomyLevel.analyzing;
  return BloomTaxonomyLevel.evaluating;
}

String getBloomDescription(BloomTaxonomyLevel level) {
  switch (level) {
    case BloomTaxonomyLevel.remembering:
      return 'Recalling or remembering facts and information.';
    case BloomTaxonomyLevel.understanding:
      return 'Understanding and interpreting ideas, concepts, and information.';
    case BloomTaxonomyLevel.applying:
      return 'Applying knowledge to solve problems or complete tasks.';
    case BloomTaxonomyLevel.analyzing:
      return 'Analyzing data and information to identify patterns, relationships, and conclusions.';
    case BloomTaxonomyLevel.evaluating:
      return 'Evaluating the value and relevance of ideas, concepts, and information.';
    case BloomTaxonomyLevel.creating:
      return 'Creating new products or solutions through applying knowledge and skills.';
  }
}

IconData getBloomCupertinoIcon(BloomTaxonomyLevel level) {
  switch (level) {
    case BloomTaxonomyLevel.remembering:
      return CupertinoIcons.book;
    case BloomTaxonomyLevel.understanding:
      return CupertinoIcons.doc_text_search;
    case BloomTaxonomyLevel.applying:
      return CupertinoIcons.wrench;
    case BloomTaxonomyLevel.analyzing:
      return CupertinoIcons.search;
    case BloomTaxonomyLevel.evaluating:
      return CupertinoIcons.check_mark_circled;
    case BloomTaxonomyLevel.creating:
      return CupertinoIcons.pencil;
  }
}

Color getBloomColor(BloomTaxonomyLevel level) {
  switch (level) {
    case BloomTaxonomyLevel.remembering:
      return Colors.blue.shade200;
    case BloomTaxonomyLevel.understanding:
      return Colors.green.shade300;
    case BloomTaxonomyLevel.applying:
      return Colors.orange.shade300;
    case BloomTaxonomyLevel.analyzing:
      return Colors.purple.shade300;
    case BloomTaxonomyLevel.evaluating:
      return Colors.red.shade300;
    case BloomTaxonomyLevel.creating:
      return Colors.teal.shade300;
  }
}
