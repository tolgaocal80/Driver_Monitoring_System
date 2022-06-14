import 'package:driver_monitoring_system/pythonComponents/single_caruser.dart';
import 'package:driver_monitoring_system/user_dao/car_user.dart';
import 'package:firebase_database/firebase_database.dart';

import 'weather.dart';
import 'forecast.dart';
import 'weather_result.dart';
import 'package:location/location.dart';

/*

Hava durumu için yardımcı sınıflar

 */

abstract class WeatherService {
  Future<Weather> get(double lat, double lon);
}

abstract class ForecastService {
  Future<Forecast> get(double lat, double lon);
}

class WeatherUseCase {

  WeatherService _weatherService;
  ForecastService _forecastService;

  WeatherUseCase(this._weatherService, this._forecastService);

  DatabaseReference reference = SingleCarUser.instance.ref;

  Future<WeatherResult> getFromCarLocation() async {
    CarUser user = SingleCarUser.instance.carUser;
    var latitude = double.parse(user.latitude);
    var longitude = double.parse(user.longitude);

    Weather weather = await _weatherService.get(latitude, longitude);
    Forecast forecast = await _forecastService.get(latitude, longitude);
    return Future.value(WeatherResult(weather: weather, forecast: forecast));
  }


}