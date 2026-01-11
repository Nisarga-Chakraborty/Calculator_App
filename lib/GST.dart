import 'package:flutter/material.dart';

class GST_Calculator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GST_CalculatorState();
  }
}

class GST_CalculatorState extends State<GST_Calculator> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedRate = '18%';
  bool _isInclusive = false;
  double _gstAmount = 0.0;
  double _totalAmount = 0.0;

  final List<String> _gstRates = ['0%', '5%', '12%', '18%', '28%'];

  void _calculateGST() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double rate = double.parse(_selectedRate.replaceAll('%', '')) / 100;

    if (_isInclusive) {
      // GST inclusive
      _gstAmount = amount - (amount / (1 + rate));
      _totalAmount = amount;
    } else {
      // GST exclusive
      _gstAmount = amount * rate;
      _totalAmount = amount + _gstAmount;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GST Calculator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: "Arial",
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 3, 30),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, const Color.fromARGB(255, 164, 146, 146)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Enter Amount',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRate,
                dropdownColor: const Color.fromARGB(255, 2, 2, 88),
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'GST Rate',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                items: _gstRates.map((rate) {
                  return DropdownMenuItem(value: rate, child: Text(rate));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRate = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'GST Inclusive',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Switch(
                    value: _isInclusive,
                    onChanged: (value) {
                      setState(() {
                        _isInclusive = value;
                      });
                    },
                  ),
                  Text(
                    'GST Exclusive',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateGST,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 99, 66, 232),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: const Text(
                  'Calculate',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              SizedBox(height: 24),
              Card(
                elevation: 4,
                color: const Color.fromARGB(255, 218, 144, 7),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'GST Amount: ₹${_gstAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Total Amount: ₹${_totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
