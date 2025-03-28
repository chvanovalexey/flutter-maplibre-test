import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/map_styles.dart';
import '../config/app_constants.dart';
import '../widgets/performance_overlay.dart';
import '../widgets/map_layers_info.dart';
import '../services/route_manager.dart';
import '../services/route_api_service.dart';
import '../widgets/map_style_dropdown.dart';
import '../widgets/layer_visibility_control.dart';
import '../utils/performance_utils.dart';
import '../services/container_route_layer_manager.dart';
import '../models/container_route.dart';
import '../services/popup_manager.dart';

@immutable
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
  
  // Add state variable to track if API route generation is in progress
  bool _isGeneratingApiRoutes = false;
  
  // Add controller for number of routes text field
  final TextEditingController _routeCountController = TextEditingController(text: '5');
  
  // Добавляем контроллер для текстового поля фильтрации
  final TextEditingController _filterController = TextEditingController();

  // Менеджер всплывающих окон
  PopupManager? _popupManager;
  
  // Ключ для карты
  final _mapKey = GlobalKey();
  
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
      // Сбрасываем менеджер всплывающих окон
      _popupManager = null;
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
  
  // Toggle routes visibility
  Future<void> _toggleRoutes() async {
    if (_routeLoaded) {
      await _clearRoute();
    } else {
      await _generateAndAddApiRoutes();
    }
  }
  
  // Clear loaded route
  Future<void> _clearRoute() async {
    if (_routeManager != null) {
      await _routeManager!.clearRoute();
      setState(() {
        _routeLoaded = false;
        // Сбрасываем выбранный маркер
        if (_popupManager != null) {
          _popupManager!.resetSelection();
        }
      });
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
      
      // Замеряем общее время генерации и добавления маршрутов
      await PerformanceUtils.measureExecution('generate_and_add_routes', () async {
        if (_mapController != null) {
          // Initialize route manager if needed
          _routeManager ??= RouteManager(_mapController!);
          
          // Инициализируем менеджер всплывающих окон, если не инициализирован
          _popupManager ??= PopupManager(_mapController!);
          
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
            return;
          }
          
          // Generate routes via API
          final routes = await RouteApiService.generateMultipleRoutes(routeCount);
          
          // Замеряем время обработки и отображения маршрутов
          await PerformanceUtils.measureExecution('process_routes', () async {
            // Process each route and add to map
            for (final route in routes) {
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
          });
        }
      });
      
      // Update state
      setState(() {
        _routeLoaded = true;
        _isGeneratingApiRoutes = false;
      });
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
  
  // Метод для применения фильтра к слоям карты
  void _applyFilter(String filterText) {
    if (_routeManager == null) return;
    
    // Если поле фильтра пустое, перезагружаем все данные
    if (filterText.isEmpty) {
      _reloadRouteWithoutFilter();
      return;
    }
    
    try {
      // Фильтруем тут
      if (_routeManager!.currentRoute != null) {
        // Фильтруем все данные маршрута
        _filterCurrentRoute(filterText.toLowerCase());
      }
    } catch (e) {
      print('Ошибка при применении фильтра: $e');
    }
  }
  
  // Метод для фильтрации текущего маршрута
  void _filterCurrentRoute(String filterText) {
    if (_routeManager == null || _routeManager!.currentRoute == null) return;
    
    // Получаем копию текущего маршрута
    final route = _routeManager!.currentRoute!;
    
    // Создаем фильтрованные списки
    final filteredDeparturePorts = route.departurePorts
        .where((port) => port.name.toLowerCase().contains(filterText))
        .toList();
    
    final filteredDestinationPorts = route.destinationPorts
        .where((port) => port.name.toLowerCase().contains(filterText))
        .toList();
    
    final filteredIntermediatePorts = route.intermediatePorts
        .where((port) => port.name.toLowerCase().contains(filterText))
        .toList();
    
    final filteredCurrentPositions = route.currentPositions
        .where((port) => port.name.toLowerCase().contains(filterText))
        .toList();
    
    // Создаем новый временный маршрут для отображения фильтрованных данных
    final filteredRoute = ContainerRoute(
      departurePorts: filteredDeparturePorts, 
      destinationPorts: filteredDestinationPorts,
      intermediatePorts: filteredIntermediatePorts,
      currentPositions: filteredCurrentPositions,
      pastRoutes: route.pastRoutes,
      futureRoutes: route.futureRoutes
    );
    
    // Обновляем источники через RouteManager
    if (_routeManager != null) {
      _routeManager!.loadFilteredRoute(filteredRoute);
    }
  }
  
  // Метод для перезагрузки маршрута без фильтра
  void _reloadRouteWithoutFilter() {
    if (_routeManager == null || _routeManager!.currentRoute == null) return;
    
    // Просто обновляем все источники с полными данными текущего маршрута
    _routeManager!.reloadCurrentRoute();
  }
  
  // Метод для обработки событий карты
  Future<void> _handleMapEvent(MapEvent event) async {
    if (_popupManager != null && _routeManager?.currentRoute != null) {
      // Обрабатываем клик для показа всплывающего окна
      final stateChanged = await _popupManager!.handleMapClick(event, _routeManager!.currentRoute);
      
      // Если состояние изменилось, обновляем UI
      if (stateChanged) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта MapLibre'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Добавляем поле для фильтрации
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: TextField(
                controller: _filterController,
                decoration: const InputDecoration(
                  hintText: 'Фильтр по названию',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: _applyFilter,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
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
          // "Toggle Routes" button
          IconButton(
            icon: Icon(_routeLoaded ? Icons.directions_boat : Icons.directions_boat_outlined),
            tooltip: _routeLoaded ? 'Скрыть маршруты' : 'Показать маршруты',
            onPressed: _toggleRoutes,
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
        key: _mapKey,
        options: MapOptions(
          initCenter: Position(
            AppConstants.initialLongitude, 
            AppConstants.initialLatitude
          ), // Координаты из констант
          initZoom: AppConstants.initialZoom,
          initStyle: _currentMapStyle, // Use current style from state
          // Для Android используем TextureMode, что может влиять на производительность
          androidTextureMode: false
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          
          // Set initial projection on web platforms
          if (kIsWeb) {
            _mapController?.style?.setProjection(_currentProjection);
          }
          
          // Инициализируем менеджер всплывающих окон
          _popupManager = PopupManager(controller);
        },
        onStyleLoaded: (style) {
          // When style is loaded, ensure our projection state matches what the map is using
          if (kIsWeb) {
            // Since we can't directly query the current projection,
            // we'll update our state variable to match what we just set
            _updateProjectionState(_currentProjection);
          }
        },
        onEvent: _handleMapEvent, // Обработчик событий карты
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
          // Добавляем всплывающее окно при выборе маркера
          if (_popupManager != null)
            Builder(
              builder: (context) => _popupManager!.buildPopupWidget(
                context, 
                () => setState(() {}), // Callback для обновления состояния
              ) ?? const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    // Dispose route manager
    _routeManager?.dispose();
    
    // Dispose popup manager
    _popupManager?.dispose();
    
    // Dispose text controllers
    _routeCountController.dispose();
    _filterController.dispose();
    
    super.dispose();
  }
} 