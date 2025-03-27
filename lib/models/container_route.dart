/// Container route model based on the GeoJSON structure
class ContainerRoute {
  final List<PortPoint> departurePorts;
  final List<PortPoint> destinationPorts;
  final List<PortPoint> intermediatePorts;
  final List<PortPoint> currentPositions;
  final List<RouteSegment> pastRoutes;
  final List<RouteSegment> futureRoutes;
  
  ContainerRoute({
    this.departurePorts = const [],
    this.destinationPorts = const [],
    this.intermediatePorts = const [],
    this.currentPositions = const [],
    this.pastRoutes = const [],
    this.futureRoutes = const [],
  });
  
  /// Parse a GeoJSON FeatureCollection into a ContainerRoute
  factory ContainerRoute.fromGeoJson(Map<String, dynamic> geojson) {
    // Create empty lists for each type of feature
    final List<PortPoint> departurePorts = [];
    final List<PortPoint> destinationPorts = [];
    final List<PortPoint> intermediatePorts = [];
    final List<PortPoint> currentPositions = [];
    final List<RouteSegment> pastRoutes = [];
    final List<RouteSegment> futureRoutes = [];
    
    // Ensure we have a FeatureCollection
    if (geojson['type'] != 'FeatureCollection') {
      throw ArgumentError('Invalid GeoJSON: not a FeatureCollection');
    }
    
    // Process each feature
    final features = geojson['features'] as List;
    for (var feature in features) {
      // Get properties
      final properties = feature['properties'] as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>;
      
      // Check if it's a Point or LineString
      if (geometry['type'] == 'Point') {
        final coordinates = (geometry['coordinates'] as List).cast<num>();
        final point = PortPoint(
          name: properties['name'] as String? ?? '',
          coordinates: [coordinates[0].toDouble(), coordinates[1].toDouble()],
          properties: properties,
        );
        
        // Categorize by pointType
        final pointType = properties['pointType'] as String? ?? '';
        switch (pointType) {
          case 'departurePort':
            departurePorts.add(point);
            break;
          case 'destinationPort':
            destinationPorts.add(point);
            break;
          case 'intermediatePort':
            intermediatePorts.add(point);
            break;
          case 'currentPosition':
            currentPositions.add(point);
            break;
        }
      } else if (geometry['type'] == 'LineString') {
        // For routes (LineString)
        final List<List<double>> coordinates = (geometry['coordinates'] as List)
            .map((coord) => (coord as List).map((c) => (c as num).toDouble()).toList())
            .toList();
        
        final routeSegment = RouteSegment(
          from: properties['from'] as String? ?? '',
          to: properties['to'] as String? ?? '',
          coordinates: coordinates,
          properties: properties,
        );
        
        // Categorize by segmentType
        final segmentType = properties['segmentType'] as String? ?? '';
        if (segmentType == 'past') {
          pastRoutes.add(routeSegment);
        } else if (segmentType == 'future') {
          futureRoutes.add(routeSegment);
        }
      } else if (geometry['type'] == 'MultiLineString') {
        // Для маршрутов типа MultiLineString (когда линия пересекает 180-й меридиан)
        final List<List<List<double>>> multiCoordinates = (geometry['coordinates'] as List)
            .map((lineCoords) =>
              (lineCoords as List).map((coord) =>
                (coord as List).map((c) => (c as num).toDouble()).toList()
              ).toList()
            )
            .toList();
        
        // Создаем отдельный сегмент маршрута для каждой линии в MultiLineString
        for (var coordinates in multiCoordinates) {
          final routeSegment = RouteSegment(
            from: properties['from'] as String? ?? '',
            to: properties['to'] as String? ?? '',
            coordinates: coordinates,
            properties: properties,
          );
          
          // Категоризируем по типу сегмента
          final segmentType = properties['segmentType'] as String? ?? '';
          if (segmentType == 'past') {
            pastRoutes.add(routeSegment);
          } else if (segmentType == 'future') {
            futureRoutes.add(routeSegment);
          }
        }
      }
    }
    
    return ContainerRoute(
      departurePorts: departurePorts,
      destinationPorts: destinationPorts,
      intermediatePorts: intermediatePorts,
      currentPositions: currentPositions,
      pastRoutes: pastRoutes,
      futureRoutes: futureRoutes,
    );
  }
}

/// Represents a port point in the route
class PortPoint {
  final String name;
  final List<double> coordinates; // [longitude, latitude]
  final Map<String, dynamic> properties;
  
  PortPoint({
    required this.name,
    required this.coordinates,
    this.properties = const {},
  });
}

/// Represents a route segment
class RouteSegment {
  final String from;
  final String to;
  final List<List<double>> coordinates; // List of [longitude, latitude] points
  final Map<String, dynamic> properties;
  
  RouteSegment({
    required this.from,
    required this.to,
    required this.coordinates,
    this.properties = const {},
  });
  
  /// Возвращает новый RouteSegment с обработанными координатами для корректного
  /// отображения линий, пересекающих 180-й меридиан
  RouteSegment adjustForAntimeridian() {
    // Если у нас нет как минимум двух точек для линии, возвращаем сегмент без изменений
    if (coordinates.length < 2) {
      return this;
    }

    // Создаем новый список координат для обработки
    List<List<double>> adjustedCoordinates = [];
    
    // Проходим по всем сегментам линии (парам последовательных точек)
    for (int i = 0; i < coordinates.length - 1; i++) {
      double lng1 = coordinates[i][0];
      double lat1 = coordinates[i][1];
      double lng2 = coordinates[i + 1][0];
      double lat2 = coordinates[i + 1][1];
      
      // Добавляем первую точку сегмента
      adjustedCoordinates.add([lng1, lat1]);
      
      // Проверяем, пересекает ли сегмент 180-й меридиан
      // Если разница долгот больше 180 градусов, значит сегмент пересекает 180-й меридиан
      if ((lng2 - lng1).abs() > 180) {
        // Определяем направление пересечения (с запада на восток или с востока на запад)
        double westLng, eastLng;
        if (lng1 < lng2) {
          // lng1 на западе от -180, lng2 на востоке от +180
          westLng = lng1;
          eastLng = lng2;
        } else {
          // lng1 на востоке от +180, lng2 на западе от -180
          westLng = lng2;
          eastLng = lng1;
        }
        
        // Нормализуем восточную долготу, чтобы она стала < -180
        eastLng -= 360;
        
        // Вычисляем широту в точке пересечения с меридианом -180
        // Используем линейную интерполяцию
        double t = (-180 - westLng) / (eastLng - westLng);
        double latAtMinus180 = lat1 + t * (lat2 - lat1);
        
        // Добавляем точку пересечения с меридианом -180
        adjustedCoordinates.add([-180, latAtMinus180]);
        
        // Вычисляем широту в точке пересечения с меридианом +180
        double latAt180 = latAtMinus180; // Та же широта, т.к. -180 и +180 - это один и тот же меридиан
        
        // Добавляем точку пересечения с меридианом +180
        adjustedCoordinates.add([180, latAt180]);
      }
    }
    
    // Добавляем последнюю точку линии
    adjustedCoordinates.add(coordinates.last);
    
    return RouteSegment(
      from: from,
      to: to,
      coordinates: adjustedCoordinates,
      properties: properties,
    );
  }
} 