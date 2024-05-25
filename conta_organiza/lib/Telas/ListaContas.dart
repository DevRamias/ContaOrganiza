import 'package:flutter/material.dart';
import 'TelaInicialPage.dart';
import 'Diretorios.dart';
import 'Pesquisar.dart';
import 'Configuracoes.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ListaContas extends StatefulWidget {
  @override
  _ListaContasState createState() => _ListaContasState();
}

class _ListaContasState extends State<ListaContas> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllFiles();
  }

  Future<void> _loadAllFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> entities = directory.listSync(recursive: true);

    List<Map<String, dynamic>> files = [];
    for (var entity in entities) {
      if (entity is File) {
        final fileName = entity.path.split('/').last;
        final parts = fileName.split('_');
        if (parts.length == 3) {
          try {
            final date = DateFormat('yyyy-MM-dd').parse(parts[1]);
            files.add({
              'file': entity,
              'description': parts[0],
              'date': date,
              'type': parts[2],
            });
          } catch (e) {
            // Se ocorrer um erro ao analisar a data, ignore este arquivo
            print('Erro ao analisar data no arquivo: $fileName');
          }
        }
      }
    }

    setState(() {
      _files = files;
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      TelaInicialPage(),
      Diretorios(),
      _isLoading
          ? Center(child: CircularProgressIndicator())
          : Pesquisar(files: _files),
      Configuracoes(),
    ];

    final List<String> _titles = [
      'Tela Inicial',
      'Diretórios',
      'Pesquisar',
      'Configurações',
    ];

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
                height: 35,
                width: 35,
                child: ImageIcon(AssetImage('assets/images/icon1.jpg')),
              ),
            ),
            label: 'TelaInicial',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: SizedBox(
                height: 35,
                width: 35,
                child: ImageIcon(AssetImage('assets/images/icon2.jpg')),
              ),
            ),
            label: 'Diretórios',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: SizedBox(
                height: 35,
                width: 35,
                child: ImageIcon(AssetImage('assets/images/icon3.png')),
              ),
            ),
            label: 'Pesquisar',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: SizedBox(
                height: 35,
                width: 35,
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
