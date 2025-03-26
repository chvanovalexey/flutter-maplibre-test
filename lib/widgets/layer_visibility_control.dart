import 'package:flutter/material.dart';
import '../services/container_route_layer_manager.dart';

class LayerVisibilityControl extends StatefulWidget {
  final Function(String, bool) onLayerVisibilityChanged;
  
  const LayerVisibilityControl({
    Key? key,
    required this.onLayerVisibilityChanged,
  }) : super(key: key);

  @override
  State<LayerVisibilityControl> createState() => _LayerVisibilityControlState();
}

class _LayerVisibilityControlState extends State<LayerVisibilityControl> {
  // Maintain a map of layer IDs and their visibility state
  final Map<String, bool> _layerVisibility = {
    ContainerRouteLayerManager.departurePortsLayerId: true,
    ContainerRouteLayerManager.destinationPortsLayerId: true,
    ContainerRouteLayerManager.intermediatePortsLayerId: true,
    ContainerRouteLayerManager.currentPositionLayerId: true,
    ContainerRouteLayerManager.pastRouteLayerId: true,
    ContainerRouteLayerManager.futureRouteLayerId: true,
  };

  // Layer display names for better UI
  final Map<String, String> _layerNames = {
    ContainerRouteLayerManager.departurePortsLayerId: 'Departure Ports',
    ContainerRouteLayerManager.destinationPortsLayerId: 'Destination Ports',
    ContainerRouteLayerManager.intermediatePortsLayerId: 'Intermediate Ports',
    ContainerRouteLayerManager.currentPositionLayerId: 'Current Position',
    ContainerRouteLayerManager.pastRouteLayerId: 'Past Routes',
    ContainerRouteLayerManager.futureRouteLayerId: 'Future Routes',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.layers),
      tooltip: 'Layer Visibility',
      itemBuilder: (context) => _layerNames.entries.map((entry) {
        final layerId = entry.key;
        final layerName = entry.value;
        final isVisible = _layerVisibility[layerId] ?? true;
        
        return PopupMenuItem<String>(
          value: layerId,
          child: Row(
            children: [
              Checkbox(
                value: isVisible,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _layerVisibility[layerId] = value;
                    });
                    widget.onLayerVisibilityChanged(layerId, value);
                    Navigator.pop(context); // Close the menu after selection
                  }
                },
              ),
              Text(layerName),
            ],
          ),
        );
      }).toList(),
    );
  }
} 