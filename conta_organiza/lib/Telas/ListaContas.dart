import 'dart:async';
import 'package:conta_organiza/Telas/CustomAppBar.dart';
import 'package:conta_organiza/Telas/TelaInicialPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'diretorios.dart';
import 'pesquisar.dart';
import 'configuracoes.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListaContas extends StatefulWidget {
  const ListaContas({super.key});

  @override
  _ListaContasState createState() => _ListaContasState();
}

class _ListaContasState extends State<ListaContas> {
  int _selectedIndex = 0;
  String _userName = 'Nome do Usuário';
  String _userProfileImage = 'assets/images/Foto do perfil.png';

  List<Map<String, dynamic>> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await initializeFirestoreData();
    _loadAllFiles();
    _loadProfile();
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
        } else {
          print('Nome do arquivo não está no formato esperado: $fileName');
        }
      }
    }

    setState(() {
      _files = files;
      _isLoading = false;
    });
  }

  Future<void> _loadProfile() async {
    await _retryWithBackoff(() async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>?;

          if (userData != null) {
            setState(() {
              _userName = userData['name'] ?? 'Nome do Usuário';
              _userProfileImage = userData['profileImageUrl'] ??
                  'assets/images/Foto do perfil.png';
            });
          }
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _userName = prefs.getString('userName') ?? 'Nome do Usuário';
          _userProfileImage = prefs.getString('userProfileImage') ??
              'assets/images/Foto do perfil.png';
        });
      }
    });
  }

  Future<void> _retryWithBackoff(Function action, {int maxRetries = 5}) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        await action();
        return;
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
  }

  Future<void> initializeFirestoreData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      DocumentSnapshot userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        await userDocRef.set({
          'name': 'Nome do Usuário',
          'profileImageUrl': 'assets/images/Foto do perfil.png',
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateProfile(String newName, String newImage) {
    setState(() {
      _userName = newName;
      _userProfileImage = newImage;
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
      Configuracoes(onUpdateProfile: _updateProfile),
    ];

    final List<String> _titles = [
      'Tela Inicial',
      'Diretórios',
      'Pesquisar',
      'Configurações',
    ];

    return Scaffold(
      appBar: CustomAppBar(
        // userName: _userName,
        // userProfileImage: _userProfileImage,
        title: _titles[_selectedIndex],
        onUpdateProfileImage: (String newImageUrl) {
          setState(() {
            _userProfileImage = newImageUrl;
          });
        },
        onUpdateUserName: (String newName) {
          setState(() {
            _userName = newName;
          });
        },
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
