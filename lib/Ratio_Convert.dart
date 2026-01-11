import 'package:flutter/material.dart';

class RatioConverter extends StatefulWidget {
  const RatioConverter({super.key});

  @override
  State<RatioConverter> createState() => _RatioConverterState();
}

class _RatioConverterState extends State<RatioConverter> {
  final TextEditingController _ratioController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  // Units and their conversion factors to metres
  final Map<String, double> conversionFactors = const {
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

  final List<String> units = const [
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

  String fromUnit = "metre";
  String toUnit = "metre";

  // Guard to prevent onChanged loops when we programmatically update text fields
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Optional defaults
    _ratioController.text = "1:1";
    _inputController.text = "";
    _outputController.text = "";
  }

  @override
  void dispose() {
    _ratioController.dispose();
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  // Parse ratios in forms like "1:5000", "2 : 3", "5000", "0.2"
  // Returns a positive multiplier (scale) that maps input -> output before unit conversion.
  double? _parseRatio(String text) {
    final s = text.trim();
    if (s.isEmpty) return null;

    // If contains ':', parse a:b
    if (s.contains(':')) {
      final parts = s.split(':');
      if (parts.length != 2) return null;

      final a = double.tryParse(parts[0].trim());
      final b = double.tryParse(parts[1].trim());
      if (a == null || b == null || a == 0) return null;

      // Scale: inputVal * (b/a)
      return b / a;
    }

    // Else treat as single multiplier
    final m = double.tryParse(s);
    if (m == null || m <= 0) return null;
    return m;
  }

  void _updateFromInput(String value) {
    if (_isUpdating) return;

    _isUpdating = true;

    final scale = _parseRatio(_ratioController.text);
    final inputVal = double.tryParse(value);

    if (scale != null && inputVal != null) {
      final fromFactor = conversionFactors[fromUnit]!;
      final toFactor = conversionFactors[toUnit]!;

      // Convert input from 'fromUnit' to metres, apply scale, convert to 'toUnit'
      final outputVal = (inputVal * fromFactor) * scale / toFactor;

      _outputController.text = _formatNumber(outputVal);
    } else {
      _outputController.clear();
    }

    _isUpdating = false;
  }

  void _updateFromOutput(String value) {
    if (_isUpdating) return;

    _isUpdating = true;

    final scale = _parseRatio(_ratioController.text);
    final outputVal = double.tryParse(value);

    if (scale != null && outputVal != null && scale != 0) {
      final fromFactor = conversionFactors[fromUnit]!;
      final toFactor = conversionFactors[toUnit]!;

      // Reverse: output in 'toUnit' -> metres -> divide by scale -> convert to 'fromUnit'
      final inputVal = (outputVal * toFactor) / scale / fromFactor;

      _inputController.text = _formatNumber(inputVal);
    } else {
      _inputController.clear();
    }

    _isUpdating = false;
  }

  // Format numbers neatly
  String _formatNumber(double x) {
    // Pick fixed or scientific based on magnitude
    final absx = x.abs();
    if ((absx != 0 && absx < 1e-4) || absx >= 1e7) {
      return x.toStringAsExponential(6);
    }
    return x
        .toStringAsFixed(6)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  // Recompute from whichever field currently has focus/input.
  // If both empty, clear both. If one has a value, recompute the other.
  void _recomputeOnRatioOrUnitChange() {
    if (_isUpdating) return;

    final inputText = _inputController.text.trim();
    final outputText = _outputController.text.trim();

    // Prefer recomputing from the non-empty field
    if (inputText.isNotEmpty) {
      _updateFromInput(inputText);
    } else if (outputText.isNotEmpty) {
      _updateFromOutput(outputText);
    } else {
      // Nothing entered yet—just clear
      _inputController.clear();
      _outputController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ratio Converter",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontFamily: "Arial",
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 0, 20),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color.fromARGB(255, 164, 146, 146)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabel("Enter the ratio (e.g., 1:5000 or 5000):"),
            const SizedBox(height: 12),
            TextField(
              controller: _ratioController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintText: "Enter Ratio",
                hintStyle: TextStyle(color: Colors.white54),
              ),
              onChanged: (_) => _recomputeOnRatioOrUnitChange(),
            ),

            const SizedBox(height: 20),
            _buildLabel("\"From\" Unit and Input Value:"),
            const SizedBox(height: 10),
            _buildUnitRow(
              currentValue: fromUnit,
              onChanged: (val) {
                setState(() => fromUnit = val);
                _recomputeOnRatioOrUnitChange();
              },
              controller: _inputController,
              hint: "Enter value",
              onChangedText: _updateFromInput,
            ),

            const SizedBox(height: 20),
            _buildLabel("\"To\" Unit and Output Value:"),
            const SizedBox(height: 10),
            _buildUnitRow(
              currentValue: toUnit,
              onChanged: (val) {
                setState(() => toUnit = val);
                _recomputeOnRatioOrUnitChange();
              },
              controller: _outputController,
              hint: "Enter value",
              onChangedText: _updateFromOutput,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color.fromARGB(255, 220, 181, 6),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Reusable row: dropdown + textfield
  Widget _buildUnitRow({
    required String currentValue,
    required ValueChanged<String> onChanged,
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChangedText,
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
              style: const TextStyle(color: Colors.white, fontSize: 18),
              items: units
                  .map(
                    (String unit) => DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    ),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) onChanged(newValue);
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 55,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              onChanged: onChangedText,
            ),
          ),
        ),
      ],
    );
  }
}
