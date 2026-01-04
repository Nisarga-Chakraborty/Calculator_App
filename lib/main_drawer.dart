import "package:calculator/BMI_Screen.dart";
import "package:calculator/graphs.dart";
import "package:calculator/conversion.dart";
import "package:calculator/length_converter.dart";
import "package:calculator/scientific_calculator.dart";
import "package:flutter/material.dart";

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 57, 63, 174),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 0, 0, 0),
                  const Color.fromARGB(255, 29, 12, 125),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              "\n    Menu",
              style: TextStyle(
                color: Color.fromARGB(255, 167, 91, 4),
                fontSize: 30,
                fontFamily: "Arial",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.black),
            title: Text(
              "Home",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.science, color: Colors.black),
            title: Text(
              "Scientific",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => ScientificCalculator()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.show_chart, color: Colors.black),
            title: Text(
              "Graphs",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => GraphScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.change_circle, color: Colors.black),
            title: Text(
              "Conversions",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => Conversions()));
            },
          ),
          /*ListTile(
            leading: Icon(Icons.date_range),
            title: Text(
              "Date Calculation",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => DateRange()));
            },
          ),
          ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text(
              "Currency Exchange",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => Currency()));
            },
          ),*/
          ListTile(
            leading: Icon(Icons.monitor_weight_rounded, color: Colors.black),
            title: Text(
              "BMI-Calculator",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => BmiScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.line_weight_rounded, color: Colors.black),
            title: Text(
              "Length Converter",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => LengthConverter()));
            },
          ),
        ],
      ),
    );
  }
}
