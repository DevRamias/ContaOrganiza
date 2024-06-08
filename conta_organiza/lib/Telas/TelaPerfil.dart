import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'CustomAppBar.dart';
import 'ListaContas.dart'; // Importar a tela ListaContas

class TelaPerfil extends StatefulWidget {
  final Function(String, String) onUpdateProfile;

  TelaPerfil({required this.onUpdateProfile});

  @override
  _TelaPerfilState createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final TextEditingController _nameController = TextEditingController();
  File? _image;
  String _userName = 'Nome do Usuário';
  String _userProfileImage = 'assets/images/Foto do perfil.png';
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          _userName = data?['name'] ?? 'Nome do Usuário';
          _userProfileImage =
              data?['profileImage'] ?? 'assets/images/Foto do perfil.png';
          _nameController.text = _userName;
        });
      } else {
        setState(() {
          _userName = 'Nome do Usuário';
          _userProfileImage = 'assets/images/Foto do perfil.png';
          _nameController.text = _userName;
        });
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('userName') ?? 'Nome do Usuário';
        _userProfileImage = prefs.getString('userProfileImage') ??
            'assets/images/Foto do perfil.png';
        _nameController.text = _userName;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null || _currentUser == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(_currentUser!.uid);
      await storageRef.putFile(_image!);
      final imageUrl = await storageRef.getDownloadURL();

      setState(() {
        _userProfileImage = imageUrl;
      });

      await _saveProfile();
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({
        'name': _userName,
        'profileImage': _userProfileImage,
      }, SetOptions(merge: true));
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _userName);
      await prefs.setString('userProfileImage', _userProfileImage);
    }
    widget.onUpdateProfile(_userName, _userProfileImage);
  }

  void _updateName() {
    setState(() {
      _userName = _nameController.text;
    });
    _saveProfile();
  }

  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Digitar Nome de Usuário'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateName();
                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Escolha uma opção'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Perfil',
        onUpdateProfileImage: (newImage) {
          setState(() {
            _userProfileImage = newImage;
          });
        },
        onUpdateUserName: (newName) {
          setState(() {
            _userName = newName;
          });
        },
        userName: _userName,
        userProfileImage: _userProfileImage,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color(
                          0xffD2D6FF), // Cor de fundo ao redor do botão
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
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
                leading: CircleAvatar(
                  radius: 12,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : _userProfileImage.startsWith('assets/')
                          ? AssetImage(_userProfileImage) as ImageProvider
                          : NetworkImage(_userProfileImage),
                ),
                title: const Text('Trocar Foto do Perfil'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showImageSourceDialog,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar Nome de Usuário'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showEditNameDialog,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Substituir a tela atual pela ListaContas
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ListaContas(),
            ),
          );
        },
        icon: const Icon(Icons.save),
        label: const Text('Salvar Alterações'),
        backgroundColor: const Color(0xffD2D6FF),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
