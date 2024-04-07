import 'package:flutter/material.dart';
import 'package:conta_organiza/tela_inicial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nome do Seu App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TelaInicial(), // Aqui você usa a TelaInicial como a tela inicial do app
    );
  }
}
