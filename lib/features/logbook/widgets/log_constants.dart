import 'package:flutter/material.dart';

const List<String> kCategories = ['Mechanical', 'Electronic', 'Software'];

const Map<String, Color> kCategoryColors = {
  'Mechanical': Color(0xFF27AE60), // Green
  'Electronic': Color(0xFF2D9CDB), // Blue
  'Software': Color(0xFFBB6BD9),   // Purple/Violet
};

const Map<String, Color> kCategoryBgColors = {
  'Mechanical': Color(0xFFEAFAF1),
  'Electronic': Color(0xFFEBF4FF),
  'Software': Color(0xFFF5EEFB),
};

const Map<String, IconData> kCategoryIcons = {
  'Mechanical': Icons.settings_rounded,
  'Electronic': Icons.electrical_services_rounded,
  'Software': Icons.code_rounded,
};
