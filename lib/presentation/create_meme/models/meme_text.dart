import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memogenerator/data/models/text_with_position.dart';
import 'package:uuid/uuid.dart';

class MemeText extends Equatable {
  static const defaultColor = Colors.black;
  static const defaultFontSize = 24.0;

  final String id;
  final String text;
  final Color color;
  final double fontSize;

  MemeText({
    required this.id,
    required this.text,
    required this.color,
    required this.fontSize,
  });

  MemeText copyWithChangedText(final String newText) {
    return MemeText(id: id, text: newText, color: color, fontSize: fontSize);
  }

  MemeText copyWithChangedFontSettings(final Color newColor, final double newFontSize) {
    return MemeText(id: id, text: text, color: newColor, fontSize: newFontSize);
  }


  factory MemeText.createFromTextWithPosition(final TextWithPosition textWithPosition) {
    return MemeText(
      id: textWithPosition.id,
      text: textWithPosition.text,
      color: textWithPosition.color ?? defaultColor,
      fontSize: textWithPosition.fontSize ?? defaultFontSize,
    );
  }

  factory MemeText.create() {
    return MemeText(
      id: Uuid().v4(),
      text: "",
      color: defaultColor,
      fontSize: defaultFontSize,
    );
  }

  @override
  List<Object?> get props => [id, text];
}
