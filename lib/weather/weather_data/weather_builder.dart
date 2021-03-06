import 'package:driver_monitoring_system/weather/weather_data/weather_use_case.dart';
import 'package:http/http.dart' show Client;
import 'package:location/location.dart';
import '../common/constants.dart';
import 'current_weather_service.dart';
import 'forecast_weather_service.dart';


/*

Hava durumu için yardımcı sınıflar

 */

class WeatherBuilder {
  
  WeatherUseCase build() {
    Client client = Client();

    OpenWeatherCurrentService weatherService = OpenWeatherCurrentService(client, Constants.endpoint, Constants.appId);
    OpenWeatherForecastService forecastService = OpenWeatherForecastService(client, Constants.endpoint, Constants.appId);
    WeatherUseCase useCase = WeatherUseCase(weatherService, forecastService);
    
    return useCase;
  }

}
