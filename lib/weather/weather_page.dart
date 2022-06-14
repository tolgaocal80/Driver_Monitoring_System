import 'package:driver_monitoring_system/lane/lane_violation.dart';
import 'package:driver_monitoring_system/pythonComponents/single_caruser.dart';
import 'package:driver_monitoring_system/weather/common/date_formatter.dart';
import 'package:driver_monitoring_system/weather/weather_data/forecast.dart';
import 'package:driver_monitoring_system/weather/weather_data/weather.dart';
import 'package:driver_monitoring_system/weather/weather_data/weather_result.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../speedometer/dash_screen.dart';
import '../user_dao/car_user.dart';

/*

WeatherHomePage sınıfı birçok fonksiyonu içerisinde barındırır:

Uygulamada gösterilen özelliklerde kullanılan veriler, uygulamaya Firebase Realtime Database üzerinden gelmektedir. Herhangi bir değişim direkt
olarak uygulamaya yansıtılır ve bu sayede anlık değişimler ekranda gösterilir.

1- Raspberry Pi'den gelen kullanıcı konumunu ve bilgilerini kullanarak sürücünün bulunduğu konumdaki günlük ve 3 günlük hava durumu bilgilerini ekranda gösterir.

2- Database den gelen verilere göre sürücünün bulunduğu son konum ekranda, metin olarak gösterilir. Ayrıca bu konum her 20 saniyede güncellenir.
Güncelleme yapılırken en son gelen veriden alınan 'time' (Raspberry Pi den gönderilme zamanı, gönderilirken veriler arasına eklenir) bilgisi ile
şu anki zaman kıyaslanır ve arada 20 saniye fark varsa ekranda yer alan son konum güncellenir. Database'ye gönderilen veriler arasında konum bilgileri ve
zaman değerleri aynı anda gönderildiği için hangi zamanda nerede olunduğu kesin olarak bilinebilir.

3- Azami Fren mesafesi fonksiyonu, sürücünün hız bilgisini ve karşısına çıkan tehdide karşı göstereceği ortalama tepki süresini kullanarak,
şu anki hızında seyir halinde iken olası acil durum freninde aracın ortalama ne kadar mesafe sonra tam olarak duracağını hesaplayan bir fonksiyondur.


Durma mesafesi, fren mesafesinden oldukça uzundur. Tehlike algılandığında başlar ve araç
durduğunda sona erer. Bu nedenle tepki mesafesi ve fren mesafesi toplamlarından oluşur.
Gerekli durma mesafesini hesaplamak için bu iki değerin toplanması gerekir.

Tepki mesafesi:

Reaksiyon mesafesi şunlardan etkilenir:

-Arabanın hızı (oransal artış):
2 x daha yüksek hız = 2 x daha uzun reaksiyon mesafesi.
5 x daha yüksek hız = 5 x daha uzun reaksiyon mesafesi.
-Tepki süreniz
    -Normalde 0,5–2 saniye.
    -45-54 yaşındakiler trafikte en iyi tepki süresine sahiptir.
    -18-24 yaşındakiler ve 60 yaşın üzerindekiler trafikte aynı tepki süresine sahip.
    Gençlerin daha keskin duyuları var ama yaşlıların daha fazla deneyimi var.

Reaksiyon mesafesi şu şekilde azaltılabilir:
-Tehlikelerin öngörülmesi.
-Hazırlık

Reaksiyon mesafesi şu şekilde artırılabilir:

-Karar verme gerekliliği (örneğin, fren yapmak veya yoldan çıkmak arasında).
-Alkol, uyuşturucu ve ilaç.
-Yorgunluk.


Reaksiyon mesafesini hesaplama:

Formül: d = (s * r) / 3.6

d = metre cinsinden tepki mesafesi (hesaplanacak).
s = km/h cinsinden hız.
r = saniye cinsinden tepki süresi.
3.6 = km/s'yi m/s'ye dönüştürmek için sabit rakam.

50 km/s hız ve 1 saniye tepki süresi ile hesaplama örneği:

(50 * 1) / 3.6 = 13,9 metre reaksiyon mesafesi.

Fren mesafesi:

Fren mesafesi, frene başladığınız andan araç durana kadar aracın kat ettiği mesafedir.

Fren mesafesi şunlardan etkilenir:

-Aracın hızı (kuadratik artış; "2'nin üssü ile yükselir"):
-2 kat daha yüksek hız = 4 kat daha uzun fren mesafesi.
-3 kat daha yüksek hız = 9 kat daha uzun fren mesafesi.
-Yol (gradyan ve koşullar).
-Yük.
-Frenler (durum, frenleme teknolojisi ve kaç tekerleğin fren yaptığı).


Fren mesafesini hesaplama

Yol koşulları ve lastiklerin tutuşu büyük ölçüde değişebileceğinden, güvenilir fren mesafesi hesaplamaları yapmak çok zordur.
Örneğin yolda buz olduğunda fren mesafesi 10 kat daha uzun olabilir.


Fren mesafesini hesaplayın

Koşullar: İyi lastikler ve iyi frenler.

Formül: d = s2 / (250 * f)

d = metre cinsinden fren mesafesi (hesaplanacak).
s = km/h cinsinden hız.
250 = her zaman kullanılan sabit rakam.
f = sürtünme katsayısı, yakl. 0,8 kuru asfaltta ve 0,1 buzda.

Kuru asfaltta 50 km/s hızla hesaplama örneği:

(50^2) / (250 * 0.8) = 12,5 metre fren mesafesi


Durma mesafesi:

Durma mesafesi = tepki mesafesi + fren mesafesi


Fonksiyonda aşağıdaki gibi iyi bir tahmin ile fren mesafesi hesaplanmıştır.

int breakingDistance = ((speedKm/3.6) + ((speedKm * speedKm) / (250 * 0.8))).toInt();




KAYNAK:

https://korkortonline.se/en/theory/reaction-braking-stopping/
https://mobilityblog.tuv.com/en/calculating-stopping-distance-braking-is-not-a-matter-of-luck/


 */


