import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'map_widget.dart';

/*

Harita ekranını oluşturan yardımcı sınıf.


 */

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(),
    );
  }
}
