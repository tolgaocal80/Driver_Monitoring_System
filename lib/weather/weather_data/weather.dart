/*
Hava durumu model sınıfı
 */

class Weather {
    
    final String name;
    final String description;
    final String icon;
    final double temperature;
    final double minTemperature;
    final double maxTemperature;
    final double pressure;
    final double humidity;
    final double windSpeed;
    final DateTime dateTime;

    Weather({required this.name, required this.description, required this.icon, required this.temperature, required this.minTemperature, required this.maxTemperature, required this.pressure, required this.humidity, required this.windSpeed, required this.dateTime});

}