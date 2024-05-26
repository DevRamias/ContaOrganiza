import 'package:flutter/material.dart';
import 'Telas/CadastrarUsuario.dart';
import 'Telas/ConfirmarEmail.dart';
import 'Telas/ListaContas.dart';
import 'Telas/Inicio.dart';
import 'Telas/Login.dart'; // Importe a tela de login

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        canvasColor: const Color(0xFFfafafa),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => TelaInicial(),
        '/cadastrar': (context) => CadastrarUsuario(),
        '/confirmar-email': (context) => ConfirmarEmail(),
        '/lista-contas': (context) => ListaContas(),
        '/login': (context) => Login(), // Adiciona a rota da tela de login
      },
    );
  }
}
