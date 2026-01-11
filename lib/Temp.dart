import 'package:flutter/material.dart';

class Temp_Converter extends StatefulWidget {
  const Temp_Converter({super.key});

  @override
  State<Temp_Converter> createState() => _Temp_ConverterState();
}

class _Temp_ConverterState extends State<Temp_Converter> {
  String fromUnit = "Celsius";
  String toUnit = "Fahrenheit";

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  final Map<String, double> unitFactors = {
    "Celsius": 1.0,
    "Fahrenheit": 0.5556,
    "Kelvin": 1.0,
  };

  final List<String> units = ["Celsius", "Fahrenheit", "Kelvin"];

  void initState() {
    super.initState();
    //Detecting any inputs in the from text field
    fromController.addListener(convert);
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  void convert() {
    double tempInCelsius = 0.0;
    double output = 0.0;
    double? input = double.tryParse(fromController.text);
    if (input == null) {
      toController.text = "";
    } else
    // Convert input to Celsius
    {
      if (fromUnit == "Celsius") {
        tempInCelsius = input;
      } else if (fromUnit == "Fahrenheit") {
        tempInCelsius = (input - 32) * (5 / 9);
      } else if (fromUnit == "Kelvin") {
        tempInCelsius = input - 273.15;
      }
    }
    // Convert Celsius to target unit
    if (toUnit == "Celsius") {
      output = tempInCelsius;
    } else if (toUnit == 'Fahrenheit') {
      output = (tempInCelsius * 9 / 5) + 32;
    } else if (toUnit == "Kelvin") {
      output = tempInCelsius + 273.15;
    }

    toController.text = output.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 2, 88),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 0, 20),
        title: const Text(
          "Temperature Converter",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontFamily: "Arial",
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color.fromARGB(255, 164, 146, 146)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            _buildLabel("Present Unit"),
            const SizedBox(height: 15),
            _buildUnitRow(
              fromUnit,
              (val) => setState(() {
                fromUnit = val;
                convert();
              }),
              fromController,
              readOnly: false,
            ),

            const SizedBox(height: 44),
            _buildLabel("New Unit"),
            const SizedBox(height: 20),
            _buildUnitRow(
              toUnit,
              (val) => setState(() {
                toUnit = val;
                convert();
              }),
              toController,
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  // Label builder
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color.fromARGB(255, 220, 181, 6),
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Row builder for dropdown + textfield
  Widget _buildUnitRow(
    String currentValue,
    ValueChanged<String> onChanged,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 55,
            child: DropdownButton<String>(
              value: currentValue,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: const Color.fromARGB(255, 2, 52, 95),
              style: const TextStyle(color: Colors.white, fontSize: 20),
              items: units.map((String unit) {
                return DropdownMenuItem<String>(value: unit, child: Text(unit));
              }).toList(),
              onChanged: (String? newValue) => onChanged(newValue!),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 55,
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: "Enter temperature",
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
