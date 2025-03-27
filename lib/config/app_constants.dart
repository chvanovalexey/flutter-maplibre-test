/// Константы приложения
class AppConstants {
  /// API URL для расчета морских маршрутов
  static const routeApiUrl = 'https://europe-west1-bollo-tracker.cloudfunctions.net/calculateComplexSeaRoute';
  
  /// Начальные координаты для карты (Москва)
  static const initialLatitude = 55.75;
  static const initialLongitude = 37.62;
  
  /// Настройки зума карты
  static const initialZoom = 0.0;
  
  /// Настройки для тюнинга производительности
  static const performanceUpdateIntervalMs = 1000;
  static const performanceSampleCount = 60;
  static const jankThresholdMultiplier = 1.5;
} 