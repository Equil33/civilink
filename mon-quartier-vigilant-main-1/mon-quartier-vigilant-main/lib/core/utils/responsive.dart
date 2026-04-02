import 'package:flutter/material.dart';
import 'dart:math' as math;

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 850;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Calcule une taille de texte adaptative basée sur la largeur de l'écran.
  /// [baseSize] est la taille idéale sur un écran standard (ex: 400px de large).
  /// [min] et [max] sont des limites optionnelles.
  static double fontSize(BuildContext context, double baseSize, {double? min, double? max}) {
    double width = screenWidth(context);
    // Facteur d'échelle basé sur une largeur de référence (ex: 375px pour mobile standard)
    double scaleFactor = width / 375;
    
    // On atténue l'effet d'échelle pour éviter que le texte ne devienne géant sur desktop
    double adjustedSize = baseSize * math.pow(scaleFactor, 0.5);
    
    if (min != null && adjustedSize < min) return min;
    if (max != null && adjustedSize > max) return max;
    
    return adjustedSize;
  }
}
