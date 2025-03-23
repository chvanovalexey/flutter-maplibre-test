import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'map_styles.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

@immutable
class NewMapPage extends StatefulWidget {
  const NewMapPage({super.key});

  @override
  State<NewMapPage> createState() => _NewMapPageState();
}

class _NewMapPageState extends State<NewMapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая карта'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: MapLibreMap(
        options: MapOptions(
          initCenter: Position(37.62, 55.75), // Координаты Москвы (lng, lat)
          initZoom: 10,
          initStyle: MapStyles.protomapsLight, // Используем другой стиль карты
        ),
        children: const [
          MapScalebar(),
          SourceAttribution(),
          MapControlButtons(showTrackLocation: true),
          MapCompass(),
        ],
        onStyleLoaded: kIsWeb 
            ? (style) {
                style.setProjection(MapProjection.globe);
              }
            : null,
      ),
    );
  }
} 