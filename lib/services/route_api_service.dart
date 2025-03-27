import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
import '../utils/performance_utils.dart';

/// Service for generating routes through an API
class RouteApiService {
  // API endpoint from constants
  static final String apiUrl = AppConstants.routeApiUrl;
  
  /// Generate a random route by modifying port coordinates
  static Map<String, dynamic> generateRandomRouteData() {
    // Base template GeoJSON for a sea route
    final baseTemplate = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "properties": {
            "point": "departurePort",
            "name": "Singapore"
          },
          "geometry": {
            "type": "Point",
            "coordinates": _getRandomizedCoordinates(103.85, 1.29)
          }
        },
        {
          "type": "Feature",
          "properties": {
            "point": "intermediatePort1",
            "sequenceNumber": 1,
            "name": "Manila"
          },
          "geometry": {
            "type": "Point",
            "coordinates": _getRandomizedCoordinates(120.98, 14.58)
          }
        },
        {
          "type": "Feature",
          "properties": {
            "point": "destinationPort",
            "name": "Hong Kong"
          },
          "geometry": {
            "type": "Point",
            "coordinates": _getRandomizedCoordinates(114.17, 22.28)
          }
        },
        {
          "type": "Feature",
          "properties": {
            "point": "currentPosition",
            "name": "Current Container Position"
          },
          "geometry": {
            "type": "Point",
            "coordinates": _getRandomizedCoordinates(108.00, 12.00)
          }
        }
      ],
      "resolution": 100,
      "closeDistanceThreshold": 50,
      "allowSuez": true,
      "allowPanama": true,
      "allowMalacca": true,
      "allowGibraltar": true,
      "allowDover": true,
      "allowBering": true,
      "allowMagellan": true,
      "allowBabelmandeb": true,
      "allowKiel": true,
      "allowCorinth": true,
      "allowNorthwest": true,
      "allowNortheast": true,
      "smoothRoute": true,
      "smoothIterations": 1,
      "smoothFactor": 0.5
    };
    
    return baseTemplate;
  }
  
  /// Generate a single route using the API
  static Future<Map<String, dynamic>> generateRoute() async {
    return PerformanceUtils.measureExecution('generate_route', () async {
      try {
        // Generate random route data
        final routeData = generateRandomRouteData();
        
        // Make API request
        PerformanceUtils.addTimelineEvent('api_request_start');
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(routeData),
        );
        PerformanceUtils.addTimelineEvent('api_request_end');
        
        // Check if request was successful
        if (response.statusCode == 200) {
          // Parse and return the response
          return jsonDecode(response.body);
        } else {
          throw Exception('Failed to generate route: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        throw Exception('Error generating route: $e');
      }
    });
  }
  
  /// Generate multiple routes using the API
  static Future<List<Map<String, dynamic>>> generateMultipleRoutes(int count) async {
    return PerformanceUtils.measureExecution('generate_multiple_routes', () async {
      final List<Map<String, dynamic>> generatedRoutes = [];
      
      for (int i = 0; i < count; i++) {
        try {
          final route = await generateRoute();
          generatedRoutes.add(route);
        } catch (e) {
          print('Error generating route #${i + 1}: $e');
          // Continue with next route even if this one failed
        }
      }
      
      return generatedRoutes;
    });
  }
  
  /// Helper method to randomize coordinates within the full valid range
  static List<dynamic> _getRandomizedCoordinates(double baseLng, double baseLat) {
    // Константы для допустимых диапазонов
    const double MIN_LATITUDE = -85.0;  // Стандартное ограничение для морских маршрутов
    const double MAX_LATITUDE = 85.0;   // Стандартное ограничение для морских маршрутов
    const double MIN_LONGITUDE = -180.0;
    const double MAX_LONGITUDE = 180.0;
    
    final random = Random();
    
    // Генерируем полностью случайные координаты в допустимом диапазоне
    // Для широты: от -85 до 85 градусов
    final newLat = MIN_LATITUDE + (random.nextDouble() * (MAX_LATITUDE - MIN_LATITUDE));
    
    // Для долготы: от -180 до 180 градусов
    final newLng = MIN_LONGITUDE + (random.nextDouble() * (MAX_LONGITUDE - MIN_LONGITUDE));
    
    return [newLng, newLat];
  }
} 