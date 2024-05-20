import 'package:flutter/material.dart';

class TelaConta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conta'),
      ),
      body: Center(
        child: Text(
          'Tela de Conta',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
