import 'package:conta_organiza/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double textHeight = screenHeight * 0.6;
    double imageHeight =
        screenHeight * 0.7; // Ajuste esta porcentagem conforme necessário

    return MaterialApp(
      title: 'Imagem na Build',
      home: Scaffold(
        body: Container(
          alignment: Alignment
              .topCenter, // Alinha a imagem no topo centralizado horizontalmente

          child: Center(
            child: Column(children: [
              Image.asset(
                alignment: Alignment.topCenter,
                'assets/images/logoCO.jpg',
                height: imageHeight,
                //height: 150, // Altura da imagem (ajuste conforme necessário)
                width: 150, // Largura da imagem (ajuste conforme necessário)
              ),
              //SizedBox(height: 20),
              const Center(
              child: Text(
               // textAlign: Alignment.topCenter,

                'Conta Organiza', // Texto que será exibido
                style: TextStyle(
                    color: Color(0xFF838DFF),
                    fontSize:
                        24), // Estilo do texto (tamanho da fonte, cor, etc.)
              ),
              ),
            ],
          ),
        ),
      ),
    );
    ),
  }
}
