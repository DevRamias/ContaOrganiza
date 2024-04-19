import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double imageHeight =
        screenHeight * 0.7; // Ajuste esta porcentagem conforme necessário

    return MaterialApp(
      title: 'Imagem na Build',
      home: Scaffold(
        body: Container(
          alignment: Alignment
              .topCenter, // Alinha a imagem no topo centralizado horizontalmente

          child: Center(
            child: Column(
              children: [
                Image.asset(
                  alignment: Alignment.topCenter,
                  'assets/images/logoCO.jpg',
                  height: imageHeight,
                  //height: 150, // Altura da imagem (ajuste conforme necessário)
                  width: 150, // Largura da imagem (ajuste conforme necessário)
                ),
                //SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
