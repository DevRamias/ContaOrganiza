import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TelaInicial extends StatelessWidget {
  bool queroEntar = true;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double imageHeight =
        screenHeight * 0.2; // Ajuste esta porcentagem conforme necessário

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
                        fontSize: 26,
                        color: Color(0xff838DFF),
                      ),
                    ),
                    const SizedBox(height: 48),

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
                            const Size(300, 75), // Largura e altura mínimas
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
                            const Size(300, 75), // Largura e altura mínimas
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
                    // ElevatedButton(
                    //   style: OutlinedButton.styleFrom(
                    //     side: const BorderSide(color: Colors.green),
                    //     shape: const RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.all(Radius.circular(10)),
                    //     ),
                    //   ),
                    //   onPressed: () {},

                    //   // style: TextButton.styleFrom(
                    //   //   foregroundColor: Colors.black,
                    //   //   shape: const OvalBorder(),
                    //   //   padding: const EdgeInsets.all(20),
                    //   //   fixedSize: const Size(2, 80),
                    //   // ),
                    //   child: const Padding(
                    //     padding: EdgeInsets.all(0),
                    //     child: Text("Cadastre-se"),
                    //     //style: TextStyle(color: Colors.white, fontSize: 30),
                    //   ),
                    // ),

                    // const ElevatedButton(
                    //     // style: ,
                    //     onPressed: () {},
                    //     child: Padding(
                    //       padding: EdgeInsets.all(16.0),
                    //       child: Text("Cadastre-se"),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
