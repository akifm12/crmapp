import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bluearrow_app/app.dart';

void main() {
  testWidgets('App builds and shows the bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BlueArrowApp()));
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
  });
}
