import 'dart:convert';
//import 'dart:io';
import 'package:flutter/material.dart' show EdgeInsets;
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
        layout: {
          'line-cap': 'round',
          'line-join': 'round',
        },
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
        layout: {
          'line-cap': 'round',
          'line-join': 'round',
        },
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
    // Обрабатываем линии, пересекающие 180-й меридиан
    final processedFeatures = features.map((feature) {
      // Извлекаем GeoJSON объект для обработки
      final Map<String, dynamic> geometry = feature['geometry'] as Map<String, dynamic>;
      final Map<String, dynamic> properties = feature['properties'] as Map<String, dynamic>;
      
      // Если это LineString, проверяем на пересечение 180-го меридиана
      if (geometry['type'] == 'LineString') {
        final List<List<double>> coordinates = List<List<double>>.from(
          (geometry['coordinates'] as List).map((coord) => List<double>.from(coord))
        );
        
        // Простой и надежный подход для решения проблемы 180-го меридиана
        for (int i = 0; i < coordinates.length - 1; i++) {
          double lng1 = coordinates[i][0];
          double lng2 = coordinates[i + 1][0];
          
          // Если разница больше 180 градусов, значит линия пересекает антимеридиан
          if ((lng2 - lng1).abs() > 180) {
            // Преобразуем координаты в MultiLineString
            List<List<List<double>>> multiCoords = [];
            
            // Первая часть линии до пересечения
            List<List<double>> part1 = coordinates.sublist(0, i + 1);
            
            // Добавляем точку пересечения с меридианом
            double lat1 = coordinates[i][1];
            double lat2 = coordinates[i + 1][1];
            double t = (lng1 < lng2) ? 
                (180 - lng1) / ((lng2 > lng1 ? lng2 : lng2 + 360) - lng1) : 
                (-180 - lng1) / ((lng2 < lng1 ? lng2 : lng2 - 360) - lng1);
            double latAtMeridian = lat1 + t * (lat2 - lat1);
            
            // Точка на меридиане
            double meridianLng = (lng1 < lng2) ? 180 : -180;
            part1.add([meridianLng, latAtMeridian]);
            multiCoords.add(part1);
            
            // Вторая часть линии после пересечения
            List<List<double>> part2 = [];
            part2.add([(meridianLng == 180) ? -180 : 180, latAtMeridian]);
            part2.addAll(coordinates.sublist(i + 1));
            multiCoords.add(part2);
            
            // Возвращаем MultiLineString вместо LineString
            return {
              'type': 'Feature',
              'geometry': {
                'type': 'MultiLineString',
                'coordinates': multiCoords,
              },
              'properties': properties,
            };
          }
        }
      }
      
      // Если изменения не требуются, возвращаем исходный объект
      return feature;
    }).toList();

    final featureCollection = {
      'type': 'FeatureCollection',
      'features': processedFeatures,
    };

    final geoJson = jsonEncode(featureCollection);

    // Обновляем источник GeoJSON
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
    // В данном случае мы возвращаем оригинальные координаты сегмента,
    // так как _updateLineSource будет обрабатывать пересечение 180-го меридиана
    // и создавать MultiLineString при необходимости
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
    // Собираем все точки маршрута
    final List<Position> allPositions = [];

    // Добавляем точки портов
    for (final port in route.departurePorts) {
      allPositions.add(Position(port.coordinates[0], port.coordinates[1]));
    }
    for (final port in route.destinationPorts) {
      allPositions.add(Position(port.coordinates[0], port.coordinates[1]));
    }
    for (final port in route.intermediatePorts) {
      allPositions.add(Position(port.coordinates[0], port.coordinates[1]));
    }
    for (final port in route.currentPositions) {
      allPositions.add(Position(port.coordinates[0], port.coordinates[1]));
    }

    // Проверяем, есть ли у нас маршруты, пересекающие 180-й меридиан
    bool hasCrossAntimeridianRoutes = false;
    
    // Проверка маршрутов на пересечение антимеридиана
    for (final segment in [...route.pastRoutes, ...route.futureRoutes]) {
      if (segment.coordinates.length < 2) continue;
      
      for (int i = 0; i < segment.coordinates.length - 1; i++) {
        final double lng1 = segment.coordinates[i][0];
        final double lng2 = segment.coordinates[i + 1][0];
        
        if ((lng2 - lng1).abs() > 180) {
          hasCrossAntimeridianRoutes = true;
          break;
        }
      }
      
      if (hasCrossAntimeridianRoutes) break;
    }

    // Добавляем координаты маршрутов с учетом возможных пересечений
    for (final segment in [...route.pastRoutes, ...route.futureRoutes]) {
      if (hasCrossAntimeridianRoutes) {
        // Если есть пересечения, используем скорректированные координаты
        // которые перенесены в соответствующие полушария
        final adjusted = segment.adjustForAntimeridian();
        for (final coord in adjusted.coordinates) {
          allPositions.add(Position(coord[0], coord[1]));
        }
      } else {
        // Если пересечений нет, используем оригинальные координаты
        for (final coord in segment.coordinates) {
          allPositions.add(Position(coord[0], coord[1]));
        }
      }
    }

    // Если у нас есть позиции, устанавливаем соответствующие границы карты
    if (allPositions.isNotEmpty) {
      // Рассчитываем границы
      double minLng = double.infinity;
      double maxLng = -double.infinity;
      double minLat = double.infinity;
      double maxLat = -double.infinity;

      for (final position in allPositions) {
        final double lng = position.lng.toDouble();
        final double lat = position.lat.toDouble();
        
        // Обновляем границы широты
        if (lat < minLat) minLat = lat;
        if (lat > maxLat) maxLat = lat;
        
        // Обновляем границы долготы только если это не пересечение антимеридиана
        // или если мы используем скорректированные координаты
        if (!hasCrossAntimeridianRoutes || (lng >= -180 && lng <= 180)) {
          if (lng < minLng) minLng = lng;
          if (lng > maxLng) maxLng = lng;
        }
      }
      
      // Проверяем на случай, если корректировка координат не помогла
      // и границы все еще слишком широкие
      if (maxLng - minLng > 300 || hasCrossAntimeridianRoutes) {
        // Делим координаты на две группы: восточное и западное полушарие
        List<Position> westPositions = [];
        List<Position> eastPositions = [];
        
        for (final position in allPositions) {
          final double lng = position.lng.toDouble();
          
          // Игнорируем точки, которые могут быть артефактами корректировки
          if (lng < -180 || lng > 180) continue;
          
          if (lng < 0) {
            westPositions.add(position);
          } else {
            eastPositions.add(position);
          }
        }
        
        // Выбираем полушарие с большим количеством точек
        List<Position> dominantPositions = 
            (westPositions.length > eastPositions.length) ? westPositions : eastPositions;
        
        // Если мы не нашли доминирующее полушарие, используем оригинальные координаты
        if (dominantPositions.isEmpty) {
          dominantPositions = allPositions;
        }
        
        // Пересчитываем границы только для доминирующего полушария
        minLng = double.infinity;
        maxLng = -double.infinity;
        minLat = double.infinity;
        maxLat = -double.infinity;
        
        for (final position in dominantPositions) {
          final double lng = position.lng.toDouble();
          final double lat = position.lat.toDouble();
          
          if (lat < minLat) minLat = lat;
          if (lat > maxLat) maxLat = lat;
          if (lng < minLng) minLng = lng;
          if (lng > maxLng) maxLng = lng;
        }
      }
      
      // Создаем границы карты и устанавливаем их
      final bounds = LngLatBounds(
        longitudeWest: minLng,
        longitudeEast: maxLng,
        latitudeSouth: minLat,
        latitudeNorth: maxLat,
      );
      
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

  /// Set the visibility of a specific layer
  Future<void> setLayerVisibility(String layerId, bool isVisible) async {
    try {
      // We need to first remove the layer
      try {
        await _style.removeLayer(layerId);
      } catch (e) {
        // Layer might not exist yet, that's ok
      }
      
      // If the layer should be visible, add it back
      if (isVisible) {
        switch (layerId) {
          case departurePortsLayerId:
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
                  ],
                  'text-offset': [0, 1.5],
                  'text-anchor': 'top',
                  'text-size': 12,
                  'text-allow-overlap': false,
                },
              ),
            );
            break;
          case destinationPortsLayerId:
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
                  ],
                  'text-offset': [0, 1.5],
                  'text-anchor': 'top',
                  'text-size': 12,
                  'text-allow-overlap': false,
                },
              ),
            );
            break;
          case intermediatePortsLayerId:
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
                  ],
                  'text-offset': [0, 1.5],
                  'text-anchor': 'top',
                  'text-size': 11,
                  'text-allow-overlap': false,
                },
              ),
            );
            break;
          case currentPositionLayerId:
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
                  ],
                  'text-offset': [0, 1.5],
                  'text-anchor': 'top',
                  'text-size': 12,
                  'text-allow-overlap': false,
                },
              ),
            );
            break;
          case pastRouteLayerId:
            await _style.addLayer(
              LineStyleLayer(
                id: pastRouteLayerId,
                sourceId: pastRouteSourceId,
                layout: {
                  'line-cap': 'round',
                  'line-join': 'round',
                },
                paint: {
                  'line-color': ['get', 'stroke'],
                  'line-width': 4,
                  'line-opacity': 0.8,
                },
              ),
            );
            break;
          case futureRouteLayerId:
            await _style.addLayer(
              LineStyleLayer(
                id: futureRouteLayerId,
                sourceId: futureRouteSourceId,
                layout: {
                  'line-cap': 'round',
                  'line-join': 'round',
                },
                paint: {
                  'line-color': ['get', 'stroke'],
                  'line-width': 2,
                  'line-opacity': 0.6,
                  'line-dasharray': [5, 5],
                },
              ),
            );
            break;
        }
      }
    } catch (e) {
      print('Error setting layer visibility: $e');
    }
  }
}
