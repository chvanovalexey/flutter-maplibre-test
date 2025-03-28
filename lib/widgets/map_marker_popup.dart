import 'package:flutter/material.dart';

/// A widget that displays information about a map marker in a popup
class MapMarkerPopup extends StatelessWidget {
  final String title;
  final String? description;
  final Map<String, dynamic>? properties;
  final VoidCallback? onClose;

  const MapMarkerPopup({
    super.key, 
    required this.title,
    this.description,
    this.properties,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с кнопкой закрытия
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (onClose != null)
                    InkWell(
                      onTap: onClose,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.close, size: 20, color: Colors.black54),
                      ),
                    ),
                ],
              ),
            ),
            // Содержимое
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description != null && description!.isNotEmpty)
                    Text(
                      description!,
                      style: const TextStyle(fontSize: 14),
                    )
                  else
                    const Text(
                      'Нет дополнительной информации',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Добавляем дополнительную информацию о маркере из свойств
                  if (properties != null && properties!.isNotEmpty)
                    _buildPropertiesList(properties!),
                  // Добавляем кнопку "Подробнее" если есть дополнительные свойства
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Показываем диалог с полной информацией о маркере
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(title),
                            content: SingleChildScrollView(
                              child: _buildFullPropertiesList(properties),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Закрыть'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Подробнее'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Создает компактный список свойств маркера
  Widget _buildPropertiesList(Map<String, dynamic> props) {
    // Отображаем только самые важные свойства
    final importantKeys = ['pointType', 'marker-symbol', 'title'];
    final visibleProps = props.entries
        .where((entry) => !importantKeys.contains(entry.key) && entry.value != null)
        .take(2) // Берем только два дополнительных свойства для компактности
        .toList();
        
    if (visibleProps.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: visibleProps.map((entry) {
        // Форматируем ключ для отображения
        final key = entry.key.replaceAll('-', ' ').replaceAll('_', ' ');
        final String formattedKey = key.substring(0, 1).toUpperCase() + key.substring(1);
        
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$formattedKey: ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  '${entry.value}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  /// Создает полный список всех свойств маркера для детального просмотра
  Widget _buildFullPropertiesList(Map<String, dynamic>? props) {
    if (props == null || props.isEmpty) {
      return const Text('Нет дополнительной информации');
    }
    
    // Исключаем некоторые технические свойства
    final excludedKeys = ['point', 'name', 'pointType'];
    
    final visibleProps = props.entries
        .where((entry) => !excludedKeys.contains(entry.key) && entry.value != null)
        .toList();
        
    if (visibleProps.isEmpty) return const Text('Нет дополнительной информации');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (description != null && description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              description!,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ...visibleProps.map((entry) {
          // Форматируем ключ для отображения
          final key = entry.key.replaceAll('-', ' ').replaceAll('_', ' ');
          final String formattedKey = key.substring(0, 1).toUpperCase() + key.substring(1);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '$formattedKey:',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${entry.value}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
} 