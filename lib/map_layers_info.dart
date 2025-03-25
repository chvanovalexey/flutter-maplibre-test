import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Display information about map layers from the current style
/// 
/// Shows the number of layers and their types from the selected map style
@immutable
class MapLayersInfo extends StatefulWidget {
  /// Creates a map layers info widget
  const MapLayersInfo({
    this.alignment = Alignment.centerRight,
    this.padding = const EdgeInsets.all(12),
    this.enabled = true,
    this.styleUrl = '',
    super.key,
  });

  /// The [Alignment] of the layers info overlay.
  final Alignment alignment;

  /// The [padding] of the layers info overlay.
  final EdgeInsets padding;
  
  /// Whether the layers info overlay is enabled.
  final bool enabled;
  
  /// The URL of the map style to analyze
  final String styleUrl;

  @override
  State<MapLayersInfo> createState() => _MapLayersInfoState();
}

class _MapLayersInfoState extends State<MapLayersInfo> {
  int _totalLayers = 0;
  Map<String, int> _layerTypes = {};
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.enabled && widget.styleUrl.isNotEmpty) {
      _fetchStyleData(widget.styleUrl);
    }
  }

  @override
  void didUpdateWidget(MapLayersInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update when enabled state or style URL changes
    if ((widget.enabled != oldWidget.enabled) || 
        (widget.styleUrl != oldWidget.styleUrl)) {
      if (widget.enabled && widget.styleUrl.isNotEmpty) {
        _fetchStyleData(widget.styleUrl);
      }
    }
  }

  /// Fetch and parse the map style JSON data
  Future<void> _fetchStyleData(String styleUrl) async {
    if (styleUrl.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    
    try {
      final response = await http.get(Uri.parse(styleUrl));
      
      if (response.statusCode == 200) {
        final styleData = jsonDecode(response.body);
        _analyzeStyleLayers(styleData);
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'HTTP ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().substring(0, min(e.toString().length, 50));
      });
    }
  }
  
  /// Analyze the layers in the style JSON
  void _analyzeStyleLayers(Map<String, dynamic> styleData) {
    if (styleData.containsKey('layers') && styleData['layers'] is List) {
      final layers = styleData['layers'] as List;
      
      // Calculate total layers
      final totalLayers = layers.length;
      
      // Count layer types
      final Map<String, int> layerTypes = {};
      
      for (var layer in layers) {
        if (layer is Map<String, dynamic> && layer.containsKey('type')) {
          final type = layer['type'] as String;
          layerTypes[type] = (layerTypes[type] ?? 0) + 1;
        }
      }
      
      setState(() {
        _totalLayers = totalLayers;
        _layerTypes = layerTypes;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'No layers found';
      });
    }
  }
  
  // Helper for string length
  int min(int a, int b) => a < b ? a : b;

  @override
  Widget build(BuildContext context) {
    // If overlay is disabled, return an empty widget
    if (!widget.enabled) {
      return const SizedBox.shrink();
    }
    
    final theme = Theme.of(context);
    
    // Calculate the height based on the number of layer types plus space for title and total
    final height = (_layerTypes.length * 20.0) + 40.0;
    
    return Container(
      alignment: widget.alignment,
      padding: widget.padding,
      child: CustomPaint(
        painter: _LayersInfoPainter(
          totalLayers: _totalLayers,
          layerTypes: _layerTypes,
          isLoading: _isLoading,
          hasError: _hasError,
          errorMessage: _errorMessage,
          theme: theme,
        ),
        size: Size(130, height),
      ),
    );
  }
}

class _LayersInfoPainter extends CustomPainter {
  _LayersInfoPainter({
    required this.totalLayers,
    required this.layerTypes,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.theme,
  });

  final int totalLayers;
  final Map<String, int> layerTypes;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final ThemeData theme;

  late final _backgroundPaint = Paint()..color = Colors.white60;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background rectangle
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, _backgroundPaint);

    // Create text style
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
    
    if (isLoading) {
      _drawText(canvas, 'Loading layers...', textStyle, 5, 15);
      return;
    }
    
    if (hasError) {
      _drawText(canvas, 'Error: $errorMessage', textStyle?.copyWith(color: Colors.red), 5, 15);
      return;
    }
    
    // Draw title
    _drawText(canvas, 'Map Layers', textStyle, 5, 15);
    
    // Draw total layers count
    _drawText(canvas, 'Total: $totalLayers', textStyle, 5, 35);
    
    // Draw layer types and counts
    int y = 55;
    layerTypes.forEach((type, count) {
      _drawText(canvas, '$type: $count', textStyle, 5, y.toDouble());
      y += 20;
    });
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
  bool shouldRepaint(covariant _LayersInfoPainter oldDelegate) =>
      totalLayers != oldDelegate.totalLayers ||
      layerTypes.toString() != oldDelegate.layerTypes.toString() ||
      isLoading != oldDelegate.isLoading ||
      hasError != oldDelegate.hasError;
} 