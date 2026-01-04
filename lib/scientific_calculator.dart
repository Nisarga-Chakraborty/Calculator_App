import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

class ScientificCalculator extends StatefulWidget {
  const ScientificCalculator({super.key});

  @override
  State<StatefulWidget> createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  List<String> buttons = [
    'C',
    'CE',
    '<-',
    '%',
    'sin',
    'cos',
    'tan',
    '√',
    'log',
    'ln',
    '2nd',
    '^',
    '(',
    ')',
    'π',
    'e',
    '7',
    '8',
    '9',
    '÷',
    '4',
    '5',
    '6',
    '×',
    '1',
    '2',
    '3',
    '-',
    '0',
    '.',
    '+',
    '=',
  ];

  String expression = "";
  String result = "";

  bool useDegrees = false;
  bool inverseMode = false;

  void calculate(String value) {
    setState(() {
      if ((value == "C") || (value == "CE")) {
        expression = "";
        result = "";
      } else if (value == "<-") {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
      } else if (value == "=") {
        try {
          final sanitized = preprocess(expression);

          Parser p = Parser();
          // Register custom log10
          p.addFunction('log10', (List<double> args) {
            return math.log(args[0]) / math.log(10);
          });
          p.addFunction("asin", (List<double> args) => math.asin(args[0]));
          p.addFunction("acos", (List<double> args) => math.acos(args[0]));
          p.addFunction("atan", (List<double> args) => math.atan(args[0]));

          Expression exp = p.parse(sanitized);
          print(sanitized);

          ContextModel cm = ContextModel();
          cm.bindVariableName('pi', Number(math.pi));
          cm.bindVariableName('e', Number(math.e));

          double eval = exp.evaluate(EvaluationType.REAL, cm);

          if (eval.isNaN || eval.isInfinite) {
            result = "Domain Error";
          } else {
            result = eval.toStringAsFixed(3);
          }
        } catch (e) {
          result = "Error";
        }
      } else if (value == "2nd") {
        inverseMode = !inverseMode;
        for (int i = 0; i < buttons.length; i++) {
          if (inverseMode) {
            if (buttons[i] == "sin") buttons[i] = "sin⁻¹";
            if (buttons[i] == "cos") buttons[i] = "cos⁻¹";
            if (buttons[i] == "tan") buttons[i] = "tan⁻¹";
          } else {
            if (buttons[i] == "sin⁻¹") buttons[i] = "sin";
            if (buttons[i] == "cos⁻¹") buttons[i] = "cos";
            if (buttons[i] == "tan⁻¹") buttons[i] = "tan";
          }
        }
      } else {
        if ([
          "sin",
          "cos",
          "tan",
          "log",
          "ln",
          "sqrt",
          "sin⁻¹",
          "cos⁻¹",
          "tan⁻¹",
        ].contains(value)) {
          expression = "$expression$value(";
        } else {
          expression = expression + value;
        }
      }
    });
  }

  String preprocess(String expr) {
    // Remove whitespace
    expr = expr.replaceAll(RegExp(r'\s+'), '');
    print("Step 0 (raw): $expr");

    // Basic replacements
    expr = expr
        .replaceAll('÷', '/')
        .replaceAll('×', '*')
        .replaceAll('√', 'sqrt')
        .replaceAll('π', 'pi')
        .replaceAll(RegExp(r'\blog\('), 'log10(');
    print("Step 1 (basic replacements): $expr");

    // Map inverse trig labels
    expr = expr.replaceAll("sin⁻¹", "asin");
    expr = expr.replaceAll("cos⁻¹", "acos");
    expr = expr.replaceAll("tan⁻¹", "atan");
    print("Step 2 (map inverse labels): $expr");

    // Map modulus operator
    expr = expr.replaceAll('%', 'mod');
    print("Step 3 (modulus): $expr");

    // Ensure functions wrap numbers correctly (e.g., sin2 -> sin(2))
    final funcs = [
      'sin',
      'cos',
      'tan',
      'ln',
      'sqrt',
      'asin',
      'acos',
      'atan',
      'log10',
      'mod',
    ];
    for (final f in funcs) {
      expr = expr.replaceAllMapped(
        RegExp('$f(\\d+(?:\\.\\d+)?)'),
        (m) => '$f(${m[1]})',
      );
    }
    print("Step 4 (wrap numbers): $expr");

    if (useDegrees) {
      // Forward trig: convert input degrees -> radians (strict word boundary so sin != asin)
      for (final f in ['sin', 'cos', 'tan']) {
        expr = expr.replaceAllMapped(
          RegExp('\\b$f\\(([^()]+)\\)'),
          (m) => '$f((${m[1]})*pi/180)',
        );
      }
      print("Step 5 (forward trig conversion): $expr");

      // Inverse trig: convert output radians -> degrees by wrapping the whole call
      for (final f in ['asin', 'acos', 'atan']) {
        expr = expr.replaceAllMapped(
          RegExp('\\b$f\\([^()]+\\)'),
          (m) => '(180/pi)*${m[0]}',
        );
      }
      print("Step 6 (inverse trig conversion): $expr");
    }

    return expr;
  }

  Color getButtonColor(String btn) {
    if (btn == "=") return Colors.blue;
    if (["C", "CE", "<-"].contains(btn)) return Colors.red;
    if (["+", "-", "*", "÷", "%", "^"].contains(btn)) return Colors.orange;
    if ([
      "sin",
      "cos",
      "tan",
      "log",
      "ln",
      "2nd",
      "π",
      "e",
      "sin⁻¹",
      "cos⁻¹",
      "tan⁻¹",
    ].contains(btn)) {
      return Colors.deepPurple;
    }
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "SCIENTIFIC",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              Text(
                useDegrees ? "Deg" : "Rad",
                style: TextStyle(
                  color: const Color.fromARGB(255, 231, 228, 24),
                  fontSize: 20,
                ),
              ),
              Switch(
                value: useDegrees,
                onChanged: (b) {
                  setState(() {
                    useDegrees = b;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF03032C), Color(0xFF260171)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      expression,
                      style: TextStyle(color: Colors.grey[300], fontSize: 22),
                    ),
                    SizedBox(height: 10),
                    Text(
                      result,
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1.5,
              ),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                String btn = buttons[index];
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getButtonColor(btn),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => calculate(btn),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      btn,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
