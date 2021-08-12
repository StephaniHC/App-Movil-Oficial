import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BackgroundLocation {
  BackgroundLocation._internal();
  static BackgroundLocation _instance = BackgroundLocation._internal();
  static BackgroundLocation get instance => _instance;

  final _methodChannel = MethodChannel("app.meedu/background-location");
  final _eventChannel = EventChannel("app.meedu/background-location-events");

  Geolocator _geolocator = Geolocator();
  final LocationOptions _locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 100);

  StreamController<LatLng> _controller = StreamController.broadcast();
  StreamSubscription _geolocatorSubs, _iosSubs;
  bool _running = false;

  Stream<LatLng> get stream => _controller.stream;

  initReferences() {
    _controller = StreamController.broadcast();
    _geolocatorSubs?.resume();
  }

  Future<void> start() async {
    if (_running) {
      throw new Exception('background location running');
    }
    initReferences();

    if (!Platform.isIOS) {
      _geolocatorSubs = _geolocator.getPositionStream(_locationOptions).listen(
        (Position position) {
          if (position != null) {
            _controller.sink.add(
              LatLng(position.latitude, position.longitude),
            );
          }
        },
      );
    } else {
      _iosSubs = _eventChannel.receiveBroadcastStream().listen(
        (data) {
          final map = Map<String, dynamic>.from(data);
          final position = LatLng(map['lat'], map['lng']);
          _controller.sink.add(position);
        },
      );
    }
    _methodChannel.invokeMethod('start');

    _running = true;
  }

  Future<void> stop() async {
    if (Platform.isIOS) {
      await _iosSubs?.cancel();
    } else {
      await _geolocatorSubs?.cancel();
      _geolocatorSubs.pause();
    }

    _running = false;
    _controller.close();

    await _methodChannel.invokeMethod('stop');
  }
}
