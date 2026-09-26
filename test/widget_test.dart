// Smoke test for the AI discussion community app's main screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_community/main.dart';

void main() {
  testWidgets('Main screen renders boards, best posts and navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const AiCommunityApp());

    // Let the initial FutureBuilders (mock data, resolved immediately) settle.
    await tester.pumpAndSettle();

    // App bar and above-the-fold content (best posts section).
    expect(find.text('AI 토론 커뮤니티'), findsOneWidget);
    expect(find.text('오늘의 베스트글'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.groups_outlined), findsOneWidget);

    // Scroll down to reach the per-board latest-posts section (with tabs),
    // which sits below the fold in the default test viewport.
    await tester.scrollUntilVisible(
      find.text('게시판별 최신글'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('게시판별 최신글'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
  });
}
