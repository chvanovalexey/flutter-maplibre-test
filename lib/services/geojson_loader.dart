import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Service for loading GeoJSON files from assets
class GeoJsonLoader {
  /// Load a GeoJSON file from assets
  static Future<Map<String, dynamic>> loadFromAssets(String path) async {
    try {
      // Load the file content as string
      final String content = await rootBundle.loadString(path);
      
      // Parse the string to JSON
      final Map<String, dynamic> jsonData = json.decode(content);
      
      return jsonData;
    } catch (e) {
      // Re-throw with more context
      throw Exception('Failed to load GeoJSON file from assets: $e');
    }
  }
} 