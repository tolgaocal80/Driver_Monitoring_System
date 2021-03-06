import 'package:driver_monitoring_system/weather/weather_data/weather_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'camera_components/cam_screen.dart';
import 'login/screens/login_page.dart';
import 'map_files/map_screen.dart';
import 'weather/weather_data/weather_use_case.dart';
import 'weather/weather_widgets/current_weather_widget.dart';


/*

Uygulama anasayfası. Bilgiler ekranı ile başlar.

 */


class MyHomePage extends StatefulWidget {
  const MyHomePage(User user, {Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  int _selectedIndex = 1;
  Future<bool> _onWillPop() async {
    return (
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Emin misiniz?'),
            content: const Text('Uygulamadan çıkmak üzeresiniz!',style: TextStyle(fontSize: 20),),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Hayır', style: const TextStyle(fontSize: 16),),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Çık', style: const TextStyle(fontSize: 16),),
              ),
            ],
          ),
        )) ?? false;
  }
  bool _isSigningOut = false;

  User carUser = FirebaseAuth.instance.currentUser!;
  late WeatherUseCase useCase;
  late WeatherUseCase useCaseCarUser;

  @override
  void initState() {
    super.initState();
    useCase = WeatherBuilder().build();
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(

      onWillPop: _onWillPop,
      child: Scaffold(

        appBar: AppBar(
          title: const Text("Driver Support and Monitoring"),
          centerTitle: true,
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
        ),

        drawer:Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
               DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: carUser.displayName!=null ? Text(carUser.displayName.toString().toUpperCase() +
                    '\n'+ carUser.email.toString()) : Text(carUser.displayName.toString())
              ),
              ListTile(
                leading: Icon(
                  Icons.home,
                ),
                title: const Text('Toyota COROLLA 2020'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.train,
                ),
                title: const Text('Raspberry Pi Model 2'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            _isSigningOut ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: () async {
                  setState(() {
                    _isSigningOut = true;
                  });
                  await FirebaseAuth.instance.signOut();

                  setState(() {
                    _isSigningOut = false;
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()));
                  },
              child: Text('Çıkış Yap'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            )],
        )
            ],
          ),
        ),

        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.map),
              title: const Text("Harita"),
              selectedColor: Colors.teal,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.dataset),
              title: const Text("Anasayfa"),
              selectedColor: Colors.purple,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.videocam_rounded),
              title: const Text("Kamera"),
              selectedColor: Colors.orange,
            ),
          ],
        ),

        body: IndexedStack(
          index: _selectedIndex,
          children: [
            MapScreen(),
            CurrentWeatherPage(weatherUseCase: useCase,),
            MyHomePage2()
          ],
        ),
      ),
    );
  }
}
