import 'package:flutter/material.dart';

class TelaInicial extends StatelessWidget {
  bool queroEntar = true;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double imageHeight =
        screenHeight * 0.15; // Ajuste esta porcentagem conforme necessário

    return MaterialApp(
      title: 'Imagem na Build',
      home: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    Image.asset("assets/images/logoCO.jpg",
                        height: imageHeight),
                    const SizedBox(height: 20),
                    const Text(
                      "CONTA ORGANIZA",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "inter",
                        fontSize: 20,
                        color: Color(0xff838DFF),
                      ),
                    ),
                    const SizedBox(height: 52),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                            width: 5.0, color: Color(0xff000D63)),
                        backgroundColor: const Color(0xff5E6DDB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20), // Ajusta o padding horizontal
                        minimumSize:
                            const Size(280, 75), // Largura e altura mínimas
                      ),
                      onPressed: () {
                        // Função a ser executada quando o botão for pressionado
                      },
                      child: const Text(
                        "Cadastre-se",
                        style: TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 24,
                            fontFamily: 'Inter'),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                            width: 5.0, color: Color(0xff000D63)),
                        backgroundColor: const Color(0xff5E6DDB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20), // Ajusta o padding horizontal
                        minimumSize:
                            const Size(280, 75), // Largura e altura mínimas
                      ),
                      onPressed: () {
                        // Função a ser executada quando o botão for pressionado
                      },
                      child: const Text(
                        "Entrar",
                        style: TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 24,
                            fontFamily: 'Inter'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        // Função a ser executada quando o texto for clicado
                      },
                      child: const Text(
                        "Política de privacidade",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 100, // Altura do rodapé
                color: const Color(0xff838DFF), // Cor do rodapé
              ),
            ),
          ],
        ),
      ),
    );
  }
}
