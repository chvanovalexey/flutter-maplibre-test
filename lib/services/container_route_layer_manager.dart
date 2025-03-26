import 'dart:convert';
//import 'dart:io';
import 'package:flutter/material.dart' show EdgeInsets, Text, TextStyle, MainAxisSize, CrossAxisAlignment;
import 'package:flutter/services.dart' show rootBundle;
import 'package:maplibre/maplibre.dart';
import '../models/container_route.dart';

/// Manager for container route layers on the map
class ContainerRouteLayerManager {
  // Source IDs
  static const String departurePortsSourceId = 'departure-ports-source';
  static const String destinationPortsSourceId = 'destination-ports-source';
  static const String intermediatePortsSourceId = 'intermediate-ports-source';
  static const String currentPositionSourceId = 'current-position-source';
  static const String pastRouteSourceId = 'past-route-source';
  static const String futureRouteSourceId = 'future-route-source';

  // Layer IDs
  static const String departurePortsLayerId = 'departure-ports-layer';
  static const String destinationPortsLayerId = 'destination-ports-layer';
  static const String intermediatePortsLayerId = 'intermediate-ports-layer';
  static const String currentPositionLayerId = 'current-position-layer';
  static const String pastRouteLayerId = 'past-route-layer';
  static const String futureRouteLayerId = 'future-route-layer';

  final StyleController _style;

  ContainerRouteLayerManager(this._style);

  /// Initialize all sources and layers for container routes
  Future<void> initializeSources() async {
    // Remove any existing sources and layers first
    await _removePreviousSourcesAndLayers();
    
    // Load custom icon images
    await _loadCustomIcons();

    // Add all sources
    await _addEmptySources();

    // Add all layers
    await _addLayers();
  }

  /// Remove any existing sources and layers
  Future<void> _removePreviousSourcesAndLayers() async {
    // Remove layers first (layers depend on sources)
    final layerIds = [
      departurePortsLayerId,
      destinationPortsLayerId,
      intermediatePortsLayerId,
      currentPositionLayerId,
      pastRouteLayerId,
      futureRouteLayerId,
    ];

    for (final layerId in layerIds) {
      try {
        // Просто пытаемся удалить слой, но подавляем вывод ошибки в консоль
        await _style.removeLayer(layerId);
      } catch (e) {
        // Слой не существует, молча игнорируем
        // Не используем print, чтобы не загромождать консоль
      }
    }

    // Then remove sources
    final sourceIds = [
      departurePortsSourceId,
      destinationPortsSourceId,
      intermediatePortsSourceId,
      currentPositionSourceId,
      pastRouteSourceId,
      futureRouteSourceId,
    ];

    for (final sourceId in sourceIds) {
      try {
        // Просто пытаемся удалить источник, но подавляем вывод ошибки
        await _style.removeSource(sourceId);
      } catch (e) {
        // Источник не существует, молча игнорируем
      }
    }
  }

  /// Add empty GeoJSON sources for all route components
  Future<void> _addEmptySources() async {
    // Create empty feature collections for each source
    final emptyCollection = {
      'type': 'FeatureCollection',
      'features': [],
    };

    final emptyGeoJson = jsonEncode(emptyCollection);

    // Add sources for points
    await _style.addSource(
      GeoJsonSource(id: departurePortsSourceId, data: emptyGeoJson),
    );
    await _style.addSource(
      GeoJsonSource(id: destinationPortsSourceId, data: emptyGeoJson),
    );
    await _style.addSource(
      GeoJsonSource(id: intermediatePortsSourceId, data: emptyGeoJson),
    );
    await _style.addSource(
      GeoJsonSource(id: currentPositionSourceId, data: emptyGeoJson),
    );

    // Add sources for routes
    await _style.addSource(
      GeoJsonSource(id: pastRouteSourceId, data: emptyGeoJson),
    );
    await _style.addSource(
      GeoJsonSource(id: futureRouteSourceId, data: emptyGeoJson),
    );
  }

