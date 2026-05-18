import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/home/ui/widgets/category_popup.dart';

void main() {
  testWidgets(
    'category popup uses german dark-neon labels without power button',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    showCategoryPopup(
                      context: context,
                      onRefreshMyWords: () async {},
                      onTodo: (_) {},
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Kategorie'), findsOneWidget);
      expect(find.text('Alle Wörter'), findsOneWidget);
      expect(find.text('Meine Wörter'), findsOneWidget);
      expect(find.text('Favoriten'), findsOneWidget);
      expect(find.text('Wörter, die ich kenne'), findsOneWidget);
      expect(find.text('Wortwelten'), findsOneWidget);
    expect(find.text('Mix erstellen'), findsOneWidget);

      expect(find.text('Category'), findsNothing);
      expect(find.text('All words'), findsNothing);
      expect(find.text('My words'), findsNothing);
      expect(find.text('Favorites'), findsNothing);
      expect(find.text('Words I know'), findsNothing);
    expect(find.text('Word hub'), findsNothing);
    expect(find.text('Make your own mix'), findsNothing);
    expect(find.text('Eigenen Mix erstellen'), findsNothing);
      expect(find.byIcon(Icons.power_settings_new_rounded), findsNothing);
    },
  );
}
