import 'package:driver_monitoring_system/user_dao/car_user.dart';
import 'package:driver_monitoring_system/weather/common/date_formatter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/*

Uygulamada bir kere oturum açıldıktan sonra ve bir kullanıcı nesnesi oluşturulduktan sonra
sürekli bu nesne üzerinden işlem yapılması gerektiği için ve gereksiz hafıza kullanımının önüne geçilmek
istendiğinden programlama tasarım kalıplarından (design patterns) sık kullanılan 'Singleton' kalıbı kullanılmıştır. Bu sınıfta bu işlemin
yapıldığı belirtilmiştir.

- Her yerden erişibilen tek (single) DatabaseReference nesnesi (Firebase Realtime Database nesnesi) ve
- Uygulama genelinde kullanılan 'CarUser' sınıfından 'carUser' nesnesi oluşturulmuştur.

 */


class SingleCarUser {

  static SingleCarUser _instance = SingleCarUser._();
  SingleCarUser._();
  static SingleCarUser get instance => _instance;
  
  CarUser carUser = CarUser("41.029112", "28.890270", "false", DateFormatter.dateTime(DateTime.now()), "TX3SudStPQSDPViRvZ9kaOlmw4H2", "false", "false");

  DatabaseReference ref = FirebaseDatabase.instanceFor(app: Firebase.app(),databaseURL: "https://ytu-surucu-destek-sistemi-default-rtdb.europe-west1.firebasedatabase.app").ref();

}
