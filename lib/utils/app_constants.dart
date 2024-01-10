import 'package:flutter/material.dart';

class AppConstants {
  static GlobalKey<NavigatorState>? globalNavKey = GlobalKey<NavigatorState>();
  static MaterialColor primaryColor = _getPrimaryColor();
  static MaterialColor _getPrimaryColor() {
    var color = const Color.fromRGBO(13, 131, 105, 1);

    final Map<int, Color> shades = {
      50: Color.fromRGBO(color.red, color.green, color.blue, .1),
      100: Color.fromRGBO(color.red, color.green, color.blue, .2),
      200: Color.fromRGBO(color.red, color.green, color.blue, .3),
      300: Color.fromRGBO(color.red, color.green, color.blue, .4),
      400: Color.fromRGBO(color.red, color.green, color.blue, .5),
      500: Color.fromRGBO(color.red, color.green, color.blue, .6),
      600: Color.fromRGBO(color.red, color.green, color.blue, .7),
      700: Color.fromRGBO(color.red, color.green, color.blue, .8),
      800: Color.fromRGBO(color.red, color.green, color.blue, .9),
      900: Color.fromRGBO(color.red, color.green, color.blue, 1),
    };

    return MaterialColor(color.value, shades);
  }

  static String isTutorialCompleteKey = 'isTutorialComplete';
}
