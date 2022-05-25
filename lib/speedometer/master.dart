import 'package:flutter/material.dart';
import 'dash_screen.dart';

class SpeedometerApp extends StatefulWidget {
  const SpeedometerApp({Key? key}) : super(key: key);

  @override
  _SpeedometerAppState createState() => _SpeedometerAppState();
}

class _SpeedometerAppState extends State<SpeedometerApp> {

  String currentSelectedUnit = 'km/h';

  @override
  Widget build(BuildContext context) {

    return Container(
      child: DashScreen(unit: currentSelectedUnit),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(30))
      ),
    );
  }
}