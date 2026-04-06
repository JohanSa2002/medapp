// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:medapp/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/single_child_widget.dart';
import 'package:medapp/firebase_options.dart';
import 'package:medapp/main.dart';

// Fake services for tests
class _FakeAuthService implements AuthService {
  // implement minimal interface
  @override
  Stream<User?> get authStateChanges async* {
    yield null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotificationProvider extends ChangeNotifier {}

/// Test-only simple counter widget to avoid initializing app-level services.
class _CounterTestApp extends StatefulWidget {
  const _CounterTestApp({Key? key}) : super(key: key);
  @override
  State<_CounterTestApp> createState() => _CounterTestAppState();
}

class _CounterTestAppState extends State<_CounterTestApp> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('$_count', textDirection: TextDirection.ltr)),
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() => _count++),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Initialize Firebase with test options and inject fake providers into MyApp
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    final providers = <SingleChildWidget>[
      Provider<AuthService>(create: (_) => _FakeAuthService()),
      ChangeNotifierProvider(create: (_) => _FakeNotificationProvider()),
    ];

    await tester.pumpWidget(MyApp(providers: providers));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