class WeatherHomePage extends StatefulWidget {
   WeatherHomePage( {Key? key, required this.weatherResult}) : super(key: key);

   WeatherResult weatherResult;

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {

  late Position currentPosition;
  String locationAddress = "";
  List<Placemark> placemarks = [];
  CarUser carUser = SingleCarUser.instance.carUser;
  Placemark place = Placemark();
  double speedKm = 0;
  int breakingDistance = 0;

  DatabaseReference reference = SingleCarUser.instance.ref;

  @override
  void initState() {
    super.initState();

    reference.child("users/${carUser.uid}").onValue.listen((DatabaseEvent event) {

      if(!event.snapshot.exists){
        print("FIREBASE STORAGE NULL VALUE RECEIVED");
      }

      SingleCarUser.instance.carUser = CarUser.fromDataSnapshot(event.snapshot);

      CarUser user = SingleCarUser.instance.carUser;

      // FOR DEBUG PURPOSES
      print("USER DATA ( LATITUDE ) : " + user.latitude);
      print("USER DATA ( LONGITUDE ) : " + user.longitude);
      print("USER DATA ( UID ) : " + user.uid);
      print("USER DATA ( SPEED ) : " + user.gpsSpeed);

      locationAddress = "";
      var lat = double.parse(user.latitude);
      var longitude = double.parse(user.longitude);

      placemarkFromCoordinates(lat,longitude).then((value) => placemarks = value);

      place = placemarks[0];

      setState(() {
        speedKm = (double.parse(user.gpsSpeed) * 3.6);
        breakingDistance = ( (speedKm/3.6) + ((speedKm * speedKm) / (250 * 0.8)) ).toInt();
        locationAddress = "${place.thoroughfare}, ${place.subLocality}\n"
            "${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}";
      });

    });

  }

  @override
  Widget build(BuildContext context) {

    Weather weather = widget.weatherResult.weather;
    Forecast forecast = widget.weatherResult.forecast;

    String cityName = weather.name; //city name

    const TextStyle _annotationTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: size.width * 0.008, vertical: size.width * 0.008,),
                          child: Column(
                            children: [
                              Container(
                                width: size.width * 0.46,
                                height: size.width * 0.3,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.075),
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
                              const SizedBox(
                                height: 2,
                              ),
                              Container(
                                width: size.width * 0.46,
                                height: size.width * 0.59,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.075),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                      ),
                                      child: Align(
                                        child: Text(
                                          cityName,
                                          style: GoogleFonts.questrial(
                                            color: isDarkMode ? Colors.white : Colors.black,
                                            fontSize: size.height * 0.045,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 2,
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
                                        top: 4,
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
                                            fontSize: size.height * 0.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 2,
                                      ),
                                      child: Align(
                                        child: Text(
                                          weather.description.replaceFirst(weather.description.characters.first, weather.description.characters.first.toUpperCase()), // weather
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
                                        top: size.height * 0.01,
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: size.width * 0.008, vertical: size.width * 0.008,),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              DashScreen(),
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.01, vertical: size.width*0.01),
                                  margin: EdgeInsets.symmetric(vertical: size.width*0.003),
                                  width: size.width * 0.5,
                                  height: size.width * 0.3,
                                  alignment: Alignment.centerLeft,
                                  decoration: const BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.all(Radius.circular(20))
                                  ),
                                  child: Column(
                                    children: [
                                      Text("Fren Mesafesi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                      Divider(
                                        color: Colors.white,
                                      ),
                                      Text(
                                          breakingDistance.toString(),
                                          style: const TextStyle(color: Colors.teal, fontSize: 36)
                                      )
                                    ],
                                  )
                              ),
                            ],
                          )
                        ),
                      ]
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: size.width * 0.008,),
                          child: Container(
                            width: size.width * 0.55,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.075),
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
                        LaneCheck()
                      ],
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
                                  '3 Günlük tahminler',
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


  // Ekranda gösterilen 3 günlük hava durumu bilgilerini oluşturan fonksiyon
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

// Ekranda gösterilen anlık hava durumu bilgilerini oluşturan fonksiyon
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
