import 'package:flutter/material.dart';

class ListaContas extends StatefulWidget {
  @override
  _ListaContasState createState() => _ListaContasState();
}

class _ListaContasState extends State<ListaContas> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // Aqui você adiciona os widgets das outras páginas
    Text('Home Page'), // Substitua pelo widget da página Home
    Text('Contas Page'), // Substitua pelo widget da página Contas
    Text(
        'Transferências Page'), // Substitua pelo widget da página Transferências
    Text('Configurações Page'), // Substitua pelo widget da página Configurações
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff838DFF),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(15),
          child: Column(
            children: [
              Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 8),
                child: const Text(
                  'Lista de Contas',
                  style: TextStyle(
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
      body: _pages[
          _currentIndex], // Muda o conteúdo da tela conforme o índice selecionado
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Contas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            label: 'Transferências',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
        selectedItemColor: const Color(0xff5E6DDB),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
