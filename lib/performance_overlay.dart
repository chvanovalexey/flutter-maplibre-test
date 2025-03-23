import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Display performance metrics on the map
/// 
/// Shows FPS, Frame time, and Jank score
@immutable
class MapPerformanceOverlay extends StatefulWidget {
  /// Creates a performance overlay widget
  const MapPerformanceOverlay({
    this.alignment = Alignment.centerRight,
    this.padding = const EdgeInsets.all(12),
    super.key,
  });

  /// The [Alignment] of the performance overlay.
  final Alignment alignment;

  /// The [padding] of the performance overlay.
  final EdgeInsets padding;

  @override
  State<MapPerformanceOverlay> createState() => _MapPerformanceOverlayState();
}

class _MapPerformanceOverlayState extends State<MapPerformanceOverlay> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _fps = 0;
  double _frameTime = 0;
  int _jankScore = 0;

  // Для подсчета FPS и измерения времени кадра
  int _frameCount = 0;
  Duration _lastTime = Duration.zero;
  List<Duration> _frameTimes = [];
  
  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
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
      
      // Обновляем значения каждые 10 кадров
      if (_frameCount % 10 == 0) {
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
    final theme = Theme.of(context);
    
    return Container(
      alignment: widget.alignment,
      padding: widget.padding,
      child: CustomPaint(
        painter: _PerformanceMetricsPainter(
          fps: _fps, 
          frameTime: _frameTime, 
          jankScore: _jankScore,
          theme: theme,
        ),
        size: const Size(130, 70),
      ),
    );
  }
}

class _PerformanceMetricsPainter extends CustomPainter {
  _PerformanceMetricsPainter({
    required this.fps,
    required this.frameTime,
    required this.jankScore,
    required this.theme,
  });

  final double fps;
  final double frameTime;
  final int jankScore;
  final ThemeData theme;

  late final _backgroundPaint = Paint()..color = Colors.white60;
  late final _borderPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

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
      jankScore != oldDelegate.jankScore;
} 