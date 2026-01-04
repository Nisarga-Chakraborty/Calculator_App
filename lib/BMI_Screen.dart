import 'dart:ffi';

import 'package:calculator/BMI_Calc.dart';
import 'package:flutter/material.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  bool isMale = true;

  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  double bmi = 0;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF000000);
    const labelColor = Color(0xFFB7BCD1);
    const fieldHintColor = Color(0xFF7B7F8F);
    const orange = Color(0xFFF5861F);
    const cardColor = Color(0xFF1C1C1C);

    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              // AppBar row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'BMI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Age + Gender row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Age
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Age',
                                  style: TextStyle(
                                    color: labelColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _UnderlineTextField(
                                  controller: ageController,
                                  hint: 'Enter age',
                                  hintColor: fieldHintColor,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Gender
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gender: ',
                                style: TextStyle(
                                  color: labelColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isMale ? 'Male' : 'Female',
                                style: const TextStyle(
                                  color: labelColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _GenderButton(
                                    isSelected: isMale,
                                    icon: Icons.man_2_rounded,
                                    orange: orange,
                                    cardColor: cardColor,
                                    onTap: () {
                                      setState(() => isMale = true);
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _GenderButton(
                                    isSelected: !isMale,
                                    icon: Icons.woman_2_rounded,
                                    orange: orange,
                                    cardColor: cardColor,
                                    onTap: () {
                                      setState(() => isMale = false);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Height
                      const Text(
                        'Height (cm)',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _UnderlineTextField(
                        controller: heightController,
                        hint: 'Enter height',
                        hintColor: fieldHintColor,
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 32),

                      // Weight
                      const Text(
                        'Weight (kg)',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _UnderlineTextField(
                        controller: weightController,
                        hint: 'Enter weight',
                        hintColor: fieldHintColor,
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 32),

                      // About BMI
                      const Text(
                        'About BMI',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Body mass index (BMI) is a person\'s weight in kilograms divided by the square of height in metres. BMI is an easy screening method for weight category.',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // Calculate button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if ((ageController.text.isEmpty) &&
                          (heightController.text.isEmpty) &&
                          (weightController.text.isEmpty)) {
                        const snackBar = SnackBar(
                          content: Text(
                            "Please enter your credentials",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        double age = double.tryParse(ageController.text) ?? 0;
                        double height =
                            double.tryParse(heightController.text) ?? 0;
                        double weight =
                            double.tryParse(weightController.text) ?? 0;
                        height =
                            height /
                            100; // converting the height from centimetre to metre
                        bmi = (weight / (height * height));

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => BmiCalc(BMI: bmi),
                          ),
                        );
                      }
                      // calculating the BMI
                    },

                    child: const Text(
                      'Calculate',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnderlineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color hintColor;
  final TextInputType? keyboardType;

  const _UnderlineTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.hintColor,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      keyboardType: keyboardType,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3A3A3A), width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.2),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final Color orange;
  final Color cardColor;
  final VoidCallback onTap;

  const _GenderButton({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.orange,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? orange : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: isSelected ? orange : Colors.grey, size: 30),
      ),
    );
  }
}