  /// Add all layers for the container routes
  Future<void> _addLayers() async {
    // Add point layers
    await _style.addLayer(
      SymbolStyleLayer(
        id: departurePortsLayerId,
        sourceId: departurePortsSourceId,
        layout: {
          'icon-image': 'departurePortImage',
          'icon-size': 1.5,
          'icon-allow-overlap': true,
          'text-field': [
            'format',
            ['get', 'title'],
            { 'font-scale': 1.0 },
            //'\n',
            //{ 'font-scale': 0.8 },
            // ['get', 'description'],
            //{ 'font-scale': 0.8 },
          ],
          //'text-font': ['Open Sans Regular'],
          'text-offset': [0, 1.5],
          'text-anchor': 'top',
          'text-size': 12,
          'text-allow-overlap': false,
        },
      ),
    );

    await _style.addLayer(
      SymbolStyleLayer(
        id: destinationPortsLayerId,
        sourceId: destinationPortsSourceId,
        layout: {
          'icon-image': 'destinationPortImage',
          'icon-size': 1.5,
          'icon-allow-overlap': true,
          'text-field': [
            'format',
            ['get', 'title'],
            { 'font-scale': 1.0 },
            //'\n',
            //{ 'font-scale': 0.8 },
            //['get', 'description'],
            //{ 'font-scale': 0.8 },
          ],
          //'text-font': ['Open Sans Regular'],
          'text-offset': [0, 1.5],
          'text-anchor': 'top',
          'text-size': 12,
          'text-allow-overlap': false,
        },
      ),
    );

    await _style.addLayer(
      SymbolStyleLayer(
        id: intermediatePortsLayerId,
        sourceId: intermediatePortsSourceId,
        layout: {
          'icon-image': 'intermediatePortImage',
          'icon-size': 1.2,
          'icon-allow-overlap': true,
          'text-field': [
            'format',
            ['get', 'title'],
            { 'font-scale': 1.0 },
            //'\n',
            //{ 'font-scale': 0.8 },
            //['get', 'description'],
            //{ 'font-scale': 0.8 },
          ],
          //'text-font': ['Open Sans Regular'],
          'text-offset': [0, 1.5],
          'text-anchor': 'top',
          'text-size': 11,
          'text-allow-overlap': false,
        },
      ),
    );

    await _style.addLayer(
      SymbolStyleLayer(
        id: currentPositionLayerId,
        sourceId: currentPositionSourceId,
        layout: {
          'icon-image': 'currentPositionImage',
          'icon-size': 1.5,
          'icon-allow-overlap': true,
          'text-field': [
            'format',
            ['get', 'title'],
            { 'font-scale': 1.0 },
            //'\n',
            //{ 'font-scale': 0.8 },
            //['get', 'description'],
            //{ 'font-scale': 0.8 },
          ],
          //'text-font': ['Open Sans Regular'],
          'text-offset': [0, 1.5],
          'text-anchor': 'top',
          'text-size': 12,
          'text-allow-overlap': false,
        },
      ),
    );

    // Add line layers
    await _style.addLayer(
      LineStyleLayer(
        id: pastRouteLayerId,
        sourceId: pastRouteSourceId,
        paint: {
          'line-color': ['get', 'stroke'],
          'line-width': 4,
          'line-opacity': 0.8,
        },
      ),
    );

    await _style.addLayer(
      LineStyleLayer(
        id: futureRouteLayerId,
        sourceId: futureRouteSourceId,
        paint: {
          'line-color': ['get', 'stroke'],
          'line-width': 2,
          'line-opacity': 0.6,
          'line-dasharray': [5, 5],
        },
      ),
    );
  }

  /// Update the sources with route data
  Future<void> updateSourcesFromRoute(ContainerRoute route) async {
    // Update departure ports source
    await _updatePointSource(
      departurePortsSourceId,
      route.departurePorts.map((port) => _portToFeature(port)).toList(),
    );

    // Update destination ports source
    await _updatePointSource(
      destinationPortsSourceId,
      route.destinationPorts.map((port) => _portToFeature(port)).toList(),
    );

    // Update intermediate ports source
    await _updatePointSource(
      intermediatePortsSourceId,
      route.intermediatePorts.map((port) => _portToFeature(port)).toList(),
    );

    // Update current position source
    await _updatePointSource(
      currentPositionSourceId,
      route.currentPositions.map((port) => _portToFeature(port)).toList(),
    );

    // Update past route source
    await _updateLineSource(
      pastRouteSourceId,
      route.pastRoutes.map((segment) => _segmentToFeature(segment)).toList(),
    );

    // Update future route source
    await _updateLineSource(
      futureRouteSourceId,
      route.futureRoutes.map((segment) => _segmentToFeature(segment)).toList(),
    );
  }

