import 'package:driver_monitoring_system/weather/weather_data/weather_use_case.dart';
import 'package:http/http.dart' show Client;
import 'package:location/location.dart';

import '../common/constants.dart';
import '../weather_widgets/current_weather_widget.dart';
import 'current_weather_service.dart';
import 'forecast_weather_service.dart';

class WeatherBuilder {
  
  WeatherUseCase build() {
    Location location = Location();
    Client client = Client();

    OpenWeatherCurrentService weatherService = OpenWeatherCurrentService(client, Constants.endpoint, Constants.appId);
    OpenWeatherForecastService forecastService = OpenWeatherForecastService(client, Constants.endpoint, Constants.appId);
    WeatherUseCase useCase = WeatherUseCase(location, weatherService, forecastService);
    
    return useCase;
  }

}
