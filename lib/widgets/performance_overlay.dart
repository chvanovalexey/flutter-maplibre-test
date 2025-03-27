import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/app_constants.dart';

// Conditionally import dart:html only for web
import 'dart:html' as html if (dart.library.html) '';

/// Web implementation to check for WebGL availability
bool isWebGLAvailable() {
  if (kIsWeb) {
    try {
      final canvas = html.CanvasElement();
      final gl = canvas.getContext('webgl') ?? canvas.getContext('experimental-webgl');
      return gl != null;
    } catch (e) {
      return false;
    }
  } else {
    // Stub implementation for non-web platforms
    // Always returns false since WebGL is a web-only feature
    return false;
  }
}

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
    // Рассчет FPS и времени кадра
    if (_lastTime != Duration.zero) {
      final frameDuration = elapsed - _lastTime;
      _frameTimes.add(frameDuration);
      
      // Сохраняем только последние N кадров для расчетов
      if (_frameTimes.length > AppConstants.performanceSampleCount) {
        _frameTimes.removeAt(0);
      }
      
      // Обновляем значения не чаще, чем через определенный интервал
      if (_lastUpdateTime == Duration.zero || 
          elapsed - _lastUpdateTime > Duration(milliseconds: AppConstants.performanceUpdateIntervalMs)) {
        _lastUpdateTime = elapsed;
        
        // Рассчитываем средний FPS
        final avgDuration = _frameTimes.fold<Duration>(
            Duration.zero, (sum, duration) => sum + duration) ~/ _frameTimes.length;
        
        // FPS = 1 секунда / среднее время кадра
        final newFps = 1000 / avgDuration.inMilliseconds.toDouble();
        // Среднее время кадра в миллисекундах
        final newFrameTime = avgDuration.inMicroseconds / 1000;
        
        // Простой алгоритм подсчета Jank score
        // Считаем кадры, которые превышают средний показатель на определенный множитель
        int jankFrames = 0;
        final threshold = avgDuration.inMicroseconds * AppConstants.jankThresholdMultiplier;
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
        size: const Size(130, 100),
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

  late final _backgroundPaint = Paint()..color = Colors.white.withOpacity(0.85);

  @override
  void paint(Canvas canvas, Size size) {
    // Рисуем фоновый прямоугольник
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, _backgroundPaint);

    // Создаем стиль текста
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
    
    // Рисуем текст FPS
    final String fpsText = 'FPS: ${fps.toStringAsFixed(1)}';
    _drawText(canvas, fpsText, textStyle, 5, 15);
    
    // Рисуем текст Frame Time
    final String frameTimeText = 'Frame: ${frameTime.toStringAsFixed(1)} ms';
    _drawText(canvas, frameTimeText, textStyle, 5, 35);
    
    // Рисуем текст Jank Score
    final String jankScoreText = 'Jank: $jankScore%';
    
    // Определяем цвет в зависимости от значения Jank Score
    final Color jankColor = jankScore > 50 ? Colors.red : 
                           jankScore > 20 ? Colors.orange : 
                           Colors.green;
    
    _drawText(canvas, jankScoreText, textStyle?.copyWith(color: jankColor), 5, 55);
    
    // Рисуем информацию о WebGL
    final String webGLText = 'WebGL: ${isWebGLAvailable ? 'Available' : 'N/A'}';
    _drawText(
      canvas, 
      webGLText, 
      textStyle?.copyWith(
        color: isWebGLAvailable ? Colors.green : Colors.grey
      ), 
      5, 
      75
    );
  }
  
  // Вспомогательный метод для рисования текста
  void _drawText(Canvas canvas, String text, TextStyle? style, double x, double y) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(_PerformanceMetricsPainter oldDelegate) {
    return fps != oldDelegate.fps || 
           frameTime != oldDelegate.frameTime || 
           jankScore != oldDelegate.jankScore ||
           isWebGLAvailable != oldDelegate.isWebGLAvailable;
  }
} 