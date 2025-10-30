import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/main_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase safely
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Catch any initialization errors
    debugPrint("❌ Firebase initialization failed: $e");
  }

  runApp(const HajjaamApp());
}

// Route observer for screens that need to react when coming back into focus
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class HajjaamApp extends StatelessWidget {
  const HajjaamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hajjaam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorObservers: [routeObserver],
      home: const AuthWrapper(),
      routes: {
        '/booking': (context) => const BookingScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while connecting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is logged in → go to main screen
        if (snapshot.hasData) {
          return const MainScreen();
        }

        // If not logged in → show login screen
        return const LoginScreen();
      },
    );
  }
}
