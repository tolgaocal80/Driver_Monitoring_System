import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LaneViolation extends StatefulWidget {
  const LaneViolation({Key? key}) : super(key: key);

  @override
  State<LaneViolation> createState() => _LaneViolationState();
}

class _LaneViolationState extends State<LaneViolation> {

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
              Divider(
                color: Colors.white,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Icon(Icons.warning_amber_outlined, color: Colors.white, size: 40),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Icon(Icons.warning_amber_outlined, color: Colors.white, size: 40,),
                  ),
                ],
              )

            ],
          )
      ),
    );

  }


}
