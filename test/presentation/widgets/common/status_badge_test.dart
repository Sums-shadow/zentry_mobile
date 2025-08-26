import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zentry/core/theme/app_theme.dart';
import 'package:zentry/presentation/widgets/common/status_badge.dart';

void main() {
  group('StatusBadge Widget Tests', () {
    testWidgets('displays correct text for actif status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: StatusBadge(status: 'actif'),
          ),
        ),
      );

      expect(find.text('Actif'), findsOneWidget);
    });

    testWidgets('displays correct color for bon_etat status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: StatusBadge(status: 'bon_etat'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppTheme.successColor.withOpacity(0.1));
    });

    testWidgets('displays correct text for mauvais_etat status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: StatusBadge(status: 'mauvais_etat'),
          ),
        ),
      );

      expect(find.text('Mauvais état'), findsOneWidget);
    });

    testWidgets('handles unknown status gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: StatusBadge(status: 'unknown_status'),
          ),
        ),
      );

      expect(find.text('UNKNOWN STATUS'), findsOneWidget);
    });

    testWidgets('applies large style when isLarge is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: StatusBadge(
              status: 'actif',
              isLarge: true,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(Text),
        ),
      );

      expect(textWidget.style?.fontSize, 14);
    });
  });

  group('StatusBadgeWhite Widget Tests', () {
    testWidgets('displays white text and transparent background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: StatusBadgeWhite(status: 'actif'),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(
        find.descendant(
          of: find.byType(StatusBadgeWhite),
          matching: find.byType(Text),
        ),
      );

      expect(textWidget.style?.color, Colors.white);
      expect(find.text('ACTIF'), findsOneWidget);
    });
  });

  group('StatusColors Extension Tests', () {
    test('returns correct color for actif status', () {
      final color = StatusColors.forStatus('actif');
      expect(color, AppTheme.successColor);
    });

    test('returns correct color for etat_moyen status', () {
      final color = StatusColors.forStatus('etat_moyen');
      expect(color, AppTheme.warningColor);
    });

    test('returns correct color for mauvais_etat status', () {
      final color = StatusColors.forStatus('mauvais_etat');
      expect(color, AppTheme.errorColor);
    });

    test('returns grey for unknown status', () {
      final color = StatusColors.forStatus('unknown');
      expect(color, Colors.grey);
    });

    test('handles case insensitive status', () {
      final color1 = StatusColors.forStatus('ACTIF');
      final color2 = StatusColors.forStatus('actif');
      expect(color1, color2);
    });
  });
} 