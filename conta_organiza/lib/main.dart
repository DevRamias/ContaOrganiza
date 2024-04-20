// import 'package:conta_organiza/Telas/Botao.dart';
import 'package:conta_organiza/Telas/Inicio.dart';
import 'package:flutter/material.dart';
//import 'package:conta_organiza/Tela_inicial.dart'; // Importe o arquivo da Tela Inicial

void main() {
  runApp(MyApp());
}

/*
class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(children: [
          TelaInicial(),
        ]),
      ),
    );
  }
}
*/

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  //Stateful pra mudar se caso der erro
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
          TelaInicial(), // Aqui você usa a Tela_inicial como a tela inicial do app
    );
  }
}
