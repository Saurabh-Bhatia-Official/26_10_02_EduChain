import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_frontend/features/classroom/providers/classroom_provider.dart';
import 'package:flutter_frontend/features/classroom/screens/classroom_hub_screen.dart';

void main() {
  testWidgets('EduChainApp smoke and home page test', (
    WidgetTester tester,
  ) async {
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

  testWidgets(
    'Classroom hub applies student, teacher and admin entry permissions',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final provider = ClassroomProvider();
      while (!provider.isLoaded) {
        await tester.pump();
      }
      final classroom = provider.create(
        name: 'RBAC fixture',
        subject: 'Computer Science',
        section: 'A',
        description: '',
        teacherId: 'teacher-1',
        teacherName: 'Teacher',
      );
      provider.join(classroom.code, 'student-1');

      Future<void> showRole(String role, String userId) async {
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: provider,
            child: MaterialApp(
              home: Scaffold(
                body: ClassroomHubScreen(
                  userRole: role,
                  userId: userId,
                  userName: userId,
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      await showRole('student', 'student-1');
      expect(find.text('Join with Code'), findsOneWidget);
      expect(find.text('Create Classroom'), findsNothing);

      await showRole('teacher', 'teacher-1');
      expect(find.text('Teacher Classrooms'), findsOneWidget);
      expect(find.text('Create Classroom'), findsOneWidget);

      await showRole('admin', 'admin-1');
      expect(find.text('Classroom Oversight & LMS'), findsOneWidget);
      expect(find.text('Create Classroom'), findsOneWidget);
    },
  );

  testWidgets('Classroom overview and detail tabs render at phone width for every role', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({});
    final provider = ClassroomProvider();
    while (!provider.isLoaded) {
      await tester.pump();
    }
    final classroom = provider.create(
      name: 'Responsive classroom',
      subject: 'Computer Science',
      section: 'A',
      description: 'Phone-sized layout smoke check',
      teacherId: 'teacher-1',
      teacherName: 'Teacher',
      studentIds: ['student-1'],
    );

    for (final entry in const [
      ('teacher', 'teacher-1'),
      ('student', 'student-1'),
      ('admin', 'admin-1'),
    ]) {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: ClassroomHubScreen(
                userRole: entry.$1,
                userId: entry.$2,
                userName: entry.$2,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Responsive classroom').first);
      await tester.pumpAndSettle();
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Recently Viewed'), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });
}
