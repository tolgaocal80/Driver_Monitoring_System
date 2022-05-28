import 'dart:collection';
import 'package:firebase_database/firebase_database.dart';

class CarUser {

   String latitude;
   String longitude;
   String status;
   String time;
   String uid;
   String leftWarning;
   String rightWarning;

  CarUser(this.latitude, this.longitude, this.status, this.time, this.uid, this.leftWarning, this.rightWarning);

  CarUser.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'],
        status = json['status'],
        time = json['time'],
        uid = json['uid'],
        leftWarning = json['leftWarning'],
        rightWarning = json['rightWarning'];

  CarUser.fromDataSnapshot(DataSnapshot snapshot)
      :
        latitude = (snapshot.value as LinkedHashMap<dynamic, dynamic>)['latitude'],
        longitude = (snapshot.value as LinkedHashMap<dynamic, dynamic>)['longitude'],
        status = (snapshot.value as LinkedHashMap<dynamic, dynamic>)['status'],
        time = (snapshot.value as LinkedHashMap<dynamic, dynamic>)['time'],
        uid = (snapshot.value as LinkedHashMap<dynamic, dynamic>)['uid'],
        leftWarning = (snapshot.value as LinkedHashMap<dynamic, dynamic>)['leftWarning'],
        rightWarning = (snapshot.value as LinkedHashMap<dynamic, dynamic>)['rightWarning'];

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'status': status,
    'time': time,
    'uid': uid,
    'leftWarning': leftWarning,
    'rightWarning': rightWarning,
  };

   @override
   String toString() {
     return ('{uid: $uid, status: $status, time: $time, latitude: $latitude, longitude: $longitude, leftWarning: $leftWarning, rightWarning: $rightWarning}');
   }

}