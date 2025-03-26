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
} 