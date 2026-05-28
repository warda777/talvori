import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/ui/talvori_snackbar.dart';

void main() {
  testWidgets('TalvoriSnackBar shows a floating dark-neon snackbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () => TalvoriSnackBar.show(
                  context,
                  message: 'Gespeichert',
                  type: TalvoriSnackBarType.success,
                ),
                child: const Text('Show'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();

    expect(find.text('Gespeichert'), findsOneWidget);

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.behavior, SnackBarBehavior.floating);
    expect(snackBar.backgroundColor, TalvoriSnackBar.surface);
    expect(snackBar.elevation, 0);
  });
}
