import 'package:conta_organiza/Telas/TelaNotificacao.dart';
import 'package:flutter/material.dart';
import 'TelaPerfil.dart'; // Importe a tela de perfil
import 'TelaConta.dart'; // Importe a tela de conta
import 'TelaNotificacao.dart'; // Importe a tela de notificação

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: Container(
              margin: EdgeInsets.symmetric(horizontal: 0.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2.0,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TelaPerfil()),
              );
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
              backgroundImage: AssetImage('assets/images/Icone Conta.png'),
            ),
            title: Text('Conta'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TelaConta()),
              );
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
              backgroundImage:
                  AssetImage('assets/images/Icone Notificacao.png'),
            ),
            title: Text('Notificações'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TelaNotificacao()),
              );
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 6.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Ação para deslogar da conta
              },
              icon: Icon(
                Icons.power_settings_new,
                color: Colors.black, // Cor do ícone preto
              ),
              label: Text(
                'Deslogar',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff838dff), // Cor de fundo roxa
              ),
            ),
          ),
        ],
      ),
    );
  }
}
