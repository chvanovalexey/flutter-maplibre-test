import 'package:maplibre/maplibre.dart';
import '../models/container_route.dart';
import '../services/geojson_loader.dart';
import '../services/container_route_layer_manager.dart';

/// Manager for loading and displaying container routes on the map
class RouteManager {
  final MapController _mapController;
  ContainerRouteLayerManager? _layerManager;
  ContainerRoute? _currentRoute;
  
  RouteManager(this._mapController);
  
  /// Initialize the route manager
  Future<void> initialize() async {
    if (_layerManager == null && _mapController.style != null) {
      _layerManager = ContainerRouteLayerManager(_mapController.style!);
      await _layerManager!.initializeSources();
    }
  }
  
  /// Load a container route from a GeoJSON file
  Future<void> loadRouteFromFile(String filePath) async {
    try {
      // Initialize layer manager if not already initialized
      await initialize();
      
      // Load the GeoJSON data
      final geojsonData = await GeoJsonLoader.loadFromAssets(filePath);
      
      // Parse the data into a ContainerRoute object
      _currentRoute = ContainerRoute.fromGeoJson(geojsonData);
      
      // Update the map sources with the route data
      if (_layerManager != null && _currentRoute != null) {
        await _layerManager!.updateSourcesFromRoute(_currentRoute!);
        
        // Fit the map to the route
        await _layerManager!.fitToRoute(_mapController, _currentRoute!);
      }
    } catch (e) {
      print('Error loading route from file: $e');
      rethrow;
    }
  }
  
  /// Clear the current route from the map
  Future<void> clearRoute() async {
    if (_layerManager != null) {
      // Initialize empty sources to clear the current data
      await _layerManager!.initializeSources();
      _currentRoute = null;
    }
  }
  
  /// Get the current loaded route, if any
  ContainerRoute? get currentRoute => _currentRoute;
  
  /// Dispose of the route manager
  void dispose() {
    _layerManager = null;
    _currentRoute = null;
  }
} 