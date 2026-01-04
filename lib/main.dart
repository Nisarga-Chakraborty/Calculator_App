import 'package:calculator/calculator_app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalculatorApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}
