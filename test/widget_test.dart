import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elearning_app/main.dart';

void main() {
  testWidgets('App builds and shows the course list title', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ElearningApp()));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Daftar Course'), findsOneWidget);
  });
}