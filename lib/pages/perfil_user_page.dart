import 'package:app_movil_oficial/models/oficial.dart';
import 'package:app_movil_oficial/models/persona.dart';
import 'package:app_movil_oficial/models/usuario.dart';
import 'package:app_movil_oficial/native/background_location.dart';
import 'package:app_movil_oficial/pages/tapbar_page.dart';
import 'package:app_movil_oficial/services/auth_service.dart';
import 'package:app_movil_oficial/services/notification_service.dart';
import 'package:app_movil_oficial/services/socket_service.dart';
import 'package:app_movil_oficial/widgets/SliverAppBar/custom_sliverappbar.dart';
import 'package:app_movil_oficial/widgets/card/custom_card.dart';
import 'package:app_movil_oficial/widgets/custom_listtitle.dart';
import 'package:app_movil_oficial/widgets/perfil/description_multiline_widget.dart';
import 'package:app_movil_oficial/widgets/perfil/list_listtile_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';

class PerfilUserPage extends StatefulWidget {
  PerfilUserPage({Key key}) : super(key: key);

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilUserPage> {
  final _scrollCustomController = new ScrollController();

  final _scrollPageController = new ScrollController();

  bool _available = true;

  ScrollPhysics _scrollCustomPhysics = AlwaysScrollableScrollPhysics();

  ScrollPhysics _scrollPagePhysics = NeverScrollableScrollPhysics();

  @override
  void initState() {
// testear para la pagina sobre convertir a simnglescrollpage

    // TODO: implement initState
    _scrollCustomController.addListener(() {
      if (_scrollCustomController.position.pixels ==
              _scrollCustomController.position.maxScrollExtent &&
          _available) {
        if (_scrollPageController.position.maxScrollExtent != 0.0) {
          _scrollPagePhysics = AlwaysScrollableScrollPhysics();
          _available = false;
          setState(() {});
        }
      }
    });
    _scrollPageController.addListener(() {
      // print(_scrollPageController.position.pixels);

      if (_scrollPageController.position.pixels == 0.0 && !_available) {
        _scrollCustomPhysics = AlwaysScrollableScrollPhysics();
        _scrollPagePhysics = NeverScrollableScrollPhysics();
        _available = true;
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    final notificacion =
        Provider.of<NotificationsService>(context, listen: false);

    final authService = Provider.of<AuthService>(context);
    Usuario usuario = authService.usuario;
    Persona persona = authService.persona;
    Oficial oficial = authService.oficial;

    bool isOn = socketService.isconnected;

    _systemChromeColor(Brightness.light, context);

    final expandedHeight = MediaQuery.of(context).size.height * .3;

    return CustomScrollView(
      controller: _scrollCustomController,
      physics: _scrollCustomPhysics,
      slivers: <Widget>[
        SliverPersistentHeader(
          delegate: CustomSliverAppBar(
              expandedHeight: expandedHeight,
              title: '',
              subtitle:
                  '${persona?.nombre} ${persona?.apellido}'.substring(0, 20),
              fotoUrl: usuario?.img ?? usuario.imagenUrl,
              isOn: isOn,
              logout: () async {
                await notificacion.borrarTokenFCMServices();
                authService.logout();

                BackgroundLocation.instance.stop();
                print('socketService.isconnected');
                print(socketService.isconnected);
                if (socketService.isconnected) socketService.disconnect();
                Navigator.pushReplacementNamed(context, 'login');
              },
              switchOnOff: () async {
                if (!isOn) {
                  socketService.connect();
                  BackgroundLocation.instance.start();

                  BackgroundLocation.instance.stream.listen((LatLng position) {
                    print('socket ' + position.toString());
                    socketService.sendUbicacion(
                        position.latitude, position.longitude);
                  });

                  isOn = true;
                } else {
                  BackgroundLocation.instance.stop();
                  socketService.disconnect();
                  isOn = false;
                }
                setState(() {});
              },
              cards: []),
          pinned: true,
          // floating: true,
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            // SizedBox(height: MediaQuery.of(context).padding.top), //pinned
            SizedBox(height: expandedHeight * 0.1), //pinned
            SizedBox(
                height: MediaQuery.of(context).size.height -
                    kBottomNavigationBarHeight * 2,
                child: TapBarPage(tabs: [
                  Tab(text: ' Sobre '),
                  Tab(text: 'Historial')
                ], pages: [
                  SingleChildScrollView(
                    key: UniqueKey(),
                    controller: _scrollPageController,
                    physics: _scrollPagePhysics,
                    child: Column(
                      children: [
                        DividerSectionWidget(
                          title: "Informacion de usuario",
                          children: contentDividerSection([
                            '${persona.nombre} ${persona.apellido}',
                            oficial.dtm,
                            oficial.codigo,
                            persona.celular,
                            usuario.email
                          ]),
                        ),
                        DescriptionMultilineWidget(
                          title: "Descripcion",
                          description: oficial.descripcion,
                        )
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    key: UniqueKey(),
                    controller: _scrollPageController,
                    physics: _scrollPagePhysics,
                    child: Column(
                      children: [
                        CustomListile(),
                        CustomListile(),
                        CustomListile(),
                        CustomListile(),
                        CustomListile(),
                        CustomListile(),
                        CustomListile(),
                        CustomListile(),
                      ],
                    ),
                  ),
                ])),
          ]),
        )
      ],
    );
  }

  void _systemChromeColor(Brightness brightness, BuildContext context) {
    final color = Theme.of(context).primaryColor;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarIconBrightness: brightness,
          systemNavigationBarColor: Colors.white,
          statusBarColor: color.withOpacity(0)),
    );
  }
}

Widget contentDividerSection(List<String> list) {
  return Column(children: [
    ListTile(
        leading: Icon(Icons.person, color: Colors.black),
        title: Text('Nombre Apellido', style: TextStyle(fontSize: 14)),
        subtitle: Text(list[0])),
    Divider(height: 0),
    ListTile(
        leading: Icon(Icons.person, color: Colors.black),
        title: Text('Direccion de Transito y Movilidad',
            style: TextStyle(fontSize: 14)),
        subtitle: Text(list[1])),
    Divider(height: 0),
    ListTile(
        leading: Icon(Icons.perm_identity, color: Colors.black),
        title: Text('Codigo', style: TextStyle(fontSize: 14)),
        subtitle: Text(list[2])),
    Divider(height: 0),
    ListTile(
        leading: Icon(Icons.phone, color: Colors.black),
        title: Text('Celular', style: TextStyle(fontSize: 14)),
        subtitle: Text(list[3])),
    Divider(height: 0),
    ListTile(
        leading: Icon(Icons.email, color: Colors.black),
        title: Text('Email', style: TextStyle(fontSize: 14)),
        subtitle: Text(list[4])),
  ]);
}
