import 'dart:developer' as developer;

/// Утилиты для анализа производительности приложения
class PerformanceUtils {
  // Карта для хранения времени начала замера
  static final Map<String, DateTime> _startTimes = {};
  
  /// Начинает замер времени для указанной метки
  static void startBenchmark(String label) {
    _startTimes[label] = DateTime.now();
  }
  
  /// Завершает замер времени и выводит результат в миллисекундах
  static int endBenchmark(String label) {
    if (_startTimes.containsKey(label)) {
      final endTime = DateTime.now();
      final elapsedMs = endTime.difference(_startTimes[label]!).inMilliseconds;
      developer.log('Benchmark [$label]: $elapsedMs ms');
      _startTimes.remove(label);
      return elapsedMs;
    } else {
      developer.log('Warning: attempted to end benchmark [$label] that was not started');
      return -1;
    }
  }
  
  /// Оборачивает функцию для измерения времени выполнения
  static Future<T> measureExecution<T>(String label, Future<T> Function() action) async {
    startBenchmark(label);
    try {
      final result = await action();
      endBenchmark(label);
      return result;
    } catch (e) {
      endBenchmark(label);
      rethrow;
    }
  }
  
  /// Добавляет отметку в журнале (DevTools Timeline) для профилирования
  static void addTimelineEvent(String label) {
    developer.Timeline.instantSync(label);
  }
  
  /// Оборачивает выполнение в секцию временной шкалы
  static Future<T> timelineSection<T>(String label, Future<T> Function() action) async {
    return developer.Timeline.timeSync(label, action);
  }
} 