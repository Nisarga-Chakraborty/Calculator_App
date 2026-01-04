import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:math_expressions/math_expressions.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  List<String> equations = ["sin(x)", "x^2"];
  List<TextEditingController> controllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each starting equation
    controllers = equations
        .map((eq) => TextEditingController(text: eq))
        .toList();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 3),
        title: const Text(
          "Graphing Calculator",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: "Arial",
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 243, 218, 61),
              const Color.fromARGB(255, 2, 6, 249),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 30),
            // Graph area
            Expanded(
              flex: 2,
              child: InteractiveViewer(
                // InteractiveViewer allows the user to zoom in and zoom out
                boundaryMargin: const EdgeInsets.all(50),
                minScale: 0.5,
                maxScale: 5,
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) =>
                          FlLine(color: Colors.black, strokeWidth: 1.5),
                      getDrawingVerticalLine: (value) =>
                          FlLine(color: Colors.black, strokeWidth: 1.5),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: equations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final eq = entry.value;
                      final spots = generatePoints(eq);
                      return LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color:
                            Colors.primaries[index % Colors.primaries.length],
                        barWidth: 2,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            // Equation input area
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: equations.length,
                itemBuilder: (context, index) {
                  return TextField(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                    ),
                    controller: controllers[index],
                    onChanged: (val) => setState(() => equations[index] = val),
                    decoration: InputDecoration(
                      prefixIcon: IconButton(
                        icon: Icon(Icons.show_chart_rounded),
                        color: Colors.black,
                        onPressed: () {},
                      ),
                      hintText: "Enter the function",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.black,
                        onPressed: () => setState(() {
                          equations.removeAt(index);
                          controllers.removeAt(index).dispose();
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Add new equation
      floatingActionButton: FloatingActionButton(
        // That “+” sign at the bottom‑right of the screen
        child: const Icon(Icons.add),
        onPressed: () => setState(() {
          equations.add("");
          controllers.add(TextEditingController());
        }),
      ),
    );
  }

  /// Generate points for a given equation string
  List<FlSpot> generatePoints(String eq) {
    try {
      String sanitized = preprocess(eq);

      Parser p = Parser();
      Expression exp = p.parse(sanitized);
      ContextModel cm = ContextModel();

      return List.generate(200, (i) {
        double x = (i - 100) / 10.0; // range -10 to +10
        double y = exp.evaluate(
          EvaluationType.REAL,
          cm..bindVariable(Variable('x'), Number(x)),
        );

        // Handle invalid values gracefully
        if (y.isNaN || y.isInfinite) return FlSpot(x, 0);
        return FlSpot(x, y);
      });
    } catch (e) {
      return [];
    }
  }

  String preprocess(String expr) {
    expr = expr
        .replaceAll('÷', '/')
        .replaceAll('×', '*')
        .replaceAll('π', 'pi')
        .replaceAll('√', 'sqrt'); // map symbol to parser function

    // Also allow users to type "sqrt" directly
    expr = expr.replaceAll('sqrt', 'sqrt');

    return expr;
  }
}
