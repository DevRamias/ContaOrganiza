import 'package:flutter/material.dart';

class TelaNotificacao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações'),
      ),
      body: Center(
        child: Text(
          'Tela de Notificações',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
