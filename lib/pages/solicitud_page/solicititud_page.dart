import 'package:app_movil_oficial/pages/mapa_page.dart';
import 'package:app_movil_oficial/pages/tapbar_page.dart';
import 'package:app_movil_oficial/services/auth_service.dart';
import 'package:app_movil_oficial/services/denuncia_service.dart';
import 'package:app_movil_oficial/widgets/card/custom_listtitle_perfil.dart';
import 'package:app_movil_oficial/widgets/custom_listtitle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistorialPage extends StatelessWidget {
  HistorialPage({Key key}) : super(key: key);

  final _mapa = MapaPage();

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
                    CustomListile(),
                  ],
                );
              } else {
                return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child:
                        Center(child: Text('No tienes denuncias en proceso')));
              }
            },
          )),
        ]),
      ),
    );
  }

  Widget cardMapa(BuildContext context) {
    final denunciaService =
        Provider.of<DenunciaService>(context, listen: false);
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
            Expanded(child: _mapa),
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
}
