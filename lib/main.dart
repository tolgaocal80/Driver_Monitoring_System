
import 'package:driver_monitoring_system/MapScreen.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Sürücü Destek ve Gözlem Sistemi'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  int _selectedIndex = 0;
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
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),

        /*
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          index: _selectedIndex,
          height: 50,
          color: Colors.black,

          items: const <Widget>[
            Icon(Icons.add, size: 30,color: Colors.white),
            Icon(Icons.list, size: 30, color: Colors.white),
            Icon(Icons.compare_arrows, size: 30, color: Colors.white),
          ],
          onTap: (index) {
            _onItemTapped(index);
          },
        ),
         */
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            SalomonBottomBarItem(
              icon: Icon(Icons.map),
              title: Text("Harita"),
              selectedColor: Colors.teal,
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.dataset),
              title: Text("Anasayfa"),
              selectedColor: Colors.purple,
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.videocam_rounded),
              title: Text("Kamera"),
              selectedColor: Colors.orange,
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            Center(
              child: Text(_selectedIndex.toString()),
            ),
            MapScreen()

          ],
        ),
      ),

    );
  }
}
