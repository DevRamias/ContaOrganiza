import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'InserirTelaVencimento.dart';
import 'TelaPerfil.dart';
import 'TelaNotificacao.dart';

class Configuracoes extends StatefulWidget {
  final Function(String, String) onUpdateProfile;

  Configuracoes({required this.onUpdateProfile});

  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deslogado com sucesso!")),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print("Erro ao deslogar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao deslogar: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2.0,
                  color: Colors.black,
                ),
              ),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/Foto do perfil.png'),
              ),
            ),
            title: const Text('Perfil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaPerfil(
                    onUpdateProfile: widget.onUpdateProfile,
                  ),
                ),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundImage:
                  AssetImage('assets/images/Icone Notificacao.png'),
            ),
            title: const Text('Notificações'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TelaNotificacao()),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.transparent, // Definir fundo transparente
              child: Image.asset(
                'assets/images/Icone Vencimento.png', // Adicione a imagem do ícone de vencimento
                fit: BoxFit.cover, // Ajuste a imagem para cobrir o espaço
              ),
            ),
            title: const Text('Data de vencimento'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const InserirTelaVencimento(), // Certifique-se de criar a TelaVencimento
                ),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(
                Icons.power_settings_new,
                color: Colors.black, // Cor do ícone preto
              ),
              label: const Text(
                'Deslogar',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff838dff), // Cor de fundo roxa
              ),
            ),
          ),
        ],
      ),
    );
  }
}
