import 'package:discount_scanner/manual_price_entry_screen.dart';
import 'package:discount_scanner/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('manual entry screen renders core controls', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MaterialApp(home: ManualPriceEntryScreen()),
      ),
    );

    expect(find.text('Manual Calculation'), findsOneWidget);
    expect(find.text('Original Price'), findsOneWidget);
    expect(find.text('Select Discount:'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
  });
}
