import 'package:flutter_test/flutter_test.dart';

import 'package:os_sandbox/main.dart';

void main() {
  testWidgets('OS Sandbox app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const OSSandboxApp());

    expect(find.text('Operating System Simulator'), findsOneWidget);
    expect(find.text('CPU Scheduling'), findsWidgets);
  });
}