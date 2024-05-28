import 'package:conta_organiza/Telas/CadastrarUsuario.dart';
import 'package:conta_organiza/Telas/Inicio.dart';
import 'package:conta_organiza/Telas/ListaContas.dart';
import 'package:conta_organiza/Telas/Login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/inicio': (context) => TelaInicial(),
        '/login': (context) => Login(),
        '/cadastrar': (context) => CadastrarUsuario(),
        '/lista-contas': (context) => ListaContas(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return ListaContas();
        }
        return TelaInicial();
      },
    );
  }
}
