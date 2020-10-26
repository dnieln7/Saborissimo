import 'package:flutter/material.dart';

class Styles {
  static TextStyle headerTitle(Color color) {
    return TextStyle(
      color: color,
      fontWeight: FontWeight.bold,
      fontFamily: 'ReliqStd-Active',
      fontSize: 50,
    );
  }

  static TextStyle title(Color color) {
    return TextStyle(
      color: color,
      fontWeight: FontWeight.bold,
      fontFamily: 'Lato-Regular',
      fontSize: 20,
    );
  }

  static TextStyle subTitle(Color color) {
    return TextStyle(
      color: color,
      fontWeight: FontWeight.normal,
      fontFamily: 'Lato-Regular',
      fontSize: 17,
    );
  }

  static TextStyle legend() {
    return TextStyle(
      color: Colors.white,
      backgroundColor: Colors.black54,
      fontWeight: FontWeight.bold,
      fontFamily: 'Lato-Regular',
      fontSize: 25,
    );
  }
}
