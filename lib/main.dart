import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/auth/login_page.dart';
import 'features/movies/movies_list_page.dart';
import 'services/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  await themeController.load();

  runApp(const CubosVideoApp());
}

class CubosVideoApp extends StatelessWidget {
  const CubosVideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Cubos Video',
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00b9ff),
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.montserratTextTheme(),
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00b9ff),
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.montserratTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            ),
            useMaterial3: true,
          ),

          themeMode: themeController.themeMode,

          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final user = snapshot.data;

              if (user == null) {
                return const LoginPage();
              } else {
                return const MoviesListPage();
              }
            },
          ),
        );
      },
    );
  }
}
