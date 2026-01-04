import "package:calculator/main_drawer.dart";
import "package:flutter/material.dart";
import "package:math_expressions/math_expressions.dart";

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CalculatorAppState();
  }
}

class _CalculatorAppState extends State<CalculatorApp> {
  String expression = "";
  String result = "";

  void calculate(String value) {
    setState(() {
      if ((value == "C") || (value == "CE")) {
        expression = "";
        result = "";
      } else if (value == "<-") {
        if (expression != "") {
          expression = expression.substring(0, expression.length - 1);
        }
      } else if (value == "=") {
        try {
          Parser p = Parser();
          Expression exp = p.parse(expression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          result = eval.toString();
        } catch (e) {
          result = "Error";
        }
      } else {
        expression = expression + value;
      }
    });
  }

  Color getButtonColor_normal(String btn) {
    if (btn == "=") return Colors.blue;
    if (["C", "CE", "<-"].contains(btn)) return Colors.red;
    if (["+", "-", "*", "/", "%"].contains(btn)) return Colors.orange;
    return const Color.fromARGB(255, 7, 1, 23);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    List<String> buttons = [
      "%",
      "CE",
      "C",
      "<-",
      "7",
      "8",
      "9",
      "/",
      "4",
      "5",
      "6",
      "*",
      "1",
      "2",
      "3",
      "-",
      ".",
      "0",
      "=",
      "+",
    ];
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Text(
          "STANDARD",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: "Arial",
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      drawer: MainDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 3, 3, 44),
              const Color.fromARGB(255, 38, 1, 113),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        expression,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 24,
                          fontFamily: "Arial",
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        result.isEmpty ? expression : result,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                padding: const EdgeInsets.all(10),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: buttons.map((btn) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getButtonColor_normal(btn),
                      foregroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size(70, 70),
                    ),
                    onPressed: () => calculate(btn),
                    child: Text(
                      btn,
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
