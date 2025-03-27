import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;

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
  
  /// Load a GeoJSON file from assets and round coordinates to the specified number of decimal places
  static Future<Map<String, dynamic>> loadFromAssetsWithRoundedCoordinates(
    String path, 
    {int decimalPlaces = 3}
  ) async {
    try {
      // Load the GeoJSON data
      final Map<String, dynamic> jsonData = await loadFromAssets(path);
      
      // Round the coordinates
      return _roundCoordinates(jsonData, decimalPlaces);
    } catch (e) {
      // Re-throw with more context
      throw Exception('Failed to load GeoJSON file with rounded coordinates: $e');
    }
  }
  
  /// Round coordinates in GeoJSON data
  static Map<String, dynamic> _roundCoordinates(Map<String, dynamic> geojson, int decimalPlaces) {
    // We need to make a deep copy of the map to avoid modifying the original
    final Map<String, dynamic> result = Map<String, dynamic>.from(geojson);
    
    // Process features if this is a FeatureCollection
    if (result['type'] == 'FeatureCollection' && result.containsKey('features')) {
      final List<dynamic> features = List.from(result['features']);
      final List<dynamic> newFeatures = [];
      
      for (var feature in features) {
        newFeatures.add(_roundFeatureCoordinates(Map<String, dynamic>.from(feature), decimalPlaces));
      }
      
      result['features'] = newFeatures;
    } 
    // Process a single feature
    else if (result['type'] == 'Feature') {
      return _roundFeatureCoordinates(result, decimalPlaces);
    }
    
    return result;
  }
  
  /// Round coordinates in a single feature
  static Map<String, dynamic> _roundFeatureCoordinates(Map<String, dynamic> feature, int decimalPlaces) {
    if (!feature.containsKey('geometry')) {
      return feature;
    }
    
    final Map<String, dynamic> geometry = Map<String, dynamic>.from(feature['geometry']);
    final String geometryType = geometry['type'] as String;
    
    switch (geometryType) {
      case 'Point':
        geometry['coordinates'] = _roundPointCoordinates(geometry['coordinates'], decimalPlaces);
        break;
      case 'LineString':
        geometry['coordinates'] = _roundLineStringCoordinates(geometry['coordinates'], decimalPlaces);
        break;
      case 'Polygon':
        geometry['coordinates'] = _roundPolygonCoordinates(geometry['coordinates'], decimalPlaces);
        break;
      case 'MultiPoint':
        geometry['coordinates'] = _roundLineStringCoordinates(geometry['coordinates'], decimalPlaces);
        break;
      case 'MultiLineString':
        geometry['coordinates'] = _roundPolygonCoordinates(geometry['coordinates'], decimalPlaces);
        break;
      case 'MultiPolygon':
        geometry['coordinates'] = _roundMultiPolygonCoordinates(geometry['coordinates'], decimalPlaces);
        break;
    }
    
    feature['geometry'] = geometry;
    return feature;
  }
  
  /// Round Point coordinates [x, y] to decimalPlaces
  static List<dynamic> _roundPointCoordinates(List<dynamic> point, int decimalPlaces) {
    return [
      _roundNumber(point[0], decimalPlaces),
      _roundNumber(point[1], decimalPlaces)
    ];
  }
  
  /// Round LineString coordinates [[x, y], [x, y], ...] to decimalPlaces
  static List<dynamic> _roundLineStringCoordinates(List<dynamic> lineString, int decimalPlaces) {
    return lineString.map((point) => _roundPointCoordinates(point, decimalPlaces)).toList();
  }
  
  /// Round Polygon coordinates [[[x, y], [x, y], ...], ...] to decimalPlaces
  static List<dynamic> _roundPolygonCoordinates(List<dynamic> polygon, int decimalPlaces) {
    return polygon.map((ring) => _roundLineStringCoordinates(ring, decimalPlaces)).toList();
  }
  
  /// Round MultiPolygon coordinates [[[[x, y], [x, y], ...], ...], ...] to decimalPlaces
  static List<dynamic> _roundMultiPolygonCoordinates(List<dynamic> multiPolygon, int decimalPlaces) {
    return multiPolygon.map((polygon) => _roundPolygonCoordinates(polygon, decimalPlaces)).toList();
  }
  
  /// Round a number to the specified number of decimal places
  static double _roundNumber(dynamic number, int decimalPlaces) {
    final double value = (number as num).toDouble();
    final double factor = math.pow(10, decimalPlaces).toDouble();
    return (value * factor).round() / factor;
  }
} 