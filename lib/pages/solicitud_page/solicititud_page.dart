import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_movil_oficial/bloc/mapa/mapa_bloc.dart';
import 'package:app_movil_oficial/bloc/mi_ubicacion/mi_ubicacion_bloc.dart';
import 'package:app_movil_oficial/helpers/helpers.dart';
import 'package:app_movil_oficial/helpers/mostrar_alerta.dart';
import 'package:app_movil_oficial/native/background_location.dart';
import 'package:app_movil_oficial/pages/mapa_page.dart';
import 'package:app_movil_oficial/pages/tapbar_page.dart';
import 'package:app_movil_oficial/services/auth_service.dart';
import 'package:app_movil_oficial/services/denuncia_service.dart';
import 'package:app_movil_oficial/services/socket_service.dart';
import 'package:app_movil_oficial/services/trafic_service.dart';
import 'package:app_movil_oficial/widgets/boton_principal.dart';
import 'package:app_movil_oficial/widgets/card/custom_listtitle_perfil.dart';
import 'package:app_movil_oficial/widgets/custom_listtitle.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:polyline/polyline.dart' as Poly;

class HistorialPage extends StatelessWidget {
  HistorialPage({Key key}) : super(key: key);

  final _mapamarcador = MapaPage();

  @override
  Widget build(BuildContext context) {
    final denunciaService =
        Provider.of<DenunciaService>(context, listen: false);

    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: TapBarPage(tabs: [
          Tab(text: 'Solicitudes'),
          Tab(
            text: 'En Proceso',
          )
        ], pages: [
          SingleChildScrollView(
            child: Column(
              children: [
                CustomListile(),
                Divider(),
                CustomListile(),
                Divider(),
                CustomListile(),
              ],
            ),
          ),
          SingleChildScrollView(
              child: FutureBuilder(
            future:
                denunciaService.getDenunciaEnProceso(authService.oficial.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data) {
                  return Column(
                    children: [
                      Container(height: 300, child: cardMapa(context)),
                      CustomListilePerfil(
                          img: denunciaService.usuario.img,
                          header: "Reportado por:",
                          title: denunciaService.persona.nombre +
                              denunciaService.persona.apellido,
                          subtitle: denunciaService.persona.ci,
                          description: denunciaService.denuncia.descripcion),
                      Divider(
                        height: 15,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 15),
                          alignment: Alignment.centerLeft,
                          child: Text('Respaldo Multimedia')),
                      Container(
                          height: 200,
                          child: listCard(
                              context, denunciaService.denuncia.multimedia)),
                      Divider(),
                      //Boton aceptar Rechazar
                      Container(
                          padding: EdgeInsets.all(10),
                          child: BotonPrincipal(
                              text: "Terminar",
                              onPressed: () async {
                                await terminarDenuncia(context);
                              })),
                    ],
                  );
                } else {
                  return Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: Center(
                          child: Text('No tienes denuncias en proceso')));
                }
              } else {
                return Container(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )),
        ]),
      ),
    );
  }

  Future terminarDenuncia(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    final denunciaService =
        Provider.of<DenunciaService>(context, listen: false);

    bool terminadoOk = await denunciaService.terminarDenuncia();
    if (terminadoOk) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      BackgroundLocation.instance.start();
      socketService.connect();
      mostrarAlerta(context, 'Denuncia concluida', 'Has concluido la denuncia');
      Timer(Duration(seconds: 3),
          () => Navigator.pushReplacementNamed(context, 'home'));
    } else {
      mostrarAlerta(context, 'Atencion', 'Algo ha salido mal');
    }
  }

  Widget cardMapa(BuildContext context) {
    final denunciaService =
        Provider.of<DenunciaService>(context, listen: false);
    var coordenadas = denunciaService.denuncia.coordenadas.split(',');
    LatLng destino =
        LatLng(double.parse(coordenadas[0]), double.parse(coordenadas[1]));

    print("coordenadas \n");
    print(coordenadas);

    Widget content = Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 4.0,
        margin: EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
        child: Column(
          // mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: GestureDetector(
                  onDoubleTap: () {
                    print('object');

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _mapamarcador,
                        ));
                  },
                  onTap: () {
                    print('object2');

                    // final mapaBloc = BlocProvider.of<MapaBloc>(context);
                  },
                  child: _mapamarcador),
            ),
            Container(
              padding: EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo de Reporte: '),
                        Text('Hora y Fecha: '),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(denunciaService.denuncia?.tipoDenuncia ?? ""),
                        Text(denunciaService.denuncia?.fecha ?? ""),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    calcularDestino(context, destino);
    return content;
  }

  Widget listCard(BuildContext context, List imagenes) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imagenes.length,
      itemBuilder: (context, idx) {
        return _card(imagenes[idx]);
      },
    );
  }

  _card(url) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: FadeInImage(
        width: 130,
        image: NetworkImage(url),
        placeholder: AssetImage('assets/jar-loading.gif'),
        fadeInDuration: Duration(milliseconds: 200),
        height: 180.0,
        fit: BoxFit.cover,
      ),
    );
  }

  void calcularDestino(BuildContext context, LatLng destino) async {
    // calculandoAlerta(context);

    final trafficService = new TrafficService();
    final mapaBloc = context.bloc<MapaBloc>();

    final inicio = context.bloc<MiUbicacionBloc>().state.ubicacion;
    // final destino = mapaBloc.state.ubicacionCentral;

    final trafficResponse =
        await trafficService.getCoordsInicioYDestino(inicio, destino);

    final geometry = trafficResponse.routes[0].geometry;
    final duracion = trafficResponse.routes[0].duration;
    final distancia = trafficResponse.routes[0].distance;

    // Decodificar los puntos del geometry
    final points = Poly.Polyline.Decode(encodedString: geometry, precision: 6)
        .decodedCoords;
    final List<LatLng> rutaCoordenadas =
        points.map((point) => LatLng(point[0], point[1])).toList();

    mapaBloc
        .add(OnCrearRutaInicioDestino(rutaCoordenadas, distancia, duracion));

    mapaBloc.add(OnSeguirUbicacion());

    //  final destino = miUbicacionBloc.state.ubicacion;
    mapaBloc.moverCamara(destino);

    // Navigator.of(context).pop();
    // context.bloc<BusquedaBloc>().add(OnDesactivarMarcadorManual());
  }
}
