/*import 'package:flutter/material.dart';

class LengthConverter extends StatefulWidget {
  const LengthConverter({super.key});

  @override
  State<LengthConverter> createState() => _LengthConverterState();
}

class _LengthConverterState extends State<LengthConverter> {
  // Separate state variables for each dropdown
  String fromUnit = "Foot";
  String toUnit = "metre";

  final List<String> units = [
    "nm",
    "µm",
    "mm",
    "cm",
    "dm",
    "metre",
    "km",
    "inches",
    "Foot",
    "Yard",
    "mile",
    "Nautical Miles",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 2, 88),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 0, 20),
        title: const Text(
          "Length Converter",
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
            colors: [
              Color.fromARGB(255, 6, 1, 19),
              Color.fromARGB(255, 38, 13, 181),
            ],
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
            _buildUnitRow(fromUnit, (val) => setState(() => fromUnit = val)),

            const SizedBox(height: 44),
            _buildLabel("New Unit"),
            const SizedBox(height: 20),
            _buildUnitRow(toUnit, (val) => setState(() => toUnit = val)),
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
  Widget _buildUnitRow(String currentValue, ValueChanged<String> onChanged) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 55, // same height for both
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
            height: 55, // same height for both
            child: TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                //hintText: "Enter value",
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
*/
import 'package:flutter/material.dart';

class LengthConverter extends StatefulWidget {
  const LengthConverter({super.key});

  @override
  State<LengthConverter> createState() => _LengthConverterState();
}

class _LengthConverterState extends State<LengthConverter> {
  // State variables for dropdowns
  String fromUnit = "Foot";
  String toUnit = "metre";

  // Controllers for text fields
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  // Conversion factors relative to metre
  final Map<String, double> conversionFactors = {
    "nm": 1e-9,
    "µm": 1e-6,
    "mm": 1e-3,
    "cm": 1e-2,
    "dm": 1e-1,
    "metre": 1.0,
    "km": 1e3,
    "inches": 0.0254,
    "Foot": 0.3048,
    "Yard": 0.9144,
    "mile": 1609.34,
    "Nautical Miles": 1852.0,
  };

  final List<String> units = [
    "nm",
    "µm",
    "mm",
    "cm",
    "dm",
    "metre",
    "km",
    "inches",
    "Foot",
    "Yard",
    "mile",
    "Nautical Miles",
  ];

  @override
  void initState() {
    super.initState();
    // Listen for changes in input field
    fromController.addListener(_convert);
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  // Conversion logic
  void _convert() {
    double? input = double.tryParse(fromController.text);
    if (input == null) {
      toController.text = "";
      return;
    }

    double fromFactor = conversionFactors[fromUnit]!;
    double toFactor = conversionFactors[toUnit]!;

    double result = input * (fromFactor / toFactor);
    toController.text = result.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 2, 88),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 0, 20),
        title: const Text(
          "Length Converter",
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
            colors: [
              Color.fromARGB(255, 6, 1, 19),
              Color.fromARGB(255, 38, 13, 181),
            ],
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
                _convert();
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
                _convert();
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
