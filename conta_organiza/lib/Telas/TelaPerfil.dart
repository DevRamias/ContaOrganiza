import 'package:flutter/material.dart';

class TelaPerfil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff838DFF),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      AssetImage('assets/images/Foto do perfil.png'),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Nome do Usuário',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            Image.asset(
              'assets/images/Vector.png',
              height: 30,
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: const Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Container(
                height: 2,
                color: Colors.black,
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Color(0xffD2D6FF), // Cor de fundo ao redor do botão
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, color: Colors.black),
                  SizedBox(width: 5),
                  Text(
                    'Voltar',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0),
          ListTile(
            title: Text('Foto do Perfil'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Ação para editar a foto do perfil
              },
            ),
          ),
          Divider(color: Colors.black),
          ListTile(
            title: Text('Nome de Usuário'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Ação para editar o nome de usuário
              },
            ),
          ),
          Divider(color: Colors.black),
          ListTile(
            title: Text('Email do Usuário'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Ação para editar o email do usuário
              },
            ),
          ),
          Divider(color: Colors.black),
        ],
      ),
    );
  }
}
