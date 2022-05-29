import 'package:intl/intl.dart';

/*

Şu anki zamanı istenilen formata getiren genel yardımcı sınıf.

 */


class DateFormatter {

  static String date(DateTime dt) {
    DateFormat formatter = DateFormat('d/M/yy');
    return formatter.format(dt);
  }

  static String dateTime(DateTime dt) {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dt);
  }
  
}