import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Login.dart'; // Certifique-se de importar a tela de login

class VerificaEmail extends StatelessWidget {
  final String email;

  const VerificaEmail({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

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
                  'Verifique seu e-mail',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Verifique o endereço de e-mail $email para confirmar seu cadastro.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Caso não chegou o e-mail, clique no botão abaixo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: const BorderSide(
                  width: 4.0,
                  color: Color(0xff000D63),
                ),
                backgroundColor: const Color(0xff5E6DDB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                minimumSize: const Size(290, 65),
              ),
              onPressed: () async {
                User? user = _auth.currentUser;
                if (user != null && !user.emailVerified) {
                  await user.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("E-mail de verificação reenviado!")),
                  );
                }
              },
              child: const Text(
                "Reenviar E-mail",
                style: TextStyle(
                  color: Color(0xffffffff),
                  fontSize: 20,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: const BorderSide(
                  width: 4.0,
                  color: Color(0xff000D63),
                ),
                backgroundColor: const Color(0xff5E6DDB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                minimumSize: const Size(290, 65),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: const Text(
                "Ir para Login",
                style: TextStyle(
                  color: Color(0xffffffff),
                  fontSize: 20,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
