import 'package:flutter/material.dart';

class Currency extends StatefulWidget {
  const Currency({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CurrencyState();
  }
}

class _CurrencyState extends State<Currency> {
  String fromCurrency = "USD";
  String toCurrency = "INR";

  final List<String> currencies = ["USD", "INR", 'EUR', 'GBP', 'JPY'];
  List<String> buttons = [
    "7",
    "8",
    "9",
    "<-",
    "4",
    "5",
    "6",
    "C",
    "1",
    "2",
    "3",
    ".",
    "0",
    "↔",
    "Convert",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "CURRENCY",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: "Arial",
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 12, 1, 49),
              const Color.fromARGB(255, 36, 14, 143),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              "Here i will implement the functions.....not now as I am not feeling to do it",
            ),
          ],
        ),
      ),
    );
  }
}
