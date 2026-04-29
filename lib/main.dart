import 'package:flutter/material.dart';
import 'ui/main_screen.dart';

void main() {
  runApp(const UmlStreamApp());
}

class UmlStreamApp extends StatelessWidget {
  const UmlStreamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UML Stream Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00FFC4),
          surface: Color(0xFF1E1E2C),
          background: Color(0xFF0D0D14),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
