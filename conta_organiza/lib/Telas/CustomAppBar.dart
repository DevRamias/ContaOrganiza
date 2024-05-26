import 'package:flutter/material.dart';
import 'dart:io';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userProfileImage;
  final String title;

  CustomAppBar({
    required this.userName,
    required this.userProfileImage,
    required this.title,
  });

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
                backgroundImage: userProfileImage.startsWith('assets/')
                    ? AssetImage(userProfileImage) as ImageProvider
                    : FileImage(File(userProfileImage)),
              ),
              const SizedBox(width: 10),
              Text(
                userName,
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
                title,
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

  @override
  Size get preferredSize => Size.fromHeight(100);
}
