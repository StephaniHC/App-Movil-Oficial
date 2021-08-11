import 'package:app_movil_oficial/pages/acceso_gps_page.dart';
import 'package:app_movil_oficial/pages/loading_page1.dart';
import 'package:app_movil_oficial/pages/mapa_page.dart';
import 'package:flutter/material.dart';

import 'package:app_movil_oficial/pages/loading_page.dart';
import 'package:app_movil_oficial/pages/login_page.dart';
import 'package:app_movil_oficial/pages/home_page.dart';
import 'package:app_movil_oficial/pages/welcome_page.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'loading': (BuildContext c) => LoadingPage(),
  'login': (BuildContext c) => LoginPage(),
  'home': (BuildContext c) => HomePage(),
  'welcome': (BuildContext c) => WelcomePage(),
  'mapa'      : ( _ ) => MapaPage(),
  'loading1'   : ( _ ) => LoadingPage1(),
  'acceso_gps': ( _ ) => AccesoGpsPage(),
};
