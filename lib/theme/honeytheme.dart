import 'package:flutter/material.dart';

final ThemeData honeyTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFFFC107), // dourado/mel
  scaffoldBackgroundColor: const Color(0xFFFFECB3), // fundo bege claro0xFFFFF8E1
  cardColor: const Color(0xFFFFF8E1), // cor de cartões 0xFFFFECB3
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFFFECB3),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    /*focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.orange),
      borderRadius: BorderRadius.circular(12),
    ),*/
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFC107),
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFFB300),
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFB300),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF6D4C41), // marrom suave
  ),
);
