import 'package:flutter/material.dart';

class RichStyle {
  final double fontSize;
  final Color color;
  final Color backgroundColor;
  final String fontFamily;
  final FontWeight fontWeight;

  RichStyle({
    required this.fontSize,
    required this.color,
    required this.backgroundColor,
    required this.fontFamily,
    required this.fontWeight,
  });

  RichStyle.defaultStyle({
    this.fontSize = 18,
    this.color = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.fontFamily = "Roboto",
    this.fontWeight = FontWeight.normal,
  });

  TextStyle toTextStyle() {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      backgroundColor: backgroundColor,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
    );
  }

  RichStyle copyWith({
    double? fontSize,
    Color? color,
    Color? backgroundColor,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return RichStyle(
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
    );
  }

  RichStyle pickCommon(RichStyle style) {
    RichStyle dft = RichStyle.defaultStyle();
    RichStyle common = RichStyle(
      fontSize: fontSize == style.fontSize ? fontSize : dft.fontSize,
      color: color == style.color ? color : dft.color,
      backgroundColor: backgroundColor == style.backgroundColor ? backgroundColor : dft.backgroundColor,
      fontFamily: fontFamily == style.fontFamily ? fontFamily : dft.fontFamily,
      fontWeight: fontWeight == style.fontWeight ? fontWeight : dft.fontWeight,
    );
    return common;
  }

  Map toMap() {
    return {
      "fontSize": fontSize,
      "color": color.value,
      "backgroundColor": backgroundColor.value,
      "fontFamily": fontFamily,
      "fontWeight": fontWeight.index,
    };
  }

  static RichStyle fromMap(map) {
    return RichStyle(
      fontSize: map["fontSize"],
      color: Color(map["color"]),
      backgroundColor: Color(map["backgroundColor"]),
      fontFamily: map["fontFamily"],
      fontWeight: FontWeight.values[map["fontWeight"]],
    );
  }

  @override
  String toString() {
    return "[$fontSize, $color, $backgroundColor, $fontFamily, $fontWeight]";
  }
}