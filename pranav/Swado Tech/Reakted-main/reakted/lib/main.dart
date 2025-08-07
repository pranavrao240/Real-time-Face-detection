import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'homepage.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reakted',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Satoshi',
        canvasColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          surfaceTintColor: Colors.white,
        ),
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),

        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Satoshi'),
          displayMedium: TextStyle(fontFamily: 'Satoshi'),
          displaySmall: TextStyle(fontFamily: 'Satoshi'),
          headlineLarge: TextStyle(fontFamily: 'Satoshi'),
          headlineMedium: TextStyle(fontFamily: 'Satoshi'),
          headlineSmall: TextStyle(fontFamily: 'Satoshi'),
          titleLarge: TextStyle(fontFamily: 'Satoshi'),
          titleMedium: TextStyle(fontFamily: 'Satoshi'),
          titleSmall: TextStyle(fontFamily: 'Satoshi'),
          bodyLarge: TextStyle(fontFamily: 'Satoshi'),
          bodyMedium: TextStyle(fontFamily: 'Satoshi'),
          bodySmall: TextStyle(fontFamily: 'Satoshi'),
          labelLarge: TextStyle(fontFamily: 'Satoshi'),
          labelMedium: TextStyle(fontFamily: 'Satoshi'),
          labelSmall: TextStyle(fontFamily: 'Satoshi'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,

            textStyle: TextStyle(
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
      ),

      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
