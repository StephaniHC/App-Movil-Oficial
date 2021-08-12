import 'dart:convert';

import 'package:app_movil_oficial/global/environment.dart';
import 'package:app_movil_oficial/models/denuncia.dart';
import 'package:app_movil_oficial/models/denuncia_response.dart';
import 'package:app_movil_oficial/models/oficial.dart';
import 'package:app_movil_oficial/models/persona.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:app_movil_oficial/models/usuario.dart';
import 'package:app_movil_oficial/models/login_response.dart';

class DenunciaSolicitudService with ChangeNotifier {
  String idDenuncia;
  Denuncia denuncia;
  Usuario usuario;
  Persona persona;
  Oficial oficial;

  final _storage = new FlutterSecureStorage();

  Future<bool> getDenunciaNotificada(String denuncia) async {
    this.idDenuncia = denuncia;

    final token = await this._storage.read(key: 'token');

    final resp = await http.get(
        '${Environment.apiUrl}/denuncias/notificada/${denuncia}',
        headers: {'Content-Type': 'application/json', 'x-token': token});

    if (resp.statusCode == 200) {
      final denunciaResponse = denunciaResponseFromJson(resp.body);
      this.denuncia = denunciaResponse.denuncia;
      this.usuario = denunciaResponse.usuario;
      this.persona = denunciaResponse.persona;
      this.oficial = denunciaResponse.oficial;

      return true;
    } else {
      return false;
    }
  }

  // Aceptar denuncia

  Future<bool> atenderDenuncia(String idOficial) async {
    final token = await this._storage.read(key: 'token');

    final data = {'denuncia': this.idDenuncia, 'oficial': idOficial};

    final resp = await http.post('${Environment.apiUrl}/denuncias/atender',
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json', 'x-token': token});

    if (resp.statusCode == 200) {
      // final denunciaResponse = denunciaResponseFromJson(resp.body);
      // this.denuncia = denunciaResponse.denuncia;
      // this.usuario = denunciaResponse.usuario;
      // this.persona = denunciaResponse.persona;
      // this.oficial = denunciaResponse.oficial;

      return true;
    } else {
      return false;
    }
  }

  // Aceptar denuncia
  // cambia en proceso a true
}
