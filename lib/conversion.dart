import 'package:flutter/material.dart';

class Conversions extends StatefulWidget {
  const Conversions({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ConversionsState();
  }
}

class _ConversionsState extends State<Conversions> {
  // Shared controllers for each number system
  final List<TextEditingController> controllers = [
    TextEditingController(), // Decimal
    TextEditingController(), // Binary
    TextEditingController(), // Octal
    TextEditingController(), // Hexadecimal
  ];

  // Shared flag to prevent recursive updates
  bool isUpdating = false;

  int parseInput(String value, int base) {
    return int.parse(value, radix: base);
  }

  String toBase(int number, int base) {
    return number.toRadixString(base).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 14, 4, 92),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "CONVERSION",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: "Arial",
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF03032C), Color(0xFF260171)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
              // Decimal field
              TextField(
                controller: controllers[0],
                decoration: const InputDecoration(
                  labelText: " Decimal",
                  labelStyle: TextStyle(fontSize: 25, color: Colors.white),
                ),
                keyboardType: TextInputType.numberWithOptions(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (val) {
                  if (val.isEmpty || isUpdating) return;
                  try {
                    isUpdating = true;
                    int decimal = int.parse(val);
                    controllers[1].text = toBase(decimal, 2); // Binary
                    controllers[2].text = toBase(decimal, 8); // Octal
                    controllers[3].text = toBase(decimal, 16); // Hexadecimal
                  } catch (e) {
                    _showError(context);
                  } finally {
                    isUpdating = false;
                  }
                },
              ),
              SizedBox(height: 30),
              // Binary field
              TextField(
                controller: controllers[1],
                decoration: const InputDecoration(
                  labelText: " Binary",
                  labelStyle: TextStyle(fontSize: 25, color: Colors.white),
                ),
                keyboardType: TextInputType.numberWithOptions(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (val) {
                  if (val.isEmpty || isUpdating) return;
                  try {
                    isUpdating = true;
                    int decimal = parseInput(val, 2);
                    controllers[0].text = decimal.toString(); // Decimal
                    controllers[2].text = toBase(decimal, 8); // Octal
                    controllers[3].text = toBase(decimal, 16); // Hex
                  } catch (e) {
                    _showError(context);
                  } finally {
                    isUpdating = false;
                  }
                },
              ),
              SizedBox(height: 30),
              // Octal field
              TextField(
                controller: controllers[2],
                decoration: const InputDecoration(
                  labelText: " Octal",
                  labelStyle: TextStyle(fontSize: 25, color: Colors.white),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (val) {
                  if (val.isEmpty || isUpdating) return;
                  try {
                    isUpdating = true;
                    int decimal = int.parse(val, radix: 8);
                    controllers[0].text = decimal.toString(); // Decimal
                    controllers[1].text = decimal.toRadixString(2); // Binary
                    controllers[3].text = decimal
                        .toRadixString(16)
                        .toUpperCase(); // Hex
                  } catch (e) {
                    _showError(context);
                  } finally {
                    isUpdating = false;
                  }
                },
              ),
              SizedBox(height: 30),
              // Hexadecimal field
              TextField(
                controller: controllers[3],
                decoration: const InputDecoration(
                  labelText: " Hexadecimal",
                  labelStyle: TextStyle(fontSize: 25, color: Colors.white),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (val) {
                  if (val.isEmpty || isUpdating) return;
                  try {
                    isUpdating = true;
                    int decimal = int.parse(val, radix: 16);
                    controllers[0].text = decimal.toString(); // Decimal
                    controllers[1].text = decimal.toRadixString(2); // Binary
                    controllers[2].text = decimal.toRadixString(8); // Octal
                  } catch (e) {
                    _showError(context);
                  } finally {
                    isUpdating = false;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context) {
    const snackBar = SnackBar(
      content: Text("Invalid Input", style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
