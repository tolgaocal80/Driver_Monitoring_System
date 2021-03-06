import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login/screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

/*

Uygulamanın ilk açıldığı yerdir. Önceden giriş yapmış bir kullanıcı var ise direkt olarak bilgiler ekranına gönderir. Eğer giriş yapmış kullanıcı yoksa
bunun yerine "Giriş yap" ya da "Kayıt ol" sayfalarına yönlendirir.

 */


class MyApp extends StatelessWidget {
   MyApp({Key? key}) : super(key: key);

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Support and Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  user == null ? LoginPage() : MyHomePage(user!),
    );
  }
}
