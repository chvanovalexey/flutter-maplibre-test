import 'package:maplibre/maplibre.dart';
import 'dart:convert';
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

  /// Load multiple GeoJSON files and add their data to existing sources
  Future<void> loadMultipleGeoJsonFiles(List<String> filePaths) async {
    try {
      // Initialize layer manager if not already initialized
      await initialize();
      
      for (final filePath in filePaths) {
        // Load the GeoJSON data
        final geojsonData = await GeoJsonLoader.loadFromAssets(filePath);
        
        // Parse the data into a ContainerRoute object
        final route = ContainerRoute.fromGeoJson(geojsonData);
        
        // Add the route data to existing sources
        if (_layerManager != null) {
          await _addRouteDataToSources(route);
        }
        
        // Print the contents of each source after adding this file
        await printSourceContents();
      }
      
      // Fit the map to whatever is currently loaded
      if (_layerManager != null && _currentRoute != null) {
        await _layerManager!.fitToRoute(_mapController, _currentRoute!);
      }
    } catch (e) {
      print('Error loading multiple GeoJSON files: $e');
      rethrow;
    }
  }
  
  /// Add route data to existing sources (without replacing existing data)
  Future<void> _addRouteDataToSources(ContainerRoute route) async {
    if (_layerManager != null) {
      // If this is the first route, just use updateSourcesFromRoute
      if (_currentRoute == null) {
        _currentRoute = route;
        await _layerManager!.updateSourcesFromRoute(route);
        return;
      }
      
      // Otherwise, merge the new route data with existing data
      // Add points
      _currentRoute!.departurePorts.addAll(route.departurePorts);
      _currentRoute!.destinationPorts.addAll(route.destinationPorts);
      _currentRoute!.intermediatePorts.addAll(route.intermediatePorts);
      _currentRoute!.currentPositions.addAll(route.currentPositions);
      
      // Add route segments
      _currentRoute!.pastRoutes.addAll(route.pastRoutes);
      _currentRoute!.futureRoutes.addAll(route.futureRoutes);
      
      // Update the sources with the merged data
      await _layerManager!.updateSourcesFromRoute(_currentRoute!);
    }
  }
  
  /// Print the contents of all sources to the console
  Future<void> printSourceContents() async {
    if (_layerManager == null || _currentRoute == null) {
      print('No data loaded in sources');
      return;
    }
    
    // Print departure ports
    print('DEPARTURE PORTS SOURCE:');
    print(jsonEncode(_currentRoute!.departurePorts.map((p) => {
      'name': p.name,
      'coordinates': p.coordinates,
      'properties': p.properties,
    }).toList()));
    print('---------------------------------');
    
    // Print destination ports
    print('DESTINATION PORTS SOURCE:');
    print(jsonEncode(_currentRoute!.destinationPorts.map((p) => {
      'name': p.name,
      'coordinates': p.coordinates,
      'properties': p.properties,
    }).toList()));
    print('---------------------------------');
    
    // Print intermediate ports
    print('INTERMEDIATE PORTS SOURCE:');
    print(jsonEncode(_currentRoute!.intermediatePorts.map((p) => {
      'name': p.name,
      'coordinates': p.coordinates,
      'properties': p.properties,
    }).toList()));
    print('---------------------------------');
    
    // Print current positions
    print('CURRENT POSITIONS SOURCE:');
    print(jsonEncode(_currentRoute!.currentPositions.map((p) => {
      'name': p.name,
      'coordinates': p.coordinates,
      'properties': p.properties,
    }).toList()));
    print('---------------------------------');
    
    // Print past routes
    print('PAST ROUTES SOURCE:');
    print(jsonEncode(_currentRoute!.pastRoutes.map((r) => {
      'from': r.from,
      'to': r.to,
      'coordinates': r.coordinates,
      'properties': r.properties,
    }).toList()));
    print('---------------------------------');
    
    // Print future routes
    print('FUTURE ROUTES SOURCE:');
    print(jsonEncode(_currentRoute!.futureRoutes.map((r) => {
      'from': r.from,
      'to': r.to,
      'coordinates': r.coordinates,
      'properties': r.properties,
    }).toList()));
    print('---------------------------------');
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

  /// Set the visibility of a layer
  Future<void> setLayerVisibility(String layerId, bool isVisible) async {
    if (_layerManager != null) {
      await _layerManager!.setLayerVisibility(layerId, isVisible);
    }
  }
} 