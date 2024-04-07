import 'package:flutter/material.dart';
import 'package:conta_organiza/tela_inicial.dart'; // Importe o arquivo da Tela Inicial

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conta Organiza',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          TelaInicial(), // Aqui você usa a TelaInicial como a tela inicial do app
    );
  }
}
