import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/providers/auth_provider.dart';
import 'package:flutter_frontend/providers/navigation_provider.dart';
import 'package:flutter_frontend/screens/home/home_screen.dart';
import 'package:flutter_frontend/widgets/navbar.dart';

void main() {
  testWidgets('landing page navbar scrolls to its section', (tester) async {
    _setViewport(tester, const Size(1200, 900));
    await tester.pumpWidget(_buildHomeScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('About').first);
    await tester.pumpAndSettle();

    final headingTop = tester.getTopLeft(find.text('ABOUT US')).dy;
    expect(headingTop, greaterThan(72));
    expect(headingTop, lessThan(900));
  });

  testWidgets('desktop section links call their matching scroll targets', (
    tester,
  ) async {
    final selectedSections = <String>[];
    _setViewport(tester, const Size(1200, 800));
    await tester.pumpWidget(
      _buildNavbar(onScrollToSection: selectedSections.add),
    );

    await tester.tap(find.text('About'));
    await tester.pump();
    await tester.tap(find.text('Features'));
    await tester.pump();
    await tester.tap(find.text('Contact'));

    expect(selectedSections, ['about', 'features', 'contact']);
  });

  testWidgets('mobile section menu closes after selection', (tester) async {
    String? selectedSection;
    _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      _buildNavbar(onScrollToSection: (section) => selectedSection = section),
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('About'), findsOneWidget);

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(selectedSection, 'about');
    expect(find.text('About'), findsNothing);
  });
}

Widget _buildNavbar({required ValueChanged<String> onScrollToSection}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: MaterialApp(
      home: Scaffold(body: Navbar(onScrollToSection: onScrollToSection)),
    ),
  );
}

Widget _buildHomeScreen() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: const MaterialApp(home: Scaffold(body: HomeScreen())),
  );
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
}
