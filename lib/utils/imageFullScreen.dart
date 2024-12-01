import 'dart:io';

import 'package:flutter/material.dart';

class Imageview extends StatelessWidget {
  final String imgUrl;
  final bool isFile;

  const Imageview({super.key, required this.imgUrl, this.isFile = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isFile
          ? Image.file(
              File(imgUrl),
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            )
          : Image.network(
              imgUrl,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
    );
  }
}
