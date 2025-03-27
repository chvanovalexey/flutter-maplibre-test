import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'map_styles.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'performance_overlay.dart';
import 'map_layers_info.dart';
import 'services/route_manager.dart';
import 'services/route_api_service.dart';
import 'models/container_route.dart';
import 'widgets/map_style_dropdown.dart';
import 'widgets/layer_visibility_control.dart';

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
  String _currentMapStyle = MapStyles.maptilerM1;
  
  // Добавляем переменную для управления видимостью счетчика производительности
  bool _showPerformanceOverlay = false;
  
  // Добавляем переменную для управления информацией о слоях карты
  bool _showLayersInfo = false;
  
  // Add route manager to handle container routes
  RouteManager? _routeManager;
  
  // Add state variable to track if route is loaded
  bool _routeLoaded = false;
  
  // Add state variable to track if bulk load is in progress
  bool _isLoadingBulk = false;
  
  // Add state variable to track if API route generation is in progress
  bool _isGeneratingApiRoutes = false;
  
  // Add controller for number of routes text field
  final TextEditingController _routeCountController = TextEditingController(text: '5');
  
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
      // Reset route manager and route loaded state
      _routeManager = null;
      _routeLoaded = false;
    });
  }
  
  // Method to handle layer visibility changes
  void _handleLayerVisibilityChange(String layerId, bool isVisible) {
    if (_mapController != null && _routeManager != null) {
      // Toggle layer visibility via the route manager
      _routeManager!.setLayerVisibility(layerId, isVisible);
    }
  }
  
  // Update the UI projection state based on the map style being used
  void _updateProjectionState(MapProjection projection) {
    if (_currentProjection != projection) {
      setState(() {
        _currentProjection = projection;
      });
    }
  }
  
  // Load sample route
  Future<void> _loadSampleRoute() async {
    try {
      if (_mapController != null) {
        // Initialize route manager if needed
        _routeManager ??= RouteManager(_mapController!);
        
        // Load the sample route
        await _routeManager!.loadRouteFromFile('assets/sample-geojson/sample-resp.geojson');
        
        // Update state
        setState(() {
          _routeLoaded = true;
        });
      }
    } catch (e) {
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error Loading Route'),
            content: Text('Failed to load route: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
  
  // Clear loaded route
  Future<void> _clearRoute() async {
    if (_routeManager != null) {
      await _routeManager!.clearRoute();
      setState(() {
        _routeLoaded = false;
      });
    }
  }
  
  // Load multiple GeoJSON files (from 1.geojson to 50.geojson)
  Future<void> _loadMultipleGeoJsonFiles() async {
    if (_isLoadingBulk) return;
    
    try {
      setState(() {
        _isLoadingBulk = true;
      });
      
      if (_mapController != null) {
        // Initialize route manager if needed
        _routeManager ??= RouteManager(_mapController!);
        
        // Create a list of file paths from 1.geojson to 50.geojson
        final filePaths = List.generate(
          50, 
          (index) => 'assets/sample-geojson/${index + 1}.geojson'
        );
        
        // Load all files and add to existing sources
        await _routeManager!.loadMultipleGeoJsonFiles(filePaths);
        
        // Update state
        setState(() {
          _routeLoaded = true;
          _isLoadingBulk = false;
        });
      }
    } catch (e) {
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error Loading Multiple Files'),
            content: Text('Failed to load GeoJSON files: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
        setState(() {
          _isLoadingBulk = false;
        });
      }
    }
  }
  
  // Print source contents to console
  Future<void> _printSourceContents() async {
    if (_routeManager != null) {
      await _routeManager!.printSourceContents();
    }
  }
  
  // Add method to generate and add routes via API
  Future<void> _generateAndAddApiRoutes() async {
    if (_isGeneratingApiRoutes) return;
    
    try {
      setState(() {
        _isGeneratingApiRoutes = true;
      });
      
      if (_mapController != null) {
        // Initialize route manager if needed
        _routeManager ??= RouteManager(_mapController!);
        
        // Parse the route count from the text field
        final int routeCount;
        try {
          routeCount = int.parse(_routeCountController.text);
        } catch (e) {
          // Show error dialog for invalid input
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Invalid Input'),
                content: const Text('Please enter a valid number of routes.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          setState(() {
            _isGeneratingApiRoutes = false;
          });
          return;
        }
        
        // Generate routes via API
        final routes = await RouteApiService.generateMultipleRoutes(routeCount);
        
        // Process each route and add to map
        for (final route in routes) {
          // Create a ContainerRoute object from the API response
          final containerRoute = ContainerRoute.fromGeoJson(route);
          
          // Add the route data to existing sources
          if (_routeManager != null) {
            // Use the public method in the RouteManager class
            // We need to load the first route properly
            if (!_routeLoaded) {
              await _routeManager!.loadRouteFromGeoJson(route);
              _routeLoaded = true;
            } else {
              // For subsequent routes, we add them to existing data
              await _routeManager!.addGeoJsonToExistingSources(route);
            }
          }
        }
        
        // Update state
        setState(() {
          _routeLoaded = true;
          _isGeneratingApiRoutes = false;
        });
      }
    } catch (e) {
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error Generating Routes'),
            content: Text('Failed to generate routes via API: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
        setState(() {
          _isGeneratingApiRoutes = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая карта'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Add route count text field
          Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: _routeCountController,
              decoration: const InputDecoration(
                labelText: 'Кол-во',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          // Add "Generate API Routes" button
          IconButton(
            icon: Icon(_isGeneratingApiRoutes ? Icons.sync : Icons.api),
            tooltip: 'Сгенерировать маршруты по API',
            onPressed: _isGeneratingApiRoutes ? null : _generateAndAddApiRoutes,
          ),
          // Add Style Dropdown in AppBar
          MapStyleDropdown(
            currentStyle: _currentMapStyle,
            onStyleChanged: _changeMapStyle,
          ),
          // Add Layer Visibility Control in AppBar
          LayerVisibilityControl(
            onLayerVisibilityChanged: _handleLayerVisibilityChange,
          ),
          // "Load Routes" button
          IconButton(
            icon: Icon(_routeLoaded ? Icons.directions_boat : Icons.directions_boat_outlined),
            tooltip: _routeLoaded ? 'Скрыть маршруты' : 'Загрузить маршруты',
            onPressed: _routeLoaded ? _clearRoute : _loadSampleRoute,
          ),
          // "Load Multiple GeoJSON Files" button
          IconButton(
            icon: Icon(_isLoadingBulk ? Icons.sync : Icons.file_upload),
            tooltip: 'Загрузить 50 GeoJSON файлов',
            onPressed: _isLoadingBulk ? null : _loadMultipleGeoJsonFiles,
          ),
          // "Print Source Contents" button
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Вывести содержимое источников',
            onPressed: _printSourceContents,
          ),
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
      body: MapLibreMap(
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
    );
  }
  
  @override
  void dispose() {
    // Dispose route manager
    _routeManager?.dispose();
    
    // Dispose text controller
    _routeCountController.dispose();
    
    super.dispose();
  }
} 