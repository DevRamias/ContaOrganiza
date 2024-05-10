import 'package:flutter/material.dart';

class CadastrarUsuario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff838DFF),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(15),
          child: Column(
            children: [
              Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 8),
                child: const Text(
                  'Cadastrar Usuário',
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
      body: Container(), // Aqui você pode adicionar os outros widgets da tela
    );
  }
}
