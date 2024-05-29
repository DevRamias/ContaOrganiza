import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:conta_organiza/Telas/CustomAppBar.dart'; // Certifique-se de ajustar o caminho conforme necessário

class TelaConta extends StatefulWidget {
  const TelaConta({super.key});

  @override
  _TelaContaState createState() => _TelaContaState();
}

class _TelaContaState extends State<TelaConta> {
  String _userName = 'Nome do Usuário';
  String _userProfileImage = 'assets/images/Foto do perfil.png';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Nome do Usuário';
      _userProfileImage = prefs.getString('userProfileImage') ??
          'assets/images/Foto do perfil.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        // userName: _userName,
        // userProfileImage: _userProfileImage,
        title: 'Conta',
        onUpdateProfileImage: (String) {},
        onUpdateUserName: (String) {},
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color:
                          Color(0xffD2D6FF), // Cor de fundo ao redor do botão
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.black),
                        SizedBox(width: 5),
                        Text(
                          'Voltar',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Alterar Senha',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                trailing: Icon(Icons.edit),
                onTap: () {
                  // Função a ser implementada futuramente
                },
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
              ),
              ListTile(
                title: Text(
                  'Contas Vinculadas',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                trailing: Icon(Icons.edit),
                onTap: () {
                  // Função a ser implementada futuramente
                },
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
