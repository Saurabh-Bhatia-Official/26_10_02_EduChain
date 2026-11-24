import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/providers/auth_provider.dart';
import 'package:flutter_frontend/providers/navigation_provider.dart';
import 'package:flutter_frontend/screens/student/student_portal_screen.dart';

Future<void> _pumpStudentPortal(
  WidgetTester tester, {
  required String tab,
  required double width,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(home: StudentPortalScreen(initialTab: tab)),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets(
    'dashboard panels render without layout exceptions at all widths',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      for (final width in [360.0, 600.0, 1280.0]) {
        await _pumpStudentPortal(tester, tab: 'dashboard', width: width);
        expect(find.text("Today's Lectures"), findsOneWidget);
        expect(find.text('Quick Access'), findsOneWidget);
        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason:
              'Unexpected widget exception at viewport width $width: $exception',
        );
      }
    },
  );

  testWidgets(
    'weekly timetable renders all weekdays on narrow and wide layouts',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      for (final width in [320.0, 700.0, 1280.0]) {
        await _pumpStudentPortal(tester, tab: 'timetable', width: width);
        expect(find.text('Weekly timetable'), findsOneWidget);
        expect(find.text('Monday'), findsOneWidget);
        expect(find.text('Friday'), findsOneWidget);
        expect(find.text('Faculty Mentoring'), findsOneWidget);
        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason:
              'Unexpected widget exception at viewport width $width: $exception',
        );
      }
    },
  );
}
