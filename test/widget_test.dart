import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ecoloop/main.dart';
import 'package:ecoloop/state/store.dart';

void main() {
  testWidgets('app builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: Store(),
        child: const EcoLoopApp(),
      ),
    );
    expect(find.byType(EcoLoopApp), findsOneWidget);
  });
}
