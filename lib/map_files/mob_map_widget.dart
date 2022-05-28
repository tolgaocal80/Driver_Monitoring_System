import 'dart:async';
import 'package:driver_monitoring_system/pythonComponents/single_caruser.dart';
import 'package:driver_monitoring_system/user_dao/car_user.dart';
import 'package:driver_monitoring_system/weather/common/date_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_constants.dart';
import 'map_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart' as lot;
import 'package:firebase_database/firebase_database.dart';

MapWidget getMapWidget() => MobileMap();

class MobileMap extends StatefulWidget implements MapWidget {
  MobileMap({Key? key}) : super(key: key);

  @override
  State<MobileMap> createState() => MobileMapState();
}

class MobileMapState extends State<MobileMap> with TickerProviderStateMixin{

  // GPS Position
  late Position position;
  // Create Map Controller
  late GoogleMapController mapController;
  // Current Location
  late LatLng currentLocation;

  MapType _currentMapType = MapType.normal;
  final Color _mapButtonsColor = Colors.white;

  late final AnimationController _changeMapTypeAnimationController;
  late final AnimationController _getMyLocationAnimationController;
  late final AnimationController _getCarLocationAnimationController;

  // Assign Map Controller
  void _onMapCreated(GoogleMapController gController) {
    mapController = gController;
    checkGPSPermission();
  }

  DatabaseReference reference = SingleCarUser.instance.ref;

  getCurrentLocationFromPosition() {
    return LatLng(position.latitude, position.longitude);
  }

  String userId = FirebaseAuth.instance.currentUser!.uid;

  void saveData({required String latitude, required String longitude, required String status, required String leftWarning, required String rightWarning}) async{
    CarUser carUser = SingleCarUser.instance.carUser;

    carUser.latitude = latitude;
    carUser.longitude = longitude;
    carUser.status = status;
    carUser.time = DateFormatter.dateTime(DateTime.now());
    carUser.leftWarning = leftWarning;
    carUser.rightWarning = rightWarning;

    await reference.child('users/${carUser.uid}').push().set(carUser.toJson());
  }

  Set<Marker> _markers = {};

  Future<void> updateUserData({required String latitude, required String longitude, required String status, required String leftWarning, required String rightWarning}) async {
    CarUser carUser = SingleCarUser.instance.carUser;

    carUser.latitude = latitude;
    carUser.longitude = longitude;
    carUser.status = status;
    carUser.time = DateFormatter.dateTime(DateTime.now());
    carUser.leftWarning = leftWarning;
    carUser.rightWarning = rightWarning;

    await reference.child('users/${carUser.uid}')
        .update(carUser.toJson());
  }

