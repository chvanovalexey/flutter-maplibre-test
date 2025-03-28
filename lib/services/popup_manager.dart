import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import '../models/container_route.dart';
import '../widgets/map_marker_popup.dart';

/// Класс для управления всплывающими окнами при клике на маркеры карты
class PopupManager {
  /// Текущий выбранный маркер
  PortPoint? selectedMarker;
  
  /// Позиция маркера на экране
  Offset? markerScreenPosition;
  
  /// Контроллер карты
  final MapController _mapController;
  
  /// Конструктор
  PopupManager(this._mapController);
  
  /// Обработка события клика на карту
  Future<bool> handleMapClick(MapEvent event, ContainerRoute? route) async {
    if (event is! MapEventClick || route == null) {
      return false;
    }
    
    // Если уже есть открытое всплывающее окно, закрываем его
    if (selectedMarker != null) {
      selectedMarker = null;
      markerScreenPosition = null;
      return true; // Возвращаем true, чтобы указать, что состояние изменилось
    }
    
    // Получаем позицию клика на карте
    final clickPosition = event.point;
    
    // Ищем ближайший маркер к точке клика
    final nearestMarker = _findNearestMarker(clickPosition, route);
    
    if (nearestMarker != null) {
      // Обновляем выбранный маркер
      selectedMarker = nearestMarker;
      
      // Получаем позицию маркера на экране
      try {
        markerScreenPosition = await _mapController.toScreenLocation(
          Position(nearestMarker.coordinates[0], nearestMarker.coordinates[1])
        );
        return true; // Возвращаем true, чтобы указать, что состояние изменилось
      } catch (e) {
        print('Ошибка при определении позиции маркера на экране: $e');
        selectedMarker = null;
        return false;
      }
    }
    
    return false;
  }
  
  /// Поиск ближайшего маркера к точке клика
  PortPoint? _findNearestMarker(Position clickPosition, ContainerRoute route) {
    PortPoint? closestPoint;
    double minDistance = double.infinity;
    
    // Функция для проверки расстояния до точки
    void checkPointDistance(PortPoint port) {
      final double dx = port.coordinates[0] - clickPosition.lng;
      final double dy = port.coordinates[1] - clickPosition.lat;
      final double distance = dx * dx + dy * dy; // Используем квадрат расстояния для оптимизации
      
      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = port;
      }
    }
    
    // Проверяем все типы точек
    for (final port in route.departurePorts) {
      checkPointDistance(port);
    }
    
    for (final port in route.destinationPorts) {
      checkPointDistance(port);
    }
    
    for (final port in route.intermediatePorts) {
      checkPointDistance(port);
    }
    
    for (final port in route.currentPositions) {
      checkPointDistance(port);
    }
    
    // Устанавливаем фиксированный порог для определения, достаточно ли близко клик к маркеру
    const double threshold = 0.01; // Фиксированный порог
    
    if (closestPoint != null && minDistance < threshold * threshold) {
      return closestPoint;
    }
    
    return null;
  }
  
  /// Создание виджета всплывающего окна
  Widget? buildPopupWidget(BuildContext context, VoidCallback onClose) {
    if (selectedMarker == null || markerScreenPosition == null) {
      return null;
    }
    
    // Создаем всплывающее окно с информацией о маркере
    return Positioned(
      left: markerScreenPosition!.dx - 100, // Центрируем относительно маркера
      top: markerScreenPosition!.dy - 120, // Размещаем над маркером
      width: 220, // Фиксированная ширина для попапа
      child: MapMarkerPopup(
        title: selectedMarker!.name,
        description: _getFormattedDescription(selectedMarker!),
        properties: selectedMarker!.properties,
        onClose: () {
          // Сбрасываем выбранный маркер
          selectedMarker = null;
          markerScreenPosition = null;
          onClose(); // Вызываем callback для обновления состояния
        },
      ),
    );
  }
  
  /// Получение форматированного описания для маркера
  String _getFormattedDescription(PortPoint marker) {
    final pointType = marker.properties['pointType'] as String? ?? '';
    final description = marker.properties['description'] as String? ?? '';
    
    // Формируем подробное описание в зависимости от типа точки
    switch (pointType) {
      case 'departurePort':
        return 'Порт отправления\n$description';
      case 'destinationPort':
        return 'Порт назначения\n$description';
      case 'intermediatePort':
        final sequenceNumber = marker.properties['sequenceNumber'] as int? ?? 0;
        return 'Промежуточный порт #$sequenceNumber\n$description';
      case 'currentPosition':
        return 'Текущее положение\n$description';
      default:
        return description;
    }
  }
  
  /// Сброс выбранного маркера
  void resetSelection() {
    selectedMarker = null;
    markerScreenPosition = null;
  }
  
  /// Очистка ресурсов
  void dispose() {
    resetSelection();
  }
} 