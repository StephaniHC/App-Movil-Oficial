import 'package:app_movil_oficial/helpers/mostrar_alerta.dart';
import 'package:app_movil_oficial/pages/mapa_page.dart';
import 'package:app_movil_oficial/services/BottomNavigationBarServices/ui_provider.dart';
import 'package:app_movil_oficial/services/auth_service.dart';
import 'package:app_movil_oficial/services/denuncia_service.dart';
import 'package:app_movil_oficial/services/denuncia_solicitud_service.dart';
import 'package:app_movil_oficial/widgets/boton_principal.dart';
import 'package:app_movil_oficial/widgets/card/custom_listtitle_perfil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DenunciasPage extends StatelessWidget {
  const DenunciasPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final denunciaSolicitudService =
        Provider.of<DenunciaSolicitudService>(context, listen: false);

    final String denuncia = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Denuncias")),
        ),
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: denunciaSolicitudService.getDenunciaNotificada(denuncia),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Container(height: 300, child: cardMapa(context)),
                    CustomListilePerfil(
                        img: denunciaSolicitudService.usuario.img,
                        header: "Reportado por:",
                        title: denunciaSolicitudService.persona.nombre +
                            denunciaSolicitudService.persona.apellido,
                        subtitle: denunciaSolicitudService.persona.ci,
                        description:
                            denunciaSolicitudService.denuncia.descripcion),
                    SizedBox(
                      height: 15,
                    ),

                    // Multimedia
                    Container(
                        margin: EdgeInsets.only(left: 15),
                        alignment: Alignment.centerLeft,
                        child: Text('Respaldo Multimedia')),

                    Container(
                        height: 200,
                        child: listCard(context,
                            denunciaSolicitudService.denuncia.multimedia)),

                    //Boton aceptar Rechazar
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: BotonPrincipal(
                              text: "Rechazar",
                              color: Colors.white,
                              textColor: Theme.of(context).primaryColor,
                              onPressed: () {},
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                              flex: 1,
                              child: BotonPrincipal(
                                  text: "Aceptar",
                                  onPressed: () async {
                                    await aceptarSolicitud(context);
                                  })),
                        ],
                      ),
                    )
                  ],
                );
              } else {
                return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: Center(child: CircularProgressIndicator()));
              }
            },
          ),
        ));
  }

  Future aceptarSolicitud(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    final uiProvider = Provider.of<UiProvider>(context, listen: false);
    final denunciaSolicitudService =
        Provider.of<DenunciaSolicitudService>(context, listen: false);

    String oficial = authService.oficial.id;
    bool atendioOk = await denunciaSolicitudService.atenderDenuncia(oficial);
    if (atendioOk) {
      uiProvider.selectedMenuOpt = 3;
      Navigator.pushNamed(context, 'home');
    } else {
      mostrarAlerta(context, 'Solicitud no atendida',
          'La denuncia ya ha sido atentida por otro oficial');
      Navigator.pushNamed(context, 'home');
    }
  }

  Widget cardMapa(BuildContext context) {
    final denunciaSolicitudService =
        Provider.of<DenunciaSolicitudService>(context, listen: false);
    return Container(
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
            Expanded(child: MapaPage()),
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
                        Text(denunciaSolicitudService.denuncia?.tipoDenuncia ??
                            ""),
                        Text(denunciaSolicitudService.denuncia?.fecha ?? ""),
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
        width: 100,
        image: NetworkImage(url),
        placeholder: AssetImage('assets/jar-loading.gif'),
        fadeInDuration: Duration(milliseconds: 200),
        height: 180.0,
        fit: BoxFit.cover,
      ),
    );
  }
}