  @override
  void initState() {
    super.initState();
    _changeMapTypeAnimationController = AnimationController(vsync: this)..value = 0;
    _getMyLocationAnimationController = AnimationController(vsync: this)..value = 0;
    _getCarLocationAnimationController = AnimationController(vsync: this)..value = 0;

    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) => position = value);

    reference.child("users/$userId").onValue.listen((DatabaseEvent event) {

      if(!event.snapshot.exists){
        print("FIREBASE STORAGE EXCEPTION");
        throw FirebaseException(plugin: "Fireabase Storage NULL DATA");
      }

      SingleCarUser.instance.carUser = CarUser.fromDataSnapshot(event.snapshot);
      CarUser user = SingleCarUser.instance.carUser;

      print("USER DATA ( STATUS ) : " + user.status);
      print("USER DATA ( LATITUDE ) : " + user.latitude);
      print("USER DATA ( LONGITUDE ) : " + user.longitude);
      print("USER DATA ( UID ) : " + user.uid);
      print("USER DATA ( RIGHT WARNING ) : " + user.rightWarning);
      print("USER DATA ( LEFT WARNING ) : " + user.leftWarning);
      print("USER DATA ( TIME ) : " + user.time);

      _markers.clear();
    });
  }

  // Changes map apperance type
  void _setMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite :MapType.normal;
    });
    _changeMapTypeAnimationController.forward().whenComplete(() => _changeMapTypeAnimationController.reset());
  }

  _goToCurrentLocation() {
    currentLocation = getCurrentLocationFromPosition();
    mapController.animateCamera(CameraUpdate.newLatLngZoom(currentLocation, 15));
  }

  _goToCarLocation() async {
    // Add go to car location method
    _goToCurrentLocation();
  }

  goToLocation(Location location) {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(location.latitude,location.longitude), 15));
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GoogleMap(
            onMapCreated:(gController) => _onMapCreated(gController),
            myLocationEnabled: true,
            compassEnabled: false,
            zoomControlsEnabled: false,
            tiltGesturesEnabled: false,
            mapType: _currentMapType,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            initialCameraPosition: initialCameraPosition,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30,horizontal: 10),
          child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: FloatingActionButton(
                      child: Column(
                        children: [
                          Transform.scale(
                              scale: 2,
                              child: lot.Lottie.asset(
                                'lib/assets/animations/map-type-button.json',
                                controller: _changeMapTypeAnimationController,
                                width: 50,
                                height: 50,
                                onLoaded: (composition) {
                                  setState(() {
                                    _changeMapTypeAnimationController.duration = composition.duration;
                                  });
                                },
                              )
                          ),
                        ],
                      ),
                      backgroundColor: _mapButtonsColor,
                      onPressed: () {
                        _setMapType();
                      //  saveData(longitude: currentLocation.longitude.toString(), latitude: currentLocation.latitude.toString(), status: true, leftWarning: false, rightWarning: false);
                        updateUserData(latitude: position.latitude.toString(), longitude: position.longitude.toString(), status: "false", leftWarning: "false", rightWarning: "false");
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: FloatingActionButton(
                      child: Column(
                        children: [
                          lot.Lottie.asset(
                            'lib/assets/animations/go-to-my-location-button.json',
                            controller: _getMyLocationAnimationController,
                            width: 50,
                            height: 50,
                            onLoaded: (composition) {
                              setState(() {
                                _getMyLocationAnimationController.duration = composition.duration;
                              });
                            },
                          )
                        ],
                      ),
                      backgroundColor: _mapButtonsColor,
                      onPressed: () => {
                        _goToCurrentLocation(),
                        _getMyLocationAnimationController.forward().whenComplete(() => _getMyLocationAnimationController.reset())
                      } ,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: FloatingActionButton(
                      child: Column(
                        children: [
                          lot.Lottie.asset(
                            'lib/assets/animations/gps-car.json',
                            controller: _getCarLocationAnimationController,
                            width: 45,
                            height: 45,
                            onLoaded: (composition) {
                              setState(() {
                                _getCarLocationAnimationController.duration = composition.duration;
                              });
                            },
                          )
                        ],
                      ),
                      backgroundColor: _mapButtonsColor,
                      onPressed: () => {
                        _goToCarLocation(),
                        _getCarLocationAnimationController.forward().whenComplete(() => {_getCarLocationAnimationController.reset()})
                      } ,
                    ),
                  ),

                ],
              )
          ),
        ),
      ],
    );

  }

  checkGPSPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('GPS İzni'),
              content: Text('Bu uygulama, GPS kullanımına ihtiyaç duyar. Devam etmek için gerekli izinleri veriniz.'),
              actions: <Widget>[
                CupertinoDialogAction(
                    child: Text('Hayır'),
                    onPressed: () => {Navigator.of(context).pop()}
                ),
                CupertinoDialogAction(
                    child: Text('İzin ver'),
                    onPressed: () => {Geolocator.requestPermission(), Navigator.of(context).pop(), _goToCurrentLocation()}
                ),
              ],
            ));
        if(permission != LocationPermission.denied) {
          _goToCurrentLocation();
        }
      }else if(permission != LocationPermission.denied) {
        _goToCurrentLocation();
      }
    }else if(permission != LocationPermission.denied) {
      _goToCurrentLocation();
    }
  }
}

// Class which parse the data from database
