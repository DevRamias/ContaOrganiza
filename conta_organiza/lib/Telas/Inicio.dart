import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 60),
                    Image.asset("assets/images/logoCO.jpg",
                        height: imageHeight),
                    SizedBox(height: 20),
                    const Text(
                      "CONTA ORGANIZA",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "inter",
                        fontSize: 32,
                        color: Color(0xff838DFF),
                      ),
                    )
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
