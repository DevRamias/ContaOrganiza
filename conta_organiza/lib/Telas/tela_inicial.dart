/*import 'package:flutter/material.dart';

void main() {
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
        accentColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFfafafa),
      ),
      home:
          TelaInicial(), // Aqui você usa a TelaInicial como a tela inicial do app
    );
  }
}


class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: 237,
        color: Color(0xFF838DFF),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpt.dreamstime.com%2Fvetor-de-%25C3%25ADcone-perfil-do-avatar-padr%25C3%25A3o-foto-usu%25C3%25A1rio-m%25C3%25ADdia-social-image183042379&psig=AOvVaw1nPPc1O-Wpc9Elbz_3AlUn&ust=1712612020917000&source=images&cd=vfe&opi=89978449&ved=0CBIQjRxqFwoTCMCwlJCHsYUDFQAAAAAdAAAAABAE',
              ), // Troque pela URL da foto do usuário
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
              'https://www.google.com/imgres?q=co&imgurl=https%3A%2F%2Fco-collections.com%2Fcdn%2Fshop%2Ft%2F339%2Fassets%2Flogo.svg%3Fv%3D147170347080991281211710875753&imgrefurl=https%3A%2F%2Fco-collections.com%2F&docid=vs-Y0_lRpuN4rM&tbnid=T4H6Trw9F0wfvM&vet=12ahUKEwjps_Wlh7GFAxW8pJUCHQdWBOMQM3oECGgQAA..i&w=800&h=313&hcb=2&ved=2ahUKEwjps_Wlh7GFAxW8pJUCHQdWBOMQM3oECGgQAA', // Troque pela URL do logo do aplicativo
              width: 100,
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
*/