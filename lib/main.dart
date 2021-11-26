import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memogenerator/presentation/main/main_page.dart';

void main() async {
  EquatableConfig.stringify = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
      ),
      home: MainPage(),
    );
  }
}
