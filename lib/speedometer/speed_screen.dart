import 'package:flutter/material.dart';
import 'dash_screen.dart';

class SpeedScreen extends StatefulWidget {
  const SpeedScreen({Key? key}) : super(key: key);

  @override
  _SpeedScreenState createState() => _SpeedScreenState();
}

class _SpeedScreenState extends State<SpeedScreen> {

  String currentSelectedUnit = 'km/h';

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: DashScreen(unit: currentSelectedUnit),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
    );
  }
}