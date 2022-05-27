import 'package:driver_monitoring_system/weather/common/date_formatter.dart';
import 'package:driver_monitoring_system/weather/weather_data/forecast.dart';
import 'package:driver_monitoring_system/weather/weather_data/weather.dart';
import 'package:driver_monitoring_system/weather/weather_data/weather_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';


class WeatherHomePage extends StatefulWidget {
   WeatherHomePage( {Key? key, required this.weatherResult}) : super(key: key);

   WeatherResult weatherResult;

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {

  GeolocatorPlatform geolocator= GeolocatorPlatform.instance;
  late Position currentPosition;
  late String locationAddress = "";
  late List<Placemark> placemark;

  @override
  void initState() {
    super.initState();
    geolocator.getPositionStream(locationSettings: const LocationSettings(timeLimit: Duration(seconds: 10)))
        .listen((position) async {
          currentPosition = position;
          placemark = await placemarkFromCoordinates(position.latitude, position.longitude);
          Placemark place = placemark[0];
          setState(() {
            locationAddress = "${place.thoroughfare}, ${place.subLocality}\n"
                "${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}";
          });
    },
    );
  }

  @override
  Widget build(BuildContext context) {

    Weather weather = widget.weatherResult.weather;
    Forecast forecast = widget.weatherResult.forecast;

    String cityName = weather.name; //city name

    int currTemp = weather.temperature.toInt(); // current temperature
    int maxTemp = weather.maxTemperature.toInt(); // today max temperature
    int minTemp = weather.minTemperature.toInt(); // today min temperature

    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Container(
        height: size.height,
        width: size.height,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.white,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                        ),
                        child: Column(

                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: size.height * 0.01,
                                  left: size.width * 0.03,
                                ),
                                child: Text(
                                  'Son Konum :',
                                  style: GoogleFonts.questrial(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: size.height * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            locationAddress == "" ? const SpinKitFadingFour(color: Colors.black, size: 30,) : Text(locationAddress, style: GoogleFonts.questrial(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: size.height * 0.02,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.03,
                      ),
                      child: Align(
                        child: Text(
                          cityName,
                          style: GoogleFonts.questrial(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: size.height * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.005,
                      ),
                      child: Align(
                        child: Text(
                          'Bugün', //day
                          style: GoogleFonts.questrial(
                            color:
                            isDarkMode ? Colors.white54 : Colors.black54,
                            fontSize: size.height * 0.035,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.03,
                      ),
                      child: Align(
                        child: Text(
                          '$currTemp˚C', //curent temperature
                          style: GoogleFonts.questrial(
                            color: currTemp <= 0
                                ? Colors.blue
                                : currTemp > 0 && currTemp <= 15
                                ? Colors.indigo
                                : currTemp > 15 && currTemp < 30
                                ? Colors.deepPurple
                                : Colors.pink,
                            fontSize: size.height * 0.13,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: size.width * 0.25),
                      child: Divider(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.005,
                      ),
                      child: Align(
                        child: Text(
                          weather.description, // weather
                          style: GoogleFonts.questrial(
                            color:
                            isDarkMode ? Colors.white54 : Colors.black54,
                            fontSize: size.height * 0.03,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.03,
                        bottom: size.height * 0.01,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$minTemp˚C', // min temperature
                            style: GoogleFonts.questrial(
                              color: minTemp <= 0
                                  ? Colors.blue
                                  : minTemp > 0 && minTemp <= 15
                                  ? Colors.indigo
                                  : minTemp > 15 && minTemp < 30
                                  ? Colors.deepPurple
                                  : Colors.pink,
                              fontSize: size.height * 0.03,
                            ),
                          ),
                          Text(
                            '/',
                            style: GoogleFonts.questrial(
                              color: isDarkMode
                                  ? Colors.white54
                                  : Colors.black54,
                              fontSize: size.height * 0.03,
                            ),
                          ),
                          Text(
                            '$maxTemp˚C', //max temperature
                            style: GoogleFonts.questrial(
                              color: maxTemp <= 0
                                  ? Colors.blue
                                  : maxTemp > 0 && maxTemp <= 15
                                  ? Colors.indigo
                                  : maxTemp > 15 && maxTemp < 30
                                  ? Colors.deepPurple
                                  : Colors.pink,
                              fontSize: size.height * 0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: size.height * 0.01,
                                  left: size.width * 0.03,
                                ),
                                child: Text(
                                  'Bugün için tahminler',
                                  style: GoogleFonts.questrial(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: size.height * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(size.width * 0.005),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    children: [
                                      buildForecastToday(
                                          weather.dateTime.hour.toString()+":"+weather.dateTime.minute.toString(),
                                          weather.temperature.toInt(),
                                          weather.windSpeed.toInt(),
                                          weather.humidity.toInt(),
                                          "http://openweathermap.org/img/wn/" + weather.icon.toString() +".png",
                                          size,
                                          isDarkMode
                                      ),
                                      forecast.predictions[0].dateTime.day.compareTo(DateTime.now().day) == 0 ?
                                      buildForecastToday(
                                          forecast.predictions[0].dateTime.hour.toString()+":"+forecast.predictions[0].dateTime.minute.toString(),
                                          forecast.predictions[0].temperature.toInt(),
                                          forecast.predictions[0].windSpeed.toInt(),
                                          forecast.predictions[0].humidity.toInt(),
                                          "http://openweathermap.org/img/wn/" + forecast.predictions[0].icon +".png",
                                          size,
                                          isDarkMode
                                      ) : Container(),
                                      forecast.predictions[1].dateTime.day.compareTo(DateTime.now().day) == 0 ?
                                      buildForecastToday(
                                          forecast.predictions[1].dateTime.hour.toString()+":"+forecast.predictions[1].dateTime.minute.toString(),
                                          forecast.predictions[1].temperature.toInt(),
                                          forecast.predictions[1].windSpeed.toInt(),
                                          forecast.predictions[1].humidity.toInt(),
                                          "http://openweathermap.org/img/wn/" + forecast.predictions[1].icon +".png",
                                          size,
                                          isDarkMode
                                      ) : Container(),
                                      forecast.predictions[2].dateTime.day.compareTo(DateTime.now().day) == 0 ?
                                      buildForecastToday(
                                          forecast.predictions[2].dateTime.hour.toString()+":"+forecast.predictions[2].dateTime.minute.toString(),
                                          forecast.predictions[2].temperature.toInt(),
                                          forecast.predictions[2].windSpeed.toInt(),
                                          forecast.predictions[2].humidity.toInt(),
                                          "http://openweathermap.org/img/wn/" + forecast.predictions[2].icon +".png",
                                          size,
                                          isDarkMode
                                      ) : Container(),
                                      forecast.predictions[3].dateTime.day.compareTo(DateTime.now().day) == 0 ?
                                      buildForecastToday(
                                          forecast.predictions[3].dateTime.hour.toString()+":"+forecast.predictions[3].dateTime.minute.toString(),
                                          forecast.predictions[3].temperature.toInt(),
                                          forecast.predictions[3].windSpeed.toInt(),
                                          forecast.predictions[3].humidity.toInt(),
                                          "http://openweathermap.org/img/wn/" + forecast.predictions[3].icon +".png",
                                          size,
                                          isDarkMode
                                      ) : Container(),
                                      forecast.predictions[4].dateTime.day.compareTo(DateTime.now().day) == 0 ?
                                      buildForecastToday(
                                          forecast.predictions[4].dateTime.hour.toString()+":"+forecast.predictions[4].dateTime.minute.toString(),
                                          forecast.predictions[4].temperature.toInt(),
                                          forecast.predictions[4].windSpeed.toInt(),
                                          forecast.predictions[4].humidity.toInt(),
                                          "http://openweathermap.org/img/wn/" + forecast.predictions[4].icon +".png",
                                          size,
                                          isDarkMode
                                      ) : Container(),
                                      forecast.predictions[5].dateTime.day.compareTo(DateTime.now().day) == 0 ?
                                      buildForecastToday(
                                          forecast.predictions[5].dateTime.hour.toString()+":"+forecast.predictions[5].dateTime.minute.toString(),
                                          forecast.predictions[5].temperature.toInt(),
                                          forecast.predictions[5].windSpeed.toInt(),
                                          forecast.predictions[5].humidity.toInt(),
                                          "http://openweathermap.org/img/wn/" + forecast.predictions[5].icon +".png",
                                          size,
                                          isDarkMode
                                      ) : Container(),
                                      forecast.predictions[6].dateTime.day.compareTo(DateTime.now().day) == 0 ?
                                      buildForecastToday(
                                          forecast.predictions[6].dateTime.hour.toString()+":"+forecast.predictions[6].dateTime.minute.toString(),
                                          forecast.predictions[6].temperature.toInt(),
                                          forecast.predictions[6].windSpeed.toInt(),
                                          forecast.predictions[6].humidity.toInt(),
                                          "http://openweathermap.org/img/wn/" + forecast.predictions[6].icon +".png",
                                          size,
                                          isDarkMode
                                      ) : Container(),
                                      forecast.predictions[7].dateTime.day.compareTo(DateTime.now().day) == 0 ?
                                      buildForecastToday(
                                          forecast.predictions[7].dateTime.hour.toString()+":"+forecast.predictions[7].dateTime.minute.toString(),
                                          forecast.predictions[7].temperature.toInt(),
                                          forecast.predictions[7].windSpeed.toInt(),
                                          forecast.predictions[7].humidity.toInt(),
                                          "http://openweathermap.org/img/wn/" + forecast.predictions[7].icon +".png",
                                          size,
                                          isDarkMode
                                      ) : Container(),
                                      forecast.predictions[8].dateTime.day.compareTo(DateTime.now().day) == 0 ?
                                      buildForecastToday(
                                          forecast.predictions[8].dateTime.hour.toString()+":"+forecast.predictions[8].dateTime.minute.toString(),
                                          forecast.predictions[8].temperature.toInt(),
                                          forecast.predictions[8].windSpeed.toInt(),
                                          forecast.predictions[8].humidity.toInt(),
                                          "http://openweathermap.org/img/wn/" + forecast.predictions[8].icon +".png",
                                          size,
                                          isDarkMode
                                      ) : Container(),

                                    ]
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.02,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: Colors.white.withOpacity(0.05),
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: size.height * 0.02,
                                  left: size.width * 0.03,
                                ),
                                child: Text(
                                  '5 Günlük tahminler',
                                  style: GoogleFonts.questrial(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: size.height * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            Padding(
                              padding: EdgeInsets.all(size.width * 0.005),
                              child: Column(
                                children: [
                                  //TODO: change weather forecast from local to api get
                                  forecast.predictions[0].dateTime.day.compareTo(DateTime.now().day) != 0 ?
                                   buildSevenDayForecast(
                                      DateFormatter.dateTime(forecast.predictions[0].dateTime),
                                      forecast.predictions[0].minTemperature.toInt(),
                                      forecast.predictions[0].maxTemperature.toInt(),
                                      "http://openweathermap.org/img/wn/" + forecast.predictions[0].icon +".png",
                                      size,
                                      isDarkMode
                                  ): Container(),

                                  forecast.predictions[1].dateTime.day.compareTo(DateTime.now().day) != 0 ?
                                  buildSevenDayForecast(
                                      DateFormatter.dateTime(forecast.predictions[1].dateTime),
                                      forecast.predictions[1].minTemperature.toInt(),
                                      forecast.predictions[1].maxTemperature.toInt(),
                                      "http://openweathermap.org/img/wn/" + forecast.predictions[1].icon +".png",
                                      size,
                                      isDarkMode
                                  ): Container(),

                                  forecast.predictions[2].dateTime.day.compareTo(DateTime.now().day) != 0 ?
                                  buildSevenDayForecast(
                                      DateFormatter.dateTime(forecast.predictions[2].dateTime),
                                      forecast.predictions[2].minTemperature.toInt(),
                                      forecast.predictions[2].maxTemperature.toInt(),
                                      "http://openweathermap.org/img/wn/" + forecast.predictions[2].icon +".png",
                                      size,
                                      isDarkMode
                                  ): Container(),

                                  forecast.predictions[3].dateTime.day.compareTo(DateTime.now().day) != 0 ?
                                  buildSevenDayForecast(
                                      DateFormatter.dateTime(forecast.predictions[3].dateTime),
                                      forecast.predictions[3].minTemperature.toInt(),
                                      forecast.predictions[3].maxTemperature.toInt(),
                                      "http://openweathermap.org/img/wn/" + forecast.predictions[3].icon +".png",
                                      size,
                                      isDarkMode
                                  ): Container(),

                                  forecast.predictions[4].dateTime.day.compareTo(DateTime.now().day) != 0 ?
                                  buildSevenDayForecast(
                                      DateFormatter.dateTime(forecast.predictions[4].dateTime),
                                      forecast.predictions[4].minTemperature.toInt(),
                                      forecast.predictions[4].maxTemperature.toInt(),
                                      "http://openweathermap.org/img/wn/" + forecast.predictions[4].icon +".png",
                                      size,
                                      isDarkMode
                                  ): Container(),

                                  forecast.predictions[5].dateTime.day.compareTo(DateTime.now().day) != 0 ?
                                  buildSevenDayForecast(
                                      DateFormatter.dateTime(forecast.predictions[5].dateTime),
                                      forecast.predictions[5].minTemperature.toInt(),
                                      forecast.predictions[5].maxTemperature.toInt(),
                                      "http://openweathermap.org/img/wn/" + forecast.predictions[5].icon +".png",
                                      size,
                                      isDarkMode
                                  ): Container(),

                                  forecast.predictions[6].dateTime.day.compareTo(DateTime.now().day) != 0 ?
                                  buildSevenDayForecast(
                                      DateFormatter.dateTime(forecast.predictions[6].dateTime),
                                      forecast.predictions[6].minTemperature.toInt(),
                                      forecast.predictions[6].maxTemperature.toInt(),
                                      "http://openweathermap.org/img/wn/" + forecast.predictions[6].icon +".png",
                                      size,
                                      isDarkMode
                                  ): Container(),


                                  forecast.predictions[7].dateTime.day.compareTo(DateTime.now().day) != 0 ?
                                  buildSevenDayForecast(
                                      DateFormatter.dateTime(forecast.predictions[7].dateTime),
                                      forecast.predictions[7].minTemperature.toInt(),
                                      forecast.predictions[7].maxTemperature.toInt(),
                                      "http://openweathermap.org/img/wn/" + forecast.predictions[7].icon +".png",
                                      size,
                                      isDarkMode
                                  ): Container(),

                                  forecast.predictions[8].dateTime.day.compareTo(DateTime.now().day) != 0 ?
                                  buildSevenDayForecast(
                                      DateFormatter.dateTime(forecast.predictions[8].dateTime),
                                      forecast.predictions[8].minTemperature.toInt(),
                                      forecast.predictions[8].maxTemperature.toInt(),
                                      "http://openweathermap.org/img/wn/" + forecast.predictions[8].icon +".png",
                                      size,
                                      isDarkMode
                                  ): Container(),

                                  forecast.predictions[9].dateTime.day.compareTo(DateTime.now().day) != 0 ?
                                  buildSevenDayForecast(
                                      DateFormatter.dateTime(forecast.predictions[9].dateTime),
                                      forecast.predictions[9].minTemperature.toInt(),
                                      forecast.predictions[9].maxTemperature.toInt(),
                                      "http://openweathermap.org/img/wn/" + forecast.predictions[9].icon +".png",
                                      size,
                                      isDarkMode
                                  ): Container(),

                                  forecast.predictions[10].dateTime.day.compareTo(DateTime.now().day) != 0 ?
                                  buildSevenDayForecast(
                                      DateFormatter.dateTime(forecast.predictions[10].dateTime),
                                      forecast.predictions[10].minTemperature.toInt(),
                                      forecast.predictions[10].maxTemperature.toInt(),
                                      "http://openweathermap.org/img/wn/" + forecast.predictions[10].icon +".png",
                                      size,
                                      isDarkMode
                                  ): Container(),

                                  forecast.predictions[11].dateTime.day.compareTo(DateTime.now().day) != 0 ?
                                  buildSevenDayForecast(
                                      DateFormatter.dateTime(forecast.predictions[11].dateTime),
                                      forecast.predictions[11].minTemperature.toInt(),
                                      forecast.predictions[11].maxTemperature.toInt(),
                                      "http://openweathermap.org/img/wn/" + forecast.predictions[11].icon +".png",
                                      size,
                                      isDarkMode
                                  ): Container(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget buildSevenDayForecast(String time, int minTemp, int maxTemp,
      String weatherIcon, size, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(
        size.height * 0.005,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                ),
                child: Text(
                  time,
                  style: GoogleFonts.questrial(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: size.height * 0.025,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.25,
                ),
                child: Image.network(
                  weatherIcon,
                  fit: BoxFit.scaleDown,
                ),
              ),
              Align(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: size.width * 0.15,
                  ),
                  child: Text(
                    '$minTemp˚C',
                    style: GoogleFonts.questrial(
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                      fontSize: size.height * 0.025,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                  ),
                  child: Text(
                    '$maxTemp˚C',
                    style: GoogleFonts.questrial(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: size.height * 0.025,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ],
      ),
    );
  }


  Widget buildForecastToday(String time, int temp, int wind, int rainChance,
      String weatherIcon, size, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.025),
      child: Column(
        children: [
          Text(
            time,
            style: GoogleFonts.questrial(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: size.height * 0.02,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.005,
                ),
                child: Image.network(
                  weatherIcon
                ),
              ),
            ],
          ),
          Text(
            '$temp˚C',
            style: GoogleFonts.questrial(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: size.height * 0.025,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                ),
                child: FaIcon(
                  FontAwesomeIcons.wind,
                  color: Colors.grey,
                  size: size.height * 0.03,
                ),
              ),
            ],
          ),
          Text(
            '$wind km/h',
            style: GoogleFonts.questrial(
              color: Colors.grey,
              fontSize: size.height * 0.02,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                ),
                child: FaIcon(
                  FontAwesomeIcons.umbrella,
                  color: Colors.blue,
                  size: size.height * 0.03,
                ),
              ),
            ],
          ),
          Text(
            '$rainChance %',
            style: GoogleFonts.questrial(
              color: Colors.blue,
              fontSize: size.height * 0.02,
            ),
          ),
        ],
      ),
    );
  }

}
