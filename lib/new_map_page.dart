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
  
  // Add state variable to track current map style
  String _currentMapStyle = MapStyles.protomapsLight;
  
  // Key to force rebuild the map when style changes
 // final _mapKey = GlobalKey();

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
  
  // Method to change map style
  void _changeMapStyle(String style) {
    if (_currentMapStyle == style) return;
    
    setState(() {
      _currentMapStyle = style;
      // Reset controller to force map recreation with new style
      _mapController = null;
    });
  }
  
  // Build radio list tiles for all map styles
  List<Widget> _buildStyleRadioButtons() {
    final Map<String, String> styles = MapStyles.getAllStyles();
    return styles.entries.map((entry) {
      return RadioListTile<String>(
        title: Text(entry.value),
        value: entry.key,
        groupValue: _currentMapStyle,
        onChanged: (value) => _changeMapStyle(value!),
      );
    }).toList();
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
      body: Row(
        children: [
          // Left panel with style radio buttons
          Container(
            width: 200,
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Стили карты',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Dynamically generated radio buttons for map styles
                ..._buildStyleRadioButtons(),
              ],
            ),
          ),
          // Map takes remaining width
          Expanded(
            child: MapLibreMap(
              key: ValueKey(_currentMapStyle), // Add key based on style to force rebuild
              options: MapOptions(
                initCenter: Position(37.62, 55.75), // Координаты Москвы (lng, lat)
                initZoom: 10,
                initStyle: _currentMapStyle, // Use current style from state
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
                // Custom SourceAttribution with flexible constraints to handle overflow
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SourceAttribution(),
                    ),
                  ),
                ),
                const MapControlButtons(showTrackLocation: true),
                const MapCompass(),
                MapPerformanceOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 