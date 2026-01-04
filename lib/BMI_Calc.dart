import 'package:flutter/material.dart';

class BmiCalc extends StatelessWidget {
  final double BMI;
  const BmiCalc({super.key, required this.BMI});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your current BMI",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 7, 0, 27),
              const Color.fromARGB(255, 37, 10, 174),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              BMI.toStringAsFixed(1),
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Body Mass Index",
              style: TextStyle(
                color: Color.fromARGB(255, 240, 225, 126),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),

            // BMI Indicator Line
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 18, // BMI < 18.5
                      child: Container(height: 20, color: Colors.blue),
                    ),
                    Expanded(
                      flex: 65, // BMI 18.5 - 24.9
                      child: Container(height: 20, color: Colors.green),
                    ),
                    Expanded(
                      flex: 50, // BMI 25 - 29.9
                      child: Container(height: 20, color: Colors.orange),
                    ),
                    Expanded(
                      flex: 60, // BMI >= 30
                      child: Container(height: 20, color: Colors.red),
                    ),
                  ],
                ),

                // Pointer
                Positioned(
                  left: _calculatePointerPosition(context, BMI),
                  child: Icon(
                    Icons.arrow_drop_up_sharp,
                    color: const Color.fromARGB(255, 255, 0, 0),
                    size: 35,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Underweight", style: TextStyle(color: Colors.white)),
                Text("Normal", style: TextStyle(color: Colors.white)),
                Text("Overweight", style: TextStyle(color: Colors.white)),
                Text("Obese", style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 35),
            Row(
              children: [
                const Text(
                  "Underweight --> ",
                  style: TextStyle(
                    color: Color.fromARGB(255, 197, 191, 4),
                    fontSize: 18,
                  ),
                ),
                Icon(
                  Icons.rectangle_rounded,
                  color: const Color.fromARGB(255, 10, 123, 215),
                ),
                Text(
                  "  - Less than 18.5",
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Normal -->   ",
                  style: TextStyle(
                    color: Color.fromARGB(255, 197, 191, 4),
                    fontSize: 18,
                  ),
                ),
                Icon(
                  Icons.rectangle_rounded,
                  color: const Color.fromARGB(255, 50, 167, 8),
                ),
                Text(
                  "         - 18.5 – 24.9",
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Overweight --> ",
                  style: TextStyle(
                    color: Color.fromARGB(255, 197, 191, 4),
                    fontSize: 18,
                  ),
                ),
                Icon(
                  Icons.rectangle_rounded,
                  color: const Color.fromARGB(255, 163, 103, 5),
                ),
                Text(
                  "    - 25 – 29.9",
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Obese -->   ",
                  style: TextStyle(
                    color: Color.fromARGB(255, 197, 191, 4),
                    fontSize: 18,
                  ),
                ),
                Icon(
                  Icons.rectangle_rounded,
                  color: const Color.fromARGB(255, 163, 23, 5),
                ),
                Text(
                  "           - 30 or greater",
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 54),
            Text(
              "Your Category",
              style: TextStyle(
                color: const Color.fromARGB(255, 199, 190, 7),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              displayCategory(BMI),
              style: TextStyle(
                color: const Color.fromARGB(255, 255, 255, 255),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String displayCategory(double bmi) {
    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi < 25) {
      return "Normal";
    } else if (bmi < 30) {
      return "Overweight";
    } else {
      return "Obese";
    }
  }

  double _calculatePointerPosition(BuildContext context, double bmi) {
    double totalWidth = MediaQuery.of(context).size.width - 40; // padding
    int totalFlex = 18 + 65 + 50 + 60; // sum of flex values

    // Define BMI ranges
    double underMax = 18.5;
    double normalMax = 24.9;
    double overMax = 29.9;
    double obeseMax = 40; // cap at 40 for visualization

    // Calculate segment widths based on flex
    double underWidth = (18 / totalFlex) * totalWidth;
    double normalWidth = (65 / totalFlex) * totalWidth;
    double overWidth = (50 / totalFlex) * totalWidth;
    double obeseWidth = (60 / totalFlex) * totalWidth;

    if (bmi < underMax) {
      return (bmi / underMax) * underWidth;
    } else if (bmi < normalMax) {
      return underWidth +
          ((bmi - underMax) / (normalMax - underMax)) * normalWidth;
    } else if (bmi < overMax) {
      return underWidth +
          normalWidth +
          ((bmi - normalMax) / (overMax - normalMax)) * overWidth;
    } else {
      return underWidth +
          normalWidth +
          overWidth +
          ((bmi - overMax) / (obeseMax - overMax)) * obeseWidth;
    }
  }
}
