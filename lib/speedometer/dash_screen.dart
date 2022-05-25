import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'components/speedometer.dart';
import 'components/tts_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DashScreen extends StatefulWidget {
  const DashScreen({this.unit = 'km/h', Key? key}) : super(key: key);

  final String unit;

  @override
  _DashScreenState createState() => _DashScreenState();
}

class _DashScreenState extends State<DashScreen> {
  SharedPreferences? _sharedPreferences;
  // For text to speed narration of current velocity
  /// Initiate service
  late FlutterTts _ttsService;

  /// Create a stream trying to speak speed
  StreamSubscription? _ttsCallback;

  /// String that the tts will read aloud, Speed + Expanded Unit
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

  /// Should TTS be talking
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

  /// TTS talk duration
  final Duration _ttsDuration = const Duration(seconds: 3);

  // For velocity Tracking
  /// Geolocator is used to find velocity
  GeolocatorPlatform locator = GeolocatorPlatform.instance;

  /// Stream that emits values when velocity updates
  late StreamController<double?> _velocityUpdatedStreamController;

  /// Current Velocity in km/h
  double? _velocity;

  /// Highest recorded velocity so far in m/s.
  double? _highestVelocity;

  @override
  void initState() {
  //  _ttsService.getLanguages.then((value) => print(value.toString()));
    super.initState();
    // Speedometer functionality. Updates any time velocity changes.
    _velocityUpdatedStreamController = StreamController<double?>();
    locator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation))
        .listen(
          (Position position) => _onAccelerate(position.speed),
    );

    // Set velocities to zero when app opens
    _velocity = 0;
    _highestVelocity = 0.0;

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

  /// Callback that runs when velocity updates, which in turn updates stream.
  void _onAccelerate(double speed) {
    locator.getCurrentPosition().then(
          (Position updatedPosition) {
        _velocity = (speed + updatedPosition.speed) / 2;
        if (_velocity! > _highestVelocity!) _highestVelocity = _velocity;
        _velocityUpdatedStreamController.add(_velocity);
      },
    );
    if(_velocity! > 120){
      _ttsService.speak("Yüksek hız");
    }

  }

  @override
  Widget build(BuildContext context) {
    const double gaugeBegin = 0, gaugeEnd = 200;

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      height: 360,
      width: 350,
      child: ListView(

        children: [
          // StreamBuilder updates Speedometer when new velocity received
          StreamBuilder<Object?>(
            stream: _velocityUpdatedStreamController.stream,
            builder: (context, snapshot) {
              return Container(
                padding: EdgeInsets.zero,
                child: Speedometer(
                  gaugeBegin: gaugeBegin,
                  gaugeEnd: gaugeEnd,
                  velocity: _velocity,
                  maxVelocity: _highestVelocity,
                  velocityUnit: widget.unit,
                ),
                width: 300,
                height: 300,
              )
              ;
            },
          ),
          TextToSpeechSettingsForm(
            isTTSActive: _isTTSActive,
            activeSetter: setIsActive,
          ),
        ],
      )
    );
  }

  @override
  void dispose() {
    // Velocity Stream
    _velocityUpdatedStreamController.close();
    // TTS
    _ttsCallback!.cancel();
    _ttsService.stop();
    super.dispose();
  }
}