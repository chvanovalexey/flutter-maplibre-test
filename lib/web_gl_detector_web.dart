import 'dart:html' as html;

/// Web implementation to check for WebGL availability
bool isWebGLAvailable() {
  try {
    final canvas = html.CanvasElement();
    final gl = canvas.getContext('webgl') ?? canvas.getContext('experimental-webgl');
    return gl != null;
  } catch (e) {
    return false;
  }
} 