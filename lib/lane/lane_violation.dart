import 'package:driver_monitoring_system/pythonComponents/single_caruser.dart';
import 'package:driver_monitoring_system/user_dao/car_user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LaneCheck extends StatefulWidget {
  const LaneCheck({Key? key}) : super(key: key);

  @override
  State<LaneCheck> createState() => _LaneCheckState();
}

class _LaneCheckState extends State<LaneCheck> {

  String leftLaneText = "";
  String rightLaneText = "";

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

      print("USER LANE VIOLATION CHANGED");

      setState(() {
        leftLaneText = user.leftWarning;
        rightLaneText = user.rightWarning;
      });

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

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.008,),
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.01, vertical: size.width*0.01),
            margin: EdgeInsets.symmetric(vertical: size.width*0.003),
            width: size.width * 0.4,
            height: size.width * 0.3,
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            child: Column(
              children: [
                Text("Şerit İhlali", style: _annotationTextStyle),
                const Divider(
                  color: Colors.white,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    // LEFT WARNING ICON
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Icon(Icons.warning_amber_outlined, color: leftLaneText == "true" ? Colors.redAccent : Colors.black, size: 40),
                    ),

                    // RIGHT WARNING ICON
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Icon(Icons.warning_amber_outlined, color: rightLaneText == "true" ? Colors.redAccent : Colors.black, size: 40),
                    ),

                  ],
                )
              ],

            )
        )
    );

  }


}
