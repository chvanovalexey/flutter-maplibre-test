import 'package:flutter/material.dart';
import '../config/map_styles.dart';

class MapStyleDropdown extends StatelessWidget {
  final String currentStyle;
  final Function(String) onStyleChanged;
  
  const MapStyleDropdown({
    Key? key,
    required this.currentStyle,
    required this.onStyleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, String> styles = MapStyles.getAllStyles();
    
    // Get the current style display name
    final currentStyleName = styles[currentStyle] ?? 'Select Style';
    
    return PopupMenuButton<String>(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentStyleName),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (context) {
        return styles.entries.map((entry) {
          return PopupMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList();
      },
      onSelected: onStyleChanged,
    );
  }
} 