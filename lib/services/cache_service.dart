// lib/services/cache_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  Future<void> saveObject(String key, dynamic object) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(object);
      await prefs.setString(key, jsonString);
    } catch (e) {
      print('❌ Error saving to cache: $e');
    }
  }

  Future<dynamic> getObject(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString);
      }
      return null;
    } catch (e) {
      print('❌ Error getting from cache: $e');
      return null;
    }
  }

  Future<void> removeObject(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      print('❌ Error removing from cache: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }
}