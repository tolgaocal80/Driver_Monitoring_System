import 'package:audioplayers/audioplayers.dart';
import 'package:driver_monitoring_system/pythonComponents/single_caruser.dart';
import 'package:driver_monitoring_system/user_dao/car_user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/*
LaneCheck sınıfı, Raspberry Pi cihazı üzerine bağlanmış olan ultrasonik yakınlık sensörlerinden
gelen verileri değenlendirir ve aracın hangi tarafında (sağ yada sol) engel (araç, yaya)
olduğunu mobil uygulama üzerinde anlık olarak gösterir, bunu Google şirketi tarafından sunulan NoSQL tabanlı
veritabanı Firebase Realtime Database şeklinde gerçekleştirmekteyiz. Veritabanına yapılan bütün değişiklikler
anlık olarak uygulamaya yansır. Bu, şerit değiştirirken yaşanabilecek kazaları engellenmeye yardımcı olur.

Uygulama ekranında sağ ikaz ve sol ikaz olarak görünür.

 */

class LaneCheck extends StatefulWidget {
  const LaneCheck({Key? key}) : super(key: key);

  @override
  State<LaneCheck> createState() => _LaneCheckState();
}

class _LaneCheckState extends State<LaneCheck> {

  String leftLaneText = "";
  String rightLaneText = "";

  String frontSensor = "False";

  final player = AudioPlayer();
  final musicCache = AudioCache();

  void playLoopedMusic() async {
    await player.setSourceAsset('warning.mp3');
    await player.setReleaseMode(ReleaseMode.loop);
    await player.resume();
  }

  void stopMusic() {
    player.stop();
  }

  @override
  void initState(){
    super.initState();

    DatabaseReference reference = SingleCarUser.instance.ref;
    CarUser usr = SingleCarUser.instance.carUser;

    reference.child("users/${usr.uid}").onValue.listen((DatabaseEvent event) {

      if(!event.snapshot.exists){
        print("FIREBASE STORAGE EXCEPTION");
      }

      SingleCarUser.instance.carUser = CarUser.fromDataSnapshot(event.snapshot);
      CarUser user = SingleCarUser.instance.carUser;

      print(user);



      setState(() {
        leftLaneText = user.leftWarning;
        rightLaneText = user.rightWarning;
        frontSensor = user.frontWarning;
      });

      if(frontSensor == "True"){
        playLoopedMusic();
      }else{
        stopMusic();
      }

    });
  }


  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    const TextStyle _annotationTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Column(
      children: [

        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.008),
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
              width: size.width * 0.4,
              height: size.width * 0.2,
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Column(
                children: [
                  Text("Şerit İhlali", style: _annotationTextStyle),
                  const Divider(
                    color: Colors.white,
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      // LEFT WARNING ICON
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.warning_amber_outlined, color: leftLaneText == "True" ? Colors.redAccent : Colors.black, size: 40),
                      ),

                      // RIGHT WARNING ICON
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.warning_amber_outlined, color: rightLaneText == "True" ? Colors.redAccent : Colors.black, size: 40),
                      ),

                    ],
                  )
                ],


              )
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.008),
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
              margin: EdgeInsets.only(top: 1),
              width: size.width * 0.4,
              height: size.width * 0.25,
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),

              child: Column(
                children: [
                  Text(frontSensor=="True" ? " Azami Fren Mesafesi Aşıldı" : "Güvenli Mesafe",
                      style: TextStyle(color: frontSensor == "True" ? Colors.redAccent : Colors.green, fontSize: frontSensor=="True"? 24 : 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
          ),
        ),
      ],

    );


  }


}
