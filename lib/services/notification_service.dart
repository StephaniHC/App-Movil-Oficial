import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:app_movil_oficial/global/environment.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NotificationsService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final _storage = new FlutterSecureStorage();
  final _mensajesStreamController = StreamController<String>.broadcast();

  Stream<String> get mensajesStream => _mensajesStreamController.stream;

  static Future<dynamic> onBackgroundMessage(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      final dynamic notification = message['notification'];
    }
  }

  initNotifications() async {
    await _firebaseMessaging.requestNotificationPermissions();
    await initTokenFCM();
    // final token = await this._storage.read(key: 'tokenFCM');

    _firebaseMessaging.configure(
      onMessage: onMessage,
      onBackgroundMessage:
          Platform.isIOS ? null : NotificationsService.onBackgroundMessage,
      onLaunch: onLaunch,
      onResume: onResume,
    );
  }

  Future initTokenFCM() async {
    var tokenFCM = await getTokenFCM();
    if (tokenFCM == null) {
      tokenFCM = await _firebaseMessaging.getToken();
      await guardarTokenFCM(tokenFCM);
      //guardar token servicio si esta autenticado o termina de registrarse
      // await guardarTokenFCMServices();
      print("=====token FCM creado=====");
      print(tokenFCM);
    }

    _firebaseMessaging.onTokenRefresh.listen((token) async {
      if (tokenFCM != token) {
        // await actualizarTokenFCMServices(token, tokenFCM);
        await borrarTokenFCMServices();
        await guardarTokenFCM(token);
        // PUT TODO
      }
      print('onTokenRefresh');
      print(token.toString());
    });

    print("=====token FCM=====");
    print(tokenFCM);
  }

  Future<dynamic> onMessage(Map<String, dynamic> message) async {
    String argumento = 'no-data';
    print("onMessage");

    if (Platform.isAndroid) {
      argumento = message['data']['value'] ?? 'no-data';
    } else {
      argumento = message['value'] ?? 'no-data';
    }

    _mensajesStreamController.sink.add(argumento);
  }
// verificar Notification pero primero necesitamos tener un buen login
// tanto lado del backend como app, para ir guardando los tokenFCM de acuerdo al login

  Future<bool> guardarTokenFCMServices() async {
    print('guardarTokenFCMServices');
    final tokenFCM = await getTokenFCM();
    final data = {'tokenFCM': tokenFCM};

    final token = await this._storage.read(key: 'token');

    final resp = await http.post('${Environment.apiUrl}/notificacion/tokenfcm',
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json', 'x-token': token});

    // final res = await http.get('${Environment.apiUrl}/login/renew',
    //     headers: {'Content-Type': 'application/json', 'x-token': token});

    if (resp.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> guardarTokenFCMByEmailServices(String email) async {
    print('guardarTokenFCMByEmailServices');
    final tokenFCM = await getTokenFCM();
    final data = {
      'tokenFCM': tokenFCM,
      'email': email,
    };

    final resp = await http.post(
        '${Environment.apiUrl}/notificacion/tokenfcmemail',
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'});

    if (resp.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> actualizarTokenFCMServices(
      String newToken, String oldToken) async {
    final data = {'token': newToken, 'oldtoken': oldToken};
    final resp = await http.post('${Environment.apiUrl}/notification/update',
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    if (resp.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> borrarTokenFCMServices() async {
    var tokenFCM = await getTokenFCM();

    final data = {'tokenFCM': tokenFCM};

    final token = await this._storage.read(key: 'token');

    final resp = await http.post('${Environment.apiUrl}/notificacion/eliminar',
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json', 'x-token': token});

    if (resp.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
  // void onTokenRefresh() {
  //   Stream<String> fcmStream = _firebaseMessaging.onTokenRefresh;
  //   fcmStream.listen((tokenFCM) {
  //     // saveToken(tokenFCM);
  //   });
  // }

  Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    String argumento = 'no-data';
    print("onLaunch");

    if (Platform.isAndroid) {
      argumento = message['data']['value'] ?? 'no-data';
    } else {
      argumento = message['value'] ?? 'no-data';
    }

    _mensajesStreamController.sink.add(argumento);
  }

  Future<dynamic> onResume(Map<String, dynamic> message) async {
    String argumento = 'no-data';
    print("onResume");

    if (Platform.isAndroid) {
      argumento = message['data']['value'] ?? 'no-data';
    } else {
      argumento = message['value'] ?? 'no-data';
    }

    _mensajesStreamController.sink.add(argumento);
  }

  Future guardarTokenFCM(String tokenFCM) async {
    return await _storage.write(key: 'tokenFCM', value: tokenFCM);
  }

  Future borrarTokenFCM() async {
    // await borrarTokenFCMServices();
    await _storage.delete(key: 'tokenFCM');
  }

  Future getTokenFCM() async {
    return await this._storage.read(key: 'tokenFCM');
  }

  dispose() {
    _mensajesStreamController?.close();
  }
}
