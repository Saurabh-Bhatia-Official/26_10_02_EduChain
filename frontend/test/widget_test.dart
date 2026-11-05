import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/main.dart';

void main() {
  testWidgets('EduChainApp smoke and home page test', (WidgetTester tester) async {
    // Set desktop screen size for widget test
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const EduChainApp());
    await tester.pumpAndSettle();

    expect(find.text('Institute Portal'), findsWidgets);
    expect(find.text('INSTITUTE Login'), findsWidgets);
    expect(find.text('INSTITUTE Register'), findsWidgets);
    expect(find.text('Everything You Need in One Portal'), findsOneWidget);
  });
}
