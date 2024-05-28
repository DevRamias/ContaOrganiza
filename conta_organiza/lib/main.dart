import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'Telas/CadastrarUsuario.dart';
import 'Telas/ConfirmarEmail.dart';
import 'Telas/ListaContas.dart';
import 'Telas/Inicio.dart';
import 'Telas/Login.dart'; // Importe a tela de login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    // await FirebaseAppCheck.instance.activate();
  } catch (e) {
    print('Erro ao inicializar o Firebase: $e');
  }
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
