import 'package:flutter_test/flutter_test.dart';
import 'package:me_leva_noronha_app/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MeLevaNoronhaApp());
    expect(find.text('Me Leva Noronha'), findsWidgets);
  });
}
