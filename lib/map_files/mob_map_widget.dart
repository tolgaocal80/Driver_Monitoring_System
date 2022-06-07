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


/*

Harita ekranını içeren sınıftır. Harita ekranında sürücü konumu "her güncellendiğinde" bu bir
marker (harita işaretleyici) olarak harita üzerinde gösterilir. Bu güncelleme kontrolü ise Firebase veritabanının sürekli
olarak dinlenmesiyle yapılır. Sürücü konum değerleri değiştiği anda anlık olarak harita da yeni marker çizilir.

- Harita ekranında sağ üst köşede bulunan "Harita tipini değiştir" butonu ise Google haritaların görünümünü
uydu yada arazi görünümü arasında değiştirmemizi sağlar.

- Harita ekranında sağ üst köşede bulunan "Konumuma git" butonu, cep telefonu kullanıcısının kendi konumunu
telefon GPS i yardımı ile bulur ve harita ekranını o konuma götürür.

- Harita ekranında sağ üst köşede bulunan "Araç konumuna git" butonu ise araç kullanıcısının lokasyonunu veritabanına
gönderilen anlık konum bilgileri ile bulur ve harita ekranını o konuma götürür.


 */

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

  DatabaseReference reference = SingleCarUser.instance.ref;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  Set<Marker> _markers = {};
  late Marker marker;

  // Assign Map Controller
  void _onMapCreated(GoogleMapController gController) {
    mapController = gController;
    checkGPSPermission();
  }

  getCurrentLocationFromPosition() {
    return LatLng(position.latitude, position.longitude);
  }

  void saveData({required String latitude, required String longitude, required String status, required String leftWarning, required String rightWarning}) async{
    CarUser carUser = SingleCarUser.instance.carUser;

    carUser.latitude = latitude;
    carUser.longitude = longitude;
    carUser.status = status;
    carUser.time = DateFormatter.dateTime(DateTime.now());
    carUser.leftWarning = leftWarning;
    carUser.rightWarning = rightWarning;

    await reference.child('users/${carUser.uid}').set(carUser.toJson());
  }

  Future<void> updateUserData({required String latitude, required String longitude,
    required String status, required String leftWarning, required String rightWarning}) async {
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

  // Harita arayüzünü degistirir
  void _setMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite :MapType.normal;
    });
    _changeMapTypeAnimationController.forward().whenComplete(() => _changeMapTypeAnimationController.reset());
  }

  // Harita ekranını şuanki uygulama kullanıcısı konumuna götürür
  _goToCurrentLocation() {
    currentLocation = getCurrentLocationFromPosition();
    mapController.animateCamera(CameraUpdate.newLatLngZoom(currentLocation, 15));
  }

  // Harita ekranını sürücü konumuna götürür
  _goToCarLocation() async {
    goToMarkerLocation(marker);
  }

  // Harita ekranını marker konumuna götürür
  goToMarkerLocation(Marker locationMarker) {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(locationMarker.position.latitude,locationMarker.position.longitude), 15));
  }

  // Marker oluşturur
  createCarLocationMarker(CarUser user) {
    var lat = double.parse(user.latitude);
    var longitude = double.parse(user.longitude);

    marker = Marker(markerId: MarkerId(user.uid),position: LatLng(lat, longitude), infoWindow: const InfoWindow(title: "Sürücü konumu"));
    return marker;
  }

  @override
  void initState() {
    super.initState();
    _changeMapTypeAnimationController = AnimationController(vsync: this)..value = 0;
    _getMyLocationAnimationController = AnimationController(vsync: this)..value = 0;
    _getCarLocationAnimationController = AnimationController(vsync: this)..value = 0;

    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) => position = value);

    // Veritabanı değişikliklerini sürekli olarak dinler
    reference.child("users/$userId").onValue.listen((DatabaseEvent event) {

      if(!event.snapshot.exists){
        print("FIREBASE STORAGE NULL VALUE RECEIVED");
      }

      SingleCarUser.instance.carUser = CarUser.fromDataSnapshot(event.snapshot);
      CarUser user = SingleCarUser.instance.carUser;

      // FOR DEBUG PURPOSES
      print("USER DATA ( LATITUDE ) : " + user.latitude);
      print("USER DATA ( LONGITUDE ) : " + user.longitude);
      print("USER DATA ( UID ) : " + user.uid);

      setState(() {
        _markers.clear();
        _markers.add(createCarLocationMarker(user));
      });
    });

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
            markers: _markers,
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
                  //      updateUserData(latitude: position.latitude.toString(), longitude: position.longitude.toString(), status: "false", leftWarning: "false", rightWarning: "false");
                        saveData(latitude: position.latitude.toString(), longitude: position.longitude.toString(), rightWarning: "false", leftWarning: "false", status: "true");
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

  // Kullanıcı izinleri sorgular
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