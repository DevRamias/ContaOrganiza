import 'package:flutter/material.dart';

class ListaContas extends StatefulWidget {
  @override
  _ListaContasState createState() => _ListaContasState();
}

class _ListaContasState extends State<ListaContas> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ContasScreen(),
    AdicionarScreen(),
    ConfiguracoesScreen(),
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
                child: const Text(
                  'Tela Inicial',
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff838DFF),
        items: [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon1.jpg')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon2.jpg')),
            label: 'Contas',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon3.png')),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon4.jpg')),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFFFFFFF),
        unselectedItemColor: Color.fromARGB(255, 0, 0, 0),
        onTap: _onItemTapped,
        showSelectedLabels: false, // Esconde labels selecionadas
        showUnselectedLabels: false, // Esconde labels não selecionadas
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Screen'),
    );
  }
}

class ContasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Contas Screen'),
    );
  }
}

class AdicionarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Adicionar Screen'),
    );
  }
}

class ConfiguracoesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Configurações Screen'),
    );
  }
}
