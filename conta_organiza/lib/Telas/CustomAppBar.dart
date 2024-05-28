import 'package:flutter/material.dart';
import 'dart:io';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userName;
  final String userProfileImage;
  final String title;
  final Function(String) onUpdateProfileImage;
  final Function(String) onUpdateUserName;

  CustomAppBar({
    required this.userName,
    required this.userProfileImage,
    required this.title,
    required this.onUpdateProfileImage,
    required this.onUpdateUserName,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(100);
}

class _CustomAppBarState extends State<CustomAppBar> {
  late String _userProfileImage;
  late String _userName;

  @override
  void initState() {
    super.initState();
    _userProfileImage = widget.userProfileImage;
    _userName = widget.userName;
  }

  @override
  void didUpdateWidget(covariant CustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProfileImage != widget.userProfileImage) {
      setState(() {
        _userProfileImage = widget.userProfileImage;
      });
    }
    if (oldWidget.userName != widget.userName) {
      setState(() {
        _userName = widget.userName;
      });
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
