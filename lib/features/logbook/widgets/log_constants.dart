import 'package:flutter/material.dart';

const List<String> kCategories = ['Pekerjaan', 'Pribadi', 'Urgent'];

const Map<String, Color> kCategoryColors = {
  'Pekerjaan': Color(0xFF4A90D9),
  'Pribadi': Color(0xFF27AE60),
  'Urgent': Color(0xFFE74C3C),
};

const Map<String, Color> kCategoryBgColors = {
  'Pekerjaan': Color(0xFFEBF4FF),
  'Pribadi': Color(0xFFEAFAF1),
  'Urgent': Color(0xFFFDEDEC),
};

const Map<String, IconData> kCategoryIcons = {
  'Pekerjaan': Icons.work_outline,
  'Pribadi': Icons.person_outline,
  'Urgent': Icons.priority_high_rounded,
};
