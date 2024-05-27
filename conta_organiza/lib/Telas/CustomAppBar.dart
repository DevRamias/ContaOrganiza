import 'package:flutter/material.dart';
import 'dart:io';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userName;
  final String userProfileImage;
  final String title;
  final Function(String) onUpdateProfileImage;

  CustomAppBar({
    required this.userName,
    required this.userProfileImage,
    required this.title,
    required this.onUpdateProfileImage,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(100);
}

class _CustomAppBarState extends State<CustomAppBar> {
  late String _userProfileImage;

  @override
  void initState() {
    super.initState();
    _userProfileImage = widget.userProfileImage;
  }

  void updateProfileImage(String newImage) {
    setState(() {
      _userProfileImage = newImage;
    });
    widget.onUpdateProfileImage(newImage);
  }

  @override
  Widget build(BuildContext context) {
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
                backgroundImage: _userProfileImage.startsWith('assets/')
                    ? AssetImage(_userProfileImage) as ImageProvider
                    : NetworkImage(_userProfileImage),
              ),
              const SizedBox(width: 10),
              Text(
                widget.userName,
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
