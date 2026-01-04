import 'package:flutter/material.dart';

class DateRange extends StatefulWidget {
  const DateRange({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DateRangeState();
  }
}

class _DateRangeState extends State<DateRange> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Date Range",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: "Arial",
          ),
        ),
      ),
    );
  }
}
