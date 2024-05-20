import 'package:conta_organiza/Telas/Configuracoes.dart';
import 'package:conta_organiza/Telas/Diretorios.dart';
import 'package:conta_organiza/Telas/TelaInicialPage.dart';
import 'package:conta_organiza/Telas/Pesquisar.dart';
import 'package:flutter/material.dart';

class ListaContas extends StatefulWidget {
  @override
  _ListaContasState createState() => _ListaContasState();
}

class _ListaContasState extends State<ListaContas> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    TelaInicialPage(),
    Diretorios(),
    Pesquisar(),
    Configuracoes(),
  ];

  final List<String> _titles = [
    'Tela Inicial',
    'Diretórios',
    'Pesquisar',
    'Configurações',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff838DFF),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      AssetImage('assets/images/Foto do perfil.png'),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Nome do Usuário',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            Image.asset(
              'assets/images/Vector.png',
              height: 30,
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _titles[_selectedIndex],
                  style: const TextStyle(
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff838DFF),
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: SizedBox(
                height: 35, // Ajuste o valor conforme necessário
                width: 35, // Ajuste o valor conforme necessário
                child: ImageIcon(AssetImage('assets/images/icon1.jpg')),
              ),
            ),
            label: 'TelaInicial',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: SizedBox(
                height: 35, // Ajuste o valor conforme necessário
                width: 35, // Ajuste o valor conforme necessário
                child: ImageIcon(AssetImage('assets/images/icon2.jpg')),
              ),
            ),
            label: 'Diretórios',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: SizedBox(
                height: 35, // Ajuste o valor conforme necessário
                width: 35, // Ajuste o valor conforme necessário
                child: ImageIcon(AssetImage('assets/images/icon3.png')),
              ),
            ),
            label: 'Pesquisar',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: SizedBox(
                height: 35, // Ajuste o valor conforme necessário
                width: 35, // Ajuste o valor conforme necessário
                child: ImageIcon(AssetImage('assets/images/icon4.jpg')),
              ),
            ),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
