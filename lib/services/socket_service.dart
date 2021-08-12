import 'dart:async';

import 'package:app_movil_oficial/global/environment.dart';
import 'package:app_movil_oficial/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;
  bool isconnected = false;

  ServerStatus get serverStatus => this._serverStatus;

  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;

  void connect() async {
    isconnected = true;
    final token = await AuthService.getToken();

    // Dart client
    this._socket = IO.io(Environment.socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
      'extraHeaders': {
        'x-token': token,
        'role': "OFICIAL_ROLE",
      }
    });

    this._socket.on('connect', (_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    this._socket.on('disconnect', (_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    // this._socket.on('denuncia', (data) {
    //   print(data);
    //   print('data');
    //   // return data;
    // });
  }

  listen(String event) {
    this._socket.on(event, (data) async* {
      yield data;
    });
  }

  void sendUbicacion(lat, lon) {
    if (this._socket != null) {
      var payload = {
        "lat": lat,
        "lon": lon,
      };
      this._socket.emit('ubicacion', payload);
    }
  }

  // escucharDenuncia() {
  //   this._socket.on('denuncia', (data) {
  //     print(data);
  //     print('data');
  //     // return data;
  //   });
  //   // notifyListeners();
  // }

  void disconnect() {
    isconnected = false;
    this._socket.disconnect();
  }
}
