import 'package:flutter/material.dart';

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 237,
      color: Color(0xFF838DFF),
      child: Column(sss
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('URL_DA_FOTO'),
          ),
          SizedBox(height: 16),
          Text(
            'Nome do Usuário',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Image.network(
            'URL_DO_LOGO',
            width: 100,
            height: 100,
          ),
        ],
      ),
    );
  }
}
