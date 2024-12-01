import 'package:flutter/material.dart';

ButtonStyle commonButtonStyle({double height = 50}) =>  ButtonStyle(
backgroundColor: MaterialStateProperty.all(Colors.black),
foregroundColor: MaterialStateProperty.all(Colors.white),
minimumSize: MaterialStateProperty.all(Size.fromHeight(height))
);