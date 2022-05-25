import 'package:driver_monitoring_system/weather/weather_data/weather.dart';

class Forecast {

  final String name;
  final List<Weather> predictions;

  Forecast({required this.name, required this.predictions});

}