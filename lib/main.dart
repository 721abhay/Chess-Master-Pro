import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'engine/chess_engine.dart';
import 'engine/auth_engine.dart';
import 'engine/theme_engine.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChessEngine()),
        ChangeNotifierProvider(create: (_) => AuthEngine()),
        ChangeNotifierProvider(create: (_) => ThemeEngine()),
      ],
      child: Consumer<ThemeEngine>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Chess Master Pro',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0A0A0E),
              textTheme: GoogleFonts.outfitTextTheme(
                ThemeData.dark().textTheme,
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: theme.primaryColor,
                brightness: Brightness.dark,
                primary: theme.primaryColor,
                secondary: const Color(0xFF8B5CF6),
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
