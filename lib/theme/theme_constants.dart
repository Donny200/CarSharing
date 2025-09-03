import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: Colors.blueGrey[700],
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: Colors.black,
  ),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(
    secondary: Colors.teal,
    background: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      textStyle: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
      elevation: 8,
      shadowColor: Colors.teal.withOpacity(0.5),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.grey[200],
    labelStyle: GoogleFonts.roboto(color: Colors.blueGrey[700]),
    prefixIconColor: Colors.teal,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.teal, width: 2),
    ),
  ),
  textTheme: GoogleFonts.robotoTextTheme().copyWith(
    headlineMedium: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
    titleLarge: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blueGrey[800]),
    bodyLarge: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 6,
    shadowColor: Colors.grey.withOpacity(0.3),
    color: Colors.white,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.teal,
    elevation: 6,
    extendedPadding: EdgeInsets.symmetric(horizontal: 20),
  ),
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: Colors.blueGrey[900],
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: Colors.white,
  ),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey, brightness: Brightness.dark).copyWith(
    secondary: Colors.tealAccent,
    background: Colors.black,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.tealAccent,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      textStyle: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
      elevation: 8,
      shadowColor: Colors.tealAccent.withOpacity(0.5),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.grey[800],
    labelStyle: GoogleFonts.roboto(color: Colors.blueGrey[200]),
    prefixIconColor: Colors.tealAccent,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
    ),
  ),
  textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).copyWith(
    headlineMedium: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey[100]),
    titleLarge: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blueGrey[200]),
    bodyLarge: GoogleFonts.roboto(fontSize: 16, color: Colors.white70),
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 6,
    shadowColor: Colors.black.withOpacity(0.5),
    color: Colors.grey[850],
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.tealAccent,
    elevation: 6,
    extendedPadding: EdgeInsets.symmetric(horizontal: 20),
  ),
);