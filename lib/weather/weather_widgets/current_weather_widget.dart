import 'package:driver_monitoring_system/weather/weather_page.dart';
import 'package:flutter/material.dart';
import '../weather_data/weather_result.dart';
import '../weather_data/weather_use_case.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


/*
Hava durumları için yardımcı sınıflar.
 */

class CurrentWeatherPage extends StatefulWidget {

  final WeatherUseCase weatherUseCase;
  static final Key progressKey = Key("current_weather_widget_progress");
  static final Key weatherKey = Key("current_weather_widget_weather");
  static final Key errorKey = Key("current_weather_widget_error");

  CurrentWeatherPage({required this.weatherUseCase});

  @override
  _CurrentWeatherPageState createState() => _CurrentWeatherPageState();
}

class _CurrentWeatherPageState extends State<CurrentWeatherPage> {

  late WeatherResult weatherResult;
  // CHANGE GET METHOD TYPE IF YOU WANT USER LOCATION WEATHER

  @override
  Widget build(BuildContext context) {    
    return RefreshIndicator(
        child: FutureBuilder<WeatherResult>(
          future: widget.weatherUseCase.getFromCarLocation(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              weatherResult = snapshot.data!;
              return WeatherHomePage(weatherResult: weatherResult,);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}", key: CurrentWeatherPage.errorKey);
            }
            return const Center(
              child: SpinKitFadingFour(color: Colors.black, ),
            );
          },
        ),
        onRefresh: () async {
          await widget.weatherUseCase.getFromCarLocation().then((value) =>
              setState(() {
                weatherResult = value;
              })
          );
        }
    );

  }

}