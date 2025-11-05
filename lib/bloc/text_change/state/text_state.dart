import 'package:flutter/material.dart';
abstract class TextState{}

class InitialTextState extends TextState{

  final String name;
  final Color textColor;

  InitialTextState({required this.name,required this.textColor});
}

class UpdatedTextState extends TextState{

final String name;
  final Color textColor;

    UpdatedTextState({required this.name,required this.textColor});
}

