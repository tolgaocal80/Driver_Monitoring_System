import 'package:http/http.dart' show Client;
import 'dart:convert';
import 'weather.dart';
import 'weather_use_case.dart';
import 'weather_mapper.dart';


/*

Hava durumu işlemleri için kullanılan yardımcı sınıf.

 */


class OpenWeatherCurrentService implements WeatherService{

  final String _endpoint;
  final Client _client;
  final String _appId;

  OpenWeatherCurrentService(this._client, this._endpoint, this._appId);
  
  Future<Weather> get(double lat, double lon) async {

    Uri url = Uri.parse(_endpoint + "weather?lat=$lat&lon=$lon&appId=$_appId&units=metric&lang=tr");

    final response = await _client.get(url);

    if (response != null && response.statusCode == 200) {
      return WeatherMapper.map(json.decode(response.body));
    } else {
      throw Exception("Request error");
    }
  }

}