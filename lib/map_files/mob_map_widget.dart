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

  final DatabaseReference ref = FirebaseDatabase.instanceFor(app: Firebase.app(),databaseURL: "https://ytu-surucu-destek-sistemi-default-rtdb.europe-west1.firebasedatabase.app").ref();

  getCurrentLocationFromPosition() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high) ;
    return LatLng(position.latitude, position.longitude);
  }

  void saveData() async{
    await ref.child('users').push().set({
      "name": "John",
      "age": 18,
      "address": {
        "line1": "100 Mountain View"
      }
    });
  }


  @override
  void initState() {
    super.initState();
    _changeMapTypeAnimationController = AnimationController(vsync: this)..value = 0;
    _getMyLocationAnimationController = AnimationController(vsync: this)..value = 0;
    _getCarLocationAnimationController = AnimationController(vsync: this)..value = 0;
  }

  String userId = FirebaseAuth.instance.currentUser!.uid;

  // Changes map apperance type
  void _setMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite :MapType.normal;
    });
    _changeMapTypeAnimationController.forward().whenComplete(() => _changeMapTypeAnimationController.reset());
  }

  _goToCurrentLocation() async {
    currentLocation = await getCurrentLocationFromPosition();
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
                        saveData();
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