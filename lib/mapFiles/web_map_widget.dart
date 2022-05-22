import 'dart:html';
import 'dart:ui' as ui;
import 'package:driver_monitoring_system/mapFiles/mapConstants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/google_maps.dart';
import 'package:flutter/src/widgets/basic.dart'  as basic;
import 'map_widget.dart';

MapWidget getMapWidget() => WebMap();

class WebMap extends StatefulWidget implements MapWidget {
  WebMap({Key? key}) : super(key: key);

  @override
  State<WebMap> createState() => WebMapState();
}

class WebMapState extends State<WebMap> {
  @override
  Widget build(BuildContext context) {
    final String htmlId = "map";

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
      final mapOptions = MapOptions()
        ..zoom = 15.0
        ..center = LatLng(initialCameraPosition.target.latitude, initialCameraPosition.target.longitude);


      final elem = DivElement()..id = htmlId;
      final map = GMap(elem, mapOptions);

      final camOptions = CameraOptions()
        ..center = LatLng(initialCameraPosition.target.latitude, initialCameraPosition.target.longitude)
        ..zoom = 20;


      map.onCenterChanged.listen((event) {});
      map.onDragstart.listen((event) {});
      map.onDragend.listen((event) {});

      Marker(MarkerOptions()
        ..position = map.center
        ..map = map);

      return elem;
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        HtmlElementView(viewType: htmlId),
        basic.Padding(
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
                          /*
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

                           */

                        ],
                      ),
                      backgroundColor: Colors.white,
                      onPressed: () {
                  //      _setMapType();
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
                          /*
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

                           */

                        ],
                      ),
                      backgroundColor: Colors.white,

                      onPressed: ()  {
                      //  _goToCurrentLocation(),

                     //   _getMyLocationAnimationController.forward().whenComplete(() => _getMyLocationAnimationController.reset())
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
                          /*
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

                           */
                        ],
                      ),
                      backgroundColor: Colors.white,
                      onPressed: () => {
                     //   _goToCarLocation(),
                    //    _getCarLocationAnimationController.forward().whenComplete(() => {_getCarLocationAnimationController.reset()})
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
}