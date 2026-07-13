import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Metadata for each expense category — icons, colours, keys.
class CategoryConstants {
  CategoryConstants._();

  /// Canonical category ids — must match the Hive-seeded data.
  static const String food           = 'food';
  static const String transportation = 'transportation';
  static const String shopping       = 'shopping';
  static const String bills          = 'bills';
  static const String entertainment  = 'entertainment';
  static const String health         = 'health';
  static const String education      = 'education';
  static const String travel         = 'travel';
  static const String other          = 'other';

  /// Icon identifier → [IconData] mapping.
  static const Map<String, IconData> iconMap = {
    'restaurant':     Icons.restaurant_rounded,
    'directions_car': Icons.directions_car_rounded,
    'shopping_bag':   Icons.shopping_bag_rounded,
    'receipt':        Icons.receipt_long_rounded,
    'movie':          Icons.movie_rounded,
    'favorite':       Icons.favorite_rounded,
    'school':         Icons.school_rounded,
    'flight':         Icons.flight_rounded,
    'category':       Icons.category_rounded,
    'sports':         Icons.sports_esports_rounded,
    'home':           Icons.home_rounded,
    'coffee':         Icons.local_cafe_rounded,
    'music':          Icons.music_note_rounded,
    'pets':           Icons.pets_rounded,
    'child_care':     Icons.child_care_rounded,
    'work':           Icons.work_rounded,
    'fitness':        Icons.fitness_center_rounded,
    'gift':           Icons.card_giftcard_rounded,
    'phone':          Icons.smartphone_rounded,
    'savings':        Icons.savings_rounded,
  };

  /// Icon identifier → display colour mapping (used in the picker).
  static const List<String> availableIconKeys = [
    'restaurant', 'directions_car', 'shopping_bag', 'receipt', 'movie',
    'favorite', 'school', 'flight', 'category', 'sports', 'home',
    'coffee', 'music', 'pets', 'child_care', 'work', 'fitness',
    'gift', 'phone', 'savings',
  ];

  /// Category colour options (ARGB int values for the picker).
  static const List<int> availableColors = [
    0xFFFF6B6B, // red
    0xFF4ECDC4, // teal
    0xFF45B7D1, // blue
    0xFF96CEB4, // green
    0xFFFFBE0B, // yellow
    0xFFFF6B9D, // pink
    0xFF6BCB77, // lime
    0xFF845EC2, // purple
    0xFF9CA3AF, // grey
    0xFFFF9F43, // orange
    0xFF54A0FF, // sky
    0xFF5F27CD, // deep purple
    0xFF00D2D3, // cyan
    0xFFE55039, // coral
    0xFF78E08F, // mint
  ];

  /// Seed data for the 9 built-in categories.
  static const List<Map<String, dynamic>> defaultCategories = [
    {
      'id': 'food',
      'name': 'Food',
      'iconName': 'restaurant',
      'colorValue': AppColors.catFood,
      'isCustom': false,
    },
    {
      'id': 'transportation',
      'name': 'Transportation',
      'iconName': 'directions_car',
      'colorValue': AppColors.catTransportation,
      'isCustom': false,
    },
    {
      'id': 'shopping',
      'name': 'Shopping',
      'iconName': 'shopping_bag',
      'colorValue': AppColors.catShopping,
      'isCustom': false,
    },
    {
      'id': 'bills',
      'name': 'Bills',
      'iconName': 'receipt',
      'colorValue': AppColors.catBills,
      'isCustom': false,
    },
    {
      'id': 'entertainment',
      'name': 'Entertainment',
      'iconName': 'movie',
      'colorValue': AppColors.catEntertainment,
      'isCustom': false,
    },
    {
      'id': 'health',
      'name': 'Health',
      'iconName': 'favorite',
      'colorValue': AppColors.catHealth,
      'isCustom': false,
    },
    {
      'id': 'education',
      'name': 'Education',
      'iconName': 'school',
      'colorValue': AppColors.catEducation,
      'isCustom': false,
    },
    {
      'id': 'travel',
      'name': 'Travel',
      'iconName': 'flight',
      'colorValue': AppColors.catTravel,
      'isCustom': false,
    },
    {
      'id': 'other',
      'name': 'Other',
      'iconName': 'category',
      'colorValue': AppColors.catOther,
      'isCustom': false,
    },
  ];

  /// Helper — resolve an [IconData] from a stored icon key.
  static IconData iconFromKey(String key) =>
      iconMap[key] ?? Icons.category_rounded;
}
