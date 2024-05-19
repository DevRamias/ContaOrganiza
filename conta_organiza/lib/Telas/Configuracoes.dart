import 'package:flutter/material.dart';

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
              backgroundImage: AssetImage('assets/images/Icone Conta.png'),
            ),
            title: Text('Conta'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navegue para a tela de configurações de conta
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
              // Navegue para a tela de configurações de notificações
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
