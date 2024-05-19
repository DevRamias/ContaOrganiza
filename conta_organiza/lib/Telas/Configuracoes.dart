import 'package:flutter/material.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        ListTile(
          leading: Container(
            margin: EdgeInsets.symmetric(horizontal: 6.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1.0,
                color: Colors.black,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/Foto do perfil.png'),
            ),
          ),
          title: Text('Perfil'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            // Navegue para a tela de configurações de perfil
          },
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 1.0,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black)),
          ),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/Icone Conta.png'),
          ),
          title: Text('Conta'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            // Navegue para a tela de configurações de perfil
          },
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black)),
          ),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/Icone Notificacao.png'),
          ),
          title: Text('Notificações'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            // Navegue para a tela de configurações de perfil
          },
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black)),
          ),
        ),
      ]),
    );
  }
}