  /// Update a point source with features
  Future<void> _updatePointSource(
    String sourceId,
    List<Map<String, dynamic>> features,
  ) async {
    final featureCollection = {
      'type': 'FeatureCollection',
      'features': features,
    };

    final geoJson = jsonEncode(featureCollection);

    // Update the GeoJSON source with new data
    await _style.updateGeoJsonSource(id: sourceId, data: geoJson);
  }

  /// Update a line source with features
  Future<void> _updateLineSource(
    String sourceId,
    List<Map<String, dynamic>> features,
  ) async {
    final featureCollection = {
      'type': 'FeatureCollection',
      'features': features,
    };

    final geoJson = jsonEncode(featureCollection);

    // Update the GeoJSON source with new data
    await _style.updateGeoJsonSource(id: sourceId, data: geoJson);
  }

  /// Convert a port point to a GeoJSON feature
  Map<String, dynamic> _portToFeature(PortPoint port) {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': port.coordinates,
      },
      'properties': port.properties,
    };
  }

  /// Convert a route segment to a GeoJSON feature
  Map<String, dynamic> _segmentToFeature(RouteSegment segment) {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'LineString',
        'coordinates': segment.coordinates,
      },
      'properties': segment.properties,
    };
  }

  /// Fit the map view to include all loaded route points
  Future<void> fitToRoute(
    MapController controller,
    ContainerRoute route,
  ) async {
    // Collect all coordinates from points
    final List<Position> allPositions = [];

    // Add departure ports
    for (final port in route.departurePorts) {
      allPositions.add(Position(port.coordinates[0], port.coordinates[1]));
    }

    // Add destination ports
    for (final port in route.destinationPorts) {
      allPositions.add(Position(port.coordinates[0], port.coordinates[1]));
    }

    // Add intermediate ports
    for (final port in route.intermediatePorts) {
      allPositions.add(Position(port.coordinates[0], port.coordinates[1]));
    }

    // Add current positions
    for (final port in route.currentPositions) {
      allPositions.add(Position(port.coordinates[0], port.coordinates[1]));
    }

    // If we have positions, fit the map to them
    if (allPositions.isNotEmpty) {
      // Calculate bounds
      double minLng = double.infinity;
      double maxLng = -double.infinity;
      double minLat = double.infinity;
      double maxLat = -double.infinity;

      for (final position in allPositions) {
        // Explicitly cast to double to avoid type errors
        final double lng = position.lng.toDouble();
        final double lat = position.lat.toDouble();
        if (lng < minLng) minLng = lng;
        if (lng > maxLng) maxLng = lng;
        if (lat < minLat) minLat = lat;
        if (lat > maxLat) maxLat = lat;
      }

      // Create the bounds for the map to fit
      final bounds = LngLatBounds(
        longitudeWest: minLng,
        longitudeEast: maxLng,
        latitudeSouth: minLat,
        latitudeNorth: maxLat,
      );

      // Fit the map to the bounds
      await controller.fitBounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      );
    }
  }

  /// Load the custom SVG icons needed for the map
  Future<void> _loadCustomIcons() async {
    try {
      // Note: MapLibre might require bitmap images rather than SVG
      // For SVG rendering, you might need to add a package like flutter_svg and convert SVGs to bitmaps
      
      // For now, using a simplified approach - this assumes MapLibre can handle these formats
      // If this doesn't work, you may need to convert SVGs to PNG/JPEG format
      
      final departurePortImageData = await rootBundle.load('assets/icons/departurePortImage.png');
      await _style.addImage('departurePortImage', departurePortImageData.buffer.asUint8List());
      
      final destinationPortImageData = await rootBundle.load('assets/icons/destinationPortImage.png');
      await _style.addImage('destinationPortImage', destinationPortImageData.buffer.asUint8List());
      
      final intermediatePortImageData = await rootBundle.load('assets/icons/intermediatePortImage.png');
      await _style.addImage('intermediatePortImage', intermediatePortImageData.buffer.asUint8List());
      
      final currentPositionImageData = await rootBundle.load('assets/icons/currentPositionImage.png');
      await _style.addImage('currentPositionImage', currentPositionImageData.buffer.asUint8List());
    } catch (e) {
      print('Error loading custom icons: $e');
      // If loading SVGs directly fails, you might need to convert them to PNG/JPEG first
      // or use a predefined icon set that MapLibre supports
    }
  }
}
