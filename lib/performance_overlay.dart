import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditionally import dart:html only for web
import 'web_gl_detector.dart' if (dart.library.html) 'web_gl_detector_web.dart';

/// Display performance metrics on the map
/// 
/// Shows FPS, Frame time, Jank score, and WebGL availability
@immutable
class MapPerformanceOverlay extends StatefulWidget {
  /// Creates a performance overlay widget
  const MapPerformanceOverlay({
    this.alignment = Alignment.centerRight,
    this.padding = const EdgeInsets.all(12),
    this.enabled = true, // Добавлен параметр enabled для возможности включения/выключения
    super.key,
  });

  /// The [Alignment] of the performance overlay.
  final Alignment alignment;

  /// The [padding] of the performance overlay.
  final EdgeInsets padding;
  
  /// Whether the performance overlay is enabled.
  /// When false, the ticker is paused and no performance metrics are collected.
  final bool enabled;

  @override
  State<MapPerformanceOverlay> createState() => _MapPerformanceOverlayState();
}

class _MapPerformanceOverlayState extends State<MapPerformanceOverlay> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _fps = 0;
  double _frameTime = 0;
  int _jankScore = 0;
  bool _isWebGLAvailable = false;

  // Для подсчета FPS и измерения времени кадра
  int _frameCount = 0;
  Duration _lastTime = Duration.zero;
  List<Duration> _frameTimes = [];
  
  // Переменная для снижения частоты обновления состояния
  Duration _lastUpdateTime = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (widget.enabled) {
      _ticker.start();
    }
    _checkWebGLAvailability();
  }

  @override
  void didUpdateWidget(MapPerformanceOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Включение/выключение тикера в зависимости от значения enabled
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _ticker.start();
      } else {
        _ticker.stop();
      }
    }
  }

  /// Checks if WebGL is available on the current platform
  /// For non-web platforms, this will always return false
  void _checkWebGLAvailability() {
    setState(() {
      _isWebGLAvailable = isWebGLAvailable();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    _frameCount++;
    
    // Рассчет FPS и времени кадра
    if (_lastTime != Duration.zero) {
      final frameDuration = elapsed - _lastTime;
      _frameTimes.add(frameDuration);
      
      // Сохраняем только последние 60 кадров для расчетов
      if (_frameTimes.length > 60) {
        _frameTimes.removeAt(0);
      }
      
      // Обновляем значения не чаще, чем раз в секунду
      // Это значительно снижает нагрузку от частых вызовов setState
      if (_lastUpdateTime == Duration.zero || 
          elapsed - _lastUpdateTime > const Duration(milliseconds: 1000)) {
        _lastUpdateTime = elapsed;
        
        // Рассчитываем средний FPS
        final avgDuration = _frameTimes.fold<Duration>(
            Duration.zero, (sum, duration) => sum + duration) ~/ _frameTimes.length;
        
        // FPS = 1 секунда / среднее время кадра
        final newFps = 1000 / avgDuration.inMilliseconds.toDouble();
        // Среднее время кадра в миллисекундах
        final newFrameTime = avgDuration.inMicroseconds / 1000;
        
        // Простой алгоритм подсчета Jank score
        // Считаем кадры, которые превышают средний показатель на 50%
        int jankFrames = 0;
        final threshold = avgDuration.inMicroseconds * 1.5;
        for (var duration in _frameTimes) {
          if (duration.inMicroseconds > threshold) {
            jankFrames++;
          }
        }
        // Jank score как процент проблемных кадров
        final newJankScore = (jankFrames / _frameTimes.length * 100).round();
        
        setState(() {
          _fps = newFps;
          _frameTime = newFrameTime;
          _jankScore = newJankScore;
        });
      }
    }
    
    _lastTime = elapsed;
  }

  @override
  Widget build(BuildContext context) {
    // Если оверлей отключен, возвращаем пустой контейнер
    if (!widget.enabled) {
      return const SizedBox.shrink();
    }
    
    final theme = Theme.of(context);
    
    // Increase the size of the overlay to accommodate the new WebGL information
    return Container(
      alignment: widget.alignment,
      padding: widget.padding,
      child: CustomPaint(
        painter: _PerformanceMetricsPainter(
          fps: _fps, 
          frameTime: _frameTime, 
          jankScore: _jankScore,
          isWebGLAvailable: _isWebGLAvailable,
          theme: theme,
        ),
        size: const Size(130, 90),
      ),
    );
  }
}

class _PerformanceMetricsPainter extends CustomPainter {
  _PerformanceMetricsPainter({
    required this.fps,
    required this.frameTime,
    required this.jankScore,
    required this.isWebGLAvailable,
    required this.theme,
  });

  final double fps;
  final double frameTime;
  final int jankScore;
  final bool isWebGLAvailable;
  final ThemeData theme;

  late final _backgroundPaint = Paint()..color = Colors.white60;

  @override
  void paint(Canvas canvas, Size size) {
    // Рисуем фоновый прямоугольник
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, _backgroundPaint);
    //canvas.drawRect(rect, _borderPaint);

    // Создаем текстовый стиль
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
    
    // Выводим FPS с цветовой индикацией (выше - лучше)
    // Для 60Hz дисплеев: >50 - отлично, >30 - приемлемо, <30 - плохо
    final fpsColor = fps > 50 ? Colors.green : (fps > 30 ? Colors.orange : Colors.red);
    _drawText(
      canvas, 
      'FPS: ${fps.toStringAsFixed(0)}', 
      textStyle?.copyWith(color: fpsColor), 
      5, 
      15
    );
    
    // Выводим Frame time с цветовой индикацией (ниже - лучше)
    // <18ms - отлично (60+ FPS), <33ms - приемлемо (30+ FPS), >33ms - плохо
    final frameTimeColor = frameTime < 18 ? Colors.green : (frameTime < 33 ? Colors.orange : Colors.red);
    _drawText(
      canvas, 
      'Frame: ${frameTime.toStringAsFixed(0)} ms', 
      textStyle?.copyWith(color: frameTimeColor), 
      5, 
      35
    );
    
    // Выводим Jank score
    final jankColor = jankScore < 5 ? Colors.green : (jankScore < 20 ? Colors.orange : Colors.red);
    _drawText(
      canvas, 
      'Jank: $jankScore%', 
      textStyle?.copyWith(color: jankColor), 
      5, 
      55
    );
    
    // Выводим доступность WebGL
    final webGLColor = isWebGLAvailable ? Colors.green : Colors.red;
    final webGLText = kIsWeb 
        ? (isWebGLAvailable ? 'WebGL: Доступен' : 'WebGL: Недоступен')
        : 'WebGL: Недоступен (не web)';
    
    _drawText(
      canvas, 
      webGLText, 
      textStyle?.copyWith(color: webGLColor), 
      5, 
      75
    );
  }

  void _drawText(Canvas canvas, String text, TextStyle? style, double x, double y) {
    final textPainter = TextPainter(
      text: TextSpan(style: style, text: text),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant _PerformanceMetricsPainter oldDelegate) =>
      fps != oldDelegate.fps ||
      frameTime != oldDelegate.frameTime ||
      jankScore != oldDelegate.jankScore ||
      isWebGLAvailable != oldDelegate.isWebGLAvailable;
} 