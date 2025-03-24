import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'map_styles.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'performance_overlay.dart';

@immutable
class NewMapPage extends StatefulWidget {
  const NewMapPage({super.key});

  @override
  State<NewMapPage> createState() => _NewMapPageState();
}

class _NewMapPageState extends State<NewMapPage> {
  // Add controller to access map methods
  MapController? _mapController;
  
  // Add state variable to track current projection
  MapProjection _currentProjection = MapProjection.mercator;

  // Method to toggle between projections
  void _toggleProjection() {
    if (!kIsWeb) return; // Globe projection only supported on web
    
    setState(() {
      _currentProjection = _currentProjection == MapProjection.mercator
          ? MapProjection.globe
          : MapProjection.mercator;
    });
    
    // Apply the projection change if controller is available
    if (_mapController != null) {
      _mapController?.style?.setProjection(_currentProjection);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая карта'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Only show projection toggle on web platforms
          if (kIsWeb)
            IconButton(
              icon: Icon(
                _currentProjection == MapProjection.mercator 
                    ? Icons.map 
                    : Icons.public
              ),
              tooltip: _currentProjection == MapProjection.mercator 
                  ? 'Переключить на глобус'
                  : 'Переключить на плоскую карту',
              onPressed: _toggleProjection,
            ),
        ],
      ),
      body: MapLibreMap(
        options: MapOptions(
          initCenter: Position(37.62, 55.75), // Координаты Москвы (lng, lat)
          initZoom: 10,
          initStyle: MapStyles.protomapsLight, // Используем другой стиль карты
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          
          // Set initial projection on web platforms
          if (kIsWeb) {
            _mapController?.style?.setProjection(_currentProjection);
          }
        },
        children: [
          const MapScalebar(),
          const SourceAttribution(),
          const MapControlButtons(showTrackLocation: true),
          const MapCompass(),
          MapPerformanceOverlay(),
        ],
      ),
    );
  }
} 