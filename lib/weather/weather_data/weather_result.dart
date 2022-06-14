import 'weather.dart';
import 'forecast.dart';

/*

Hava durumu için yardımcı sınıflar

 */

class WeatherResult {

  Weather weather;
  Forecast forecast;

  WeatherResult({required this.weather, required this.forecast});
}