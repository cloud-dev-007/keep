// Basic smoke test — the leftover counter-template test was deleted.
// The real qCraft app talks to a live backend, so meaningful widget tests
// would need mock HTTP. Keeping this minimal until that's added.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qcraft_app/main.dart';

void main() {
  testWidgets('App boots without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const QCraftApp());
    // We expect at least one Scaffold to be mounted on the home screen.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
