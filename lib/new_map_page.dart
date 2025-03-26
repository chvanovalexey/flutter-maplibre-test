import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'map_styles.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'performance_overlay.dart';
import 'map_layers_info.dart';

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
  
  // Добавляем переменную для управления видимостью счетчика производительности
  bool _showPerformanceOverlay = false;
  
  // Добавляем переменную для управления информацией о слоях карты
  bool _showLayersInfo = false;
  
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
  
  // Update the UI projection state based on the map style being used
  void _updateProjectionState(MapProjection projection) {
    if (_currentProjection != projection) {
      setState(() {
        _currentProjection = projection;
      });
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
          // Добавляем кнопку включения/выключения счетчика производительности
          IconButton(
            icon: Icon(_showPerformanceOverlay ? Icons.speed : Icons.speed_outlined),
            tooltip: _showPerformanceOverlay 
                ? 'Скрыть счетчик производительности' 
                : 'Показать счетчик производительности',
            onPressed: () {
              setState(() {
                _showPerformanceOverlay = !_showPerformanceOverlay;
              });
            },
          ),
          // Добавляем кнопку включения/выключения информации о слоях карты
          IconButton(
            icon: Icon(_showLayersInfo ? Icons.layers : Icons.layers_outlined),
            tooltip: _showLayersInfo 
                ? 'Скрыть информацию о слоях карты' 
                : 'Показать информацию о слоях карты',
            onPressed: () {
              setState(() {
                _showLayersInfo = !_showLayersInfo;
              });
            },
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
                // Wrap in Expanded + SingleChildScrollView to make it scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _buildStyleRadioButtons(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Map takes remaining width
          Expanded(
            child: MapLibreMap(
              key: ValueKey(_currentMapStyle), // Add key based on style to force rebuild
              options: MapOptions(
                initCenter: Position(37.62, 55.75), // Координаты Москвы (lng, lat)
                initZoom: 0,
                initStyle: _currentMapStyle, // Use current style from state
                // Для Android используем TextureMode, что может влиять на производительность
                // Отключение TextureMode на Android может в некоторых случаях улучшить производительность
                androidTextureMode: false
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                
                // Set initial projection on web platforms
                if (kIsWeb) {
                  _mapController?.style?.setProjection(_currentProjection);
                }
              },
              onStyleLoaded: (style) {
                // When style is loaded, ensure our projection state matches what the map is using
                if (kIsWeb) {
                  // Since we can't directly query the current projection,
                  // we'll update our state variable to match what we just set
                  _updateProjectionState(_currentProjection);
                }
              },
              children: [
                const MapScalebar(alignment: Alignment.bottomRight),
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
                MapPerformanceOverlay(enabled: _showPerformanceOverlay),
                // Добавляем виджет информации о слоях карты
                Positioned(
                  top: 100, // Позиционируем ниже счетчика производительности
                  right: 0,
                  child: MapLayersInfo(
                    enabled: _showLayersInfo,
                    styleUrl: _currentMapStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 