import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Service for generating routes through an API
class RouteApiService {
  // API endpoint
  static const String apiUrl = 'https://europe-west1-bollo-tracker.cloudfunctions.net/calculateComplexSeaRoute';
  
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
    try {
      // Generate random route data
      final routeData = generateRandomRouteData();
      
      // Make API request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(routeData),
      );
      
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
  }
  
  /// Generate multiple routes using the API
  static Future<List<Map<String, dynamic>>> generateMultipleRoutes(int count) async {
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
  }
  
  /// Helper method to randomize coordinates within a reasonable range
  static List<dynamic> _getRandomizedCoordinates(double baseLng, double baseLat) {
    // Random offset between -2 and 2 degrees
    final random = Random();
    final lngOffset = (random.nextDouble() * 4) - 2;
    final latOffset = (random.nextDouble() * 4) - 2;
    
    // Make sure latitude stays within valid range (-90 to 90)
    final newLat = max(-85.0, min(85.0, baseLat + latOffset));
    // Make sure longitude stays within valid range (-180 to 180)
    final newLng = (baseLng + lngOffset + 180.0) % 360.0 - 180.0;
    
    return [newLng, newLat];
  }
} 