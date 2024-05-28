import 'package:conta_organiza/Telas/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
        setState(() {
          _userName = userDoc['name'] ?? 'Nome do Usuário';
          _userProfileImage =
              userDoc['profileImage'] ?? 'assets/images/Foto do perfil.png';
          _nameController.text = _userName;
        });
      } else {
        // Documento não existe, usar valores padrão
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
          title: Text('Digitar Nome de Usuário'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateName();
                Navigator.of(context).pop();
              },
              child: Text('Salvar'),
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
          title: Text('Escolha uma opção'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tirar Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Escolher da Galeria'),
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
        userName: _userName,
        userProfileImage: _userProfileImage,
        title: 'Perfil',
        onUpdateProfileImage: (newImage) {
          setState(() {
            _userProfileImage = newImage;
          });
        },
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
                leading: CircleAvatar(
                  radius: 12,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : _userProfileImage.startsWith('assets/')
                          ? AssetImage(_userProfileImage) as ImageProvider
                          : NetworkImage(_userProfileImage),
                ),
                title: Text('Trocar Foto do Perfil'),
                trailing: Icon(Icons.chevron_right),
                onTap: _showImageSourceDialog,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar Nome de Usuário'),
                trailing: Icon(Icons.chevron_right),
                onTap: _showEditNameDialog,
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
