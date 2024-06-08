import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Function(String) onUpdateProfileImage;
  final Function(String) onUpdateUserName;

  const CustomAppBar({
    required this.title,
    required this.onUpdateProfileImage,
    required this.onUpdateUserName,
    required String userName,
    required String userProfileImage,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _CustomAppBarState extends State<CustomAppBar> {
  late String _userProfileImage;
  late String _userName;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _userProfileImage = 'assets/images/Foto do perfil.png'; // Valor padrão
    _userName = 'Nome do Usuário'; // Valor padrão
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? imageProvider;
    if (_userProfileImage.startsWith('assets/')) {
      imageProvider = AssetImage(_userProfileImage);
    } else if (_userProfileImage.startsWith('http')) {
      imageProvider = NetworkImage(_userProfileImage);
    } else {
      imageProvider = FileImage(File(_userProfileImage));
    }

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xff838DFF),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: imageProvider,
              ),
              const SizedBox(width: 10),
              Text(
                _userName,
                style: const TextStyle(
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
                widget.title,
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
    );
  }
}
