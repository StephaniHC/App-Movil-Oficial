import 'package:app_movil_oficial/pages/ubicacion_page.dart';
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
  'ubicacion': (BuildContext c) => UbicacionPage(),
};
