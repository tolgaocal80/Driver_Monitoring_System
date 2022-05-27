import 'package:driver_monitoring_system/weather/weather_data/weather_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'map_files/map_screen.dart';
import 'weather/weather_data/weather_use_case.dart';
import 'weather/weather_widgets/current_weather_widget.dart';

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

  User carUser = FirebaseAuth.instance.currentUser!;
  late WeatherUseCase useCase;

  @override
  void initState() {
    super.initState();
    useCase = WeatherBuilder().build();
  }

  @override
  Widget build(BuildContext context) {

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
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
               DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: carUser.displayName!=null ? Text(carUser.displayName.toString().toUpperCase() +
                    '\n'+ carUser.email.toString()) : const Text("Tolga OCAL")
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
            Center(
              child: Text(" Kamera ekranı"),
            )
          ],
        ),
      ),

    );
  }
}
