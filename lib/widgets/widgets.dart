import 'package:animate_do/animate_do.dart';

import 'package:app_movil_oficial/bloc/busqueda/busqueda_bloc.dart';
import 'package:app_movil_oficial/helpers/helpers.dart';
import 'package:app_movil_oficial/models/search_result.dart';
import 'package:app_movil_oficial/search/search_destination.dart';
import 'package:app_movil_oficial/services/trafic_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:polyline/polyline.dart' as Poly;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_movil_oficial/bloc/mapa/mapa_bloc.dart';

import 'package:app_movil_oficial/bloc/mi_ubicacion/mi_ubicacion_bloc.dart';

part 'btn_ubicacion.dart';
part 'btn_mi_ruta.dart';
part 'btn_seguir_ubicacion.dart';
part 'searchBar.dart';
part 'marcador_manual.dart';