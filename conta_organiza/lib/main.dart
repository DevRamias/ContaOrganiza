import 'package:flutter/material.dart';
import 'package:conta_organiza/Tela_inicial.dart'; // Importe o arquivo da Tela Inicial

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
        primaryColor: const Color(0xFF2196f3),
        //accentColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFfafafa),
      ),
      home:
          Tela_inicial(), // Aqui você usa a Tela_inicial como a tela inicial do app
    );
  }
}
