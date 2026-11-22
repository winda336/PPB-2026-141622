import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF1E5AA8);
  static const hilang = Color(0xFFD9534F);
  static const ditemukan = Color(0xFF2E8B57);
  static const selesai = Color(0xFF6C757D);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(centerTitle: false),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      );
}
