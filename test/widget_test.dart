// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskora/views/login/login_view.dart';
import 'package:taskora/views/splash/splash_view.dart';

void main() {
  testWidgets('login screen lays out without unbounded flex errors', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(502, 558);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TaskoraLoginView()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('splash screen shows the Taskora logo', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TaskoraSplashView()));

    expect(find.byKey(const ValueKey('taskora_splash_logo')), findsOneWidget);
    expect(find.byKey(const ValueKey('taskora_title_letter_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('taskora_title_letter_6')), findsOneWidget);
  });

  testWidgets('subtitle stays below the logo', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TaskoraSplashView()));
    await tester.pump(const Duration(milliseconds: 3200));

    final logoBounds = tester.getRect(
      find.byKey(const ValueKey('taskora_splash_logo')),
    );
    final subtitleBounds = tester.getRect(
      find.byKey(const ValueKey('taskora_splash_subtitle')),
    );

    expect(logoBounds.bottom, lessThanOrEqualTo(subtitleBounds.top));
  });
}
