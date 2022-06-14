import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../pythonComponents/single_caruser.dart';
import '../user_dao/car_user.dart';
import 'components/speedometer.dart';
import 'components/tts_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

/*

Hız göstergesi için yardımcı sınıf.
Hızdaki değişimleri gps üzerinden sürekli dinleyerek uygulamaya bildirir. Bu sayede ekran yenilenir ve yeni hız değerleri ekranda gösterilir.

 */

class DashScreen extends StatefulWidget {
  DashScreen({Key? key}) : super(key: key);
  @override
  DashScreenState createState() => DashScreenState();
}

class DashScreenState extends State<DashScreen> {
  SharedPreferences? _sharedPreferences;
  // For text to speed narration of current velocity
  /// Initiate service
  late FlutterTts _ttsService;

  // Create a stream trying to speak speed
  StreamSubscription? _ttsCallback;

  // String that the tts will read aloud, Speed + Expanded Unit
  String get speakText {
    String unit = 'kilometre per hour';
    return '${_velocity!.toStringAsFixed(2)} $unit';
  }

  void _startTTS() {
    _ttsService.setVoice({'name': 'tr-TR-language', 'locale': 'tr-TR'});

    _ttsCallback?.cancel();

    if (_isTTSActive) _ttsService.speak(speakText);
    _ttsCallback =
        Stream.periodic(_ttsDuration + const Duration(seconds: 1)).listen(
              (event) {
            if (_isTTSActive) _ttsService.speak(speakText);
          },
        );
  }

  // Should TTS be talking
  bool _isTTSActive = false;

  void setIsActive(bool isActive) => setState(
        () {
          if(FirebaseAuth.instance.currentUser == null){
            _isTTSActive = false;
            _ttsCallback?.cancel();
          }else{
            _isTTSActive = isActive;
            _sharedPreferences?.setBool('isTTSActive', _isTTSActive);
            if (isActive) {
              _startTTS();
            } else {
              _ttsCallback?.cancel();
            }
          }
    },
  );

  // TTS talk duration
  final Duration _ttsDuration = const Duration(seconds: 9);

  // Current Velocity in km/h
  double? _velocity;

  // Highest recorded velocity so far.
  double? _highestVelocity;

  @override
  void initState() {
    super.initState();

    // Set velocities to zero when app opens
    _velocity = 0;
    _highestVelocity = 0.0;

    DatabaseReference reference = SingleCarUser.instance.ref;
    CarUser usr = SingleCarUser.instance.carUser;

    reference.child("users/${usr.uid}").onValue.listen((DatabaseEvent event) {

      if(!event.snapshot.exists){
        print("FIREBASE STORAGE EXCEPTION");
      }

    //  SingleCarUser.instance.carUser = CarUser.fromDataSnapshot(event.snapshot);

      CarUser user = SingleCarUser.instance.carUser;

      var speedInKm = mpstokmph(double.parse(user.gpsSpeed));

      print("SPEED METER UPDATED");

      setState(() {
        _velocity = speedInKm;
        if (_velocity! > _highestVelocity!) _highestVelocity = _velocity;
      });

    });

    // Set up tts
    _ttsService = FlutterTts();
    _ttsService.setSpeechRate(0.7);

    // Load Saved values (or default values when no saved values)
    SharedPreferences.getInstance().then(
          (SharedPreferences prefs) {
        _sharedPreferences = prefs;
        _isTTSActive = prefs.getBool('isTTSActive') ?? false;
        // Start text to speech service
        _startTTS();
      });
  }

  /// Velocity in m/s to km/hr converter
  double mpstokmph(double mps) => mps * 18 / 5;

  @override
  Widget build(BuildContext context) {
    const double gaugeBegin = 0, gaugeEnd = 180;

    double width = MediaQuery.of(context).size.width / 2;

    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          height: width + 35,
          width: width ,
          child: ListView(
            padding: EdgeInsets.zero,

            children: [

              Container(
                width: width,
                height: width,
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                child: Speedometer(
                  gaugeBegin: gaugeBegin,
                  gaugeEnd: gaugeEnd,
                  velocity: (_velocity!),
                  maxVelocity: (_highestVelocity!),
                ),
              ),

              TextToSpeechSettingsForm(
                isTTSActive: _isTTSActive,
                activeSetter: setIsActive,
              ),

            ],
          )
      ),
    );

  }

  @override
  void dispose() {
    // TTS
    _ttsCallback!.cancel();
    _ttsService.stop();
    super.dispose();
  }


}