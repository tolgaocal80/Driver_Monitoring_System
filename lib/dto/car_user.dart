import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CarUser {

   String userName;
   LatLng userLocation;
   Position position;

  String carModel;

   CarUser(this.userName, this.userLocation, this.position, this.carModel);

}





