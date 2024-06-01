import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:conta_organiza/Telas/ListaContas.dart';

class Login extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _senhaController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ListaContas()),
        );
      }
    } catch (e) {
      print("Erro ao fazer login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao fazer login: $e")),
      );
    }
  }

  Future<void> _loginComGoogle() async {
    try {
      await _googleSignIn.signOut(); // Força o logout do Google Sign-In

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User? user = userCredential.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ListaContas()),
        );
      }
    } catch (e) {
      print("Erro ao fazer login com Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao fazer login com Google: $e")),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Por favor, insira seu e-mail para redefinir a senha.")),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("E-mail de redefinição de senha enviado.")),
      );
    } catch (e) {
      print("Erro ao enviar e-mail de redefinição de senha: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Erro ao enviar e-mail de redefinição de senha: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff838DFF),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(15),
          child: Column(
            children: [
              Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 8),
                child: const Text(
                  'Login',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'E-mail',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff838DFF), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Senha',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff838DFF), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                obscureText: true,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: _resetPassword,
                child: const Text(
                  "Esqueci minha senha",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 0, 0),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                    width: 4.0,
                    color: Color(0xff000D63),
                  ),
                  backgroundColor: const Color(0xff5E6DDB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20), // Ajusta o padding horizontal
                  minimumSize: const Size(290, 65), // Largura e altura mínimas
                ),
                onPressed: _login,
                child: const Text(
                  "Entrar",
                  style: TextStyle(
                    color: Color(0xffffffff),
                    fontSize: 20,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                    width: 4.0,
                    color: Color(0xff5E6DDB),
                  ),
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20), // Ajusta o padding horizontal
                  minimumSize: const Size(290, 55), // Largura e altura mínimas
                ),
                icon: Image.asset(
                  'assets/images/google_logo.png', // Certifique-se de ter o ícone do Google
                  height: 24,
                ),
                onPressed: _loginComGoogle,
                label: const Text(
                  "Continuar com Google",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                    width: 4.0,
                    color: Color(0xff000D63),
                  ),
                  backgroundColor: const Color(0xff5E6DDB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8), // Ajuste o padding horizontal e vertical
                  minimumSize: const Size(140, 40), // Largura e altura mínimas
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancelar",
                  style: TextStyle(
                    color: Color(0xffffffff),
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
