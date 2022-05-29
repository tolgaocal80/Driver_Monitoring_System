import 'package:google_maps_flutter/google_maps_flutter.dart';


/*

Harita ekranında kullanılan sabit değerler, kolaylık ve açık görünürlük açısından ayrı bir sınıfta tutulmuştur.
Harita ekranı için gerekli bazı başlangıç (default) değerleri içerir.

 */


/// Map Settings
const LatLng SOURCE_LOCATION = LatLng(41.0082, 28.9784);
const double CAMERA_ZOOM = 15;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;

CameraPosition initialCameraPosition = const CameraPosition(
    zoom: CAMERA_ZOOM,
    tilt: CAMERA_TILT,
    bearing: CAMERA_BEARING,
    target: SOURCE_LOCATION
);
