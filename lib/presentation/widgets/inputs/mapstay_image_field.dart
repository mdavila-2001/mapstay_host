import 'dart:io';
import 'package:flutter/material.dart';

/// Estructura interna para asociar un File físico/mockeado con un preview visual estético (Unsplash).
class MapStayImageItem {
  MapStayImageItem({
    required this.file,
    required this.previewUrl,
  });

  final File file;
  final String previewUrl;
}

/// Campo de selección multimedia para MapStay Anfitriones.
/// Muestra una cuadrícula de imágenes seleccionadas con soporte para eliminar y agregar.
/// Utiliza una simulación visual premium de selección de galería y ofrece ganchos claros
/// para ser reemplazados por el plugin image_picker en producción.
class MapStayImageField extends StatefulWidget {
  const MapStayImageField({
    super.key,
    required this.labelText,
    required this.onImagesChanged,
    this.initialImages = const [],
    this.maxImages = 6,
  });

  /// Etiqueta superior del campo.
  final String labelText;

  /// Callback que expone la lista de archivos seleccionados en limpio.
  final ValueChanged<List<File>> onImagesChanged;

  /// Lista de imágenes iniciales (opcional).
  final List<File> initialImages;

  /// Límite máximo de imágenes permitidas.
  final int maxImages;

  @override
  State<MapStayImageField> createState() => _MapStayImageFieldState();
}

class _MapStayImageFieldState extends State<MapStayImageField> {
  final List<MapStayImageItem> _selectedImages = [];

  // Banco de imágenes de alta calidad de Unsplash para la simulación interactiva.
  final List<Map<String, String>> _mockGalleryOptions = [
    {
      'url': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=500&auto=format&fit=crop&q=80',
      'name': 'living_room_modern.jpg',
    },
    {
      'url': 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=500&auto=format&fit=crop&q=80',
      'name': 'bedroom_cozy.jpg',
    },
    {
      'url': 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=500&auto=format&fit=crop&q=80',
      'name': 'kitchen_premium.jpg',
    },
    {
      'url': 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500&auto=format&fit=crop&q=80',
      'name': 'bathroom_clean.jpg',
    },
    {
      'url': 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=500&auto=format&fit=crop&q=80',
      'name': 'balcony_view.jpg',
    },
    {
      'url': 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=500&auto=format&fit=crop&q=80',
      'name': 'dining_area.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar a partir de archivos existentes (si se proveen)
    for (var file in widget.initialImages) {
      _selectedImages.add(
        MapStayImageItem(
          file: file,
          // Fallback a una imagen de preview genérica si no es mockeado
          previewUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=500',
        ),
      );
    }
  }

  void _notifyChanges() {
    final files = _selectedImages.map((item) => item.file).toList();
    widget.onImagesChanged(files);
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    _notifyChanges();
  }

  /// Abre la interfaz de simulación de selección multimedia.
  /// 
  /// NOTA DE PRODUCCIÓN: Para integrar image_picker real, reemplaza el contenido de este método por:
  /// ```dart
  /// final ImagePicker picker = ImagePicker();
  /// final List<XFile> images = await picker.pickMultiImage();
  /// if (images.isNotEmpty) {
  ///   setState(() {
  ///     for (var image in images) {
  ///       if (_selectedImages.length < widget.maxImages) {
  ///         _selectedImages.add(MapStayImageItem(
  ///           file: File(image.path),
  ///           previewUrl: image.path, // O muestra la foto local con Image.file()
  ///         ));
  ///       }
  ///     }
  ///   });
  ///   _notifyChanges();
  /// }
  /// ```
  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Estado local del BottomSheet para permitir selección múltiple
        List<int> selectedIndices = [];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Simulador de Selección de Fotos',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seleccione una o más imágenes de nuestra galería de prueba para simular la cámara o la galería de fotos.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mockGalleryOptions.length,
                      itemBuilder: (context, index) {
                        final option = _mockGalleryOptions[index];
                        final isSelected = selectedIndices.contains(index);

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                selectedIndices.remove(index);
                              } else {
                                selectedIndices.add(index);
                              }
                            });
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    option['url']!,
                                    fit: BoxFit.cover,
                                  ),
                                  if (isSelected)
                                    Container(
                                      color: Colors.black45,
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: Theme.of(context).colorScheme.secondary,
                                        size: 28,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Simula la toma de foto con cámara
                            if (_selectedImages.length >= widget.maxImages) {
                              Navigator.pop(context);
                              _showMaxImagesWarning();
                              return;
                            }
                            final cameraOption = _mockGalleryOptions[
                                _selectedImages.length % _mockGalleryOptions.length];
                            
                            setState(() {
                              _selectedImages.add(
                                MapStayImageItem(
                                  file: File('/simulated/camera/${cameraOption['name']}'),
                                  previewUrl: cameraOption['url']!,
                                ),
                              );
                            });
                            _notifyChanges();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Simular Cámara'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).colorScheme.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: selectedIndices.isEmpty
                              ? null
                              : () {
                                  // Simula la selección de galería
                                  setState(() {
                                    for (var idx in selectedIndices) {
                                      if (_selectedImages.length >= widget.maxImages) {
                                        break;
                                      }
                                      final option = _mockGalleryOptions[idx];
                                      _selectedImages.add(
                                        MapStayImageItem(
                                          file: File('/simulated/gallery/${option['name']}'),
                                          previewUrl: option['url']!,
                                        ),
                                      );
                                    }
                                  });
                                  _notifyChanges();
                                  Navigator.pop(context);
                                },
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text('Agregar (${selectedIndices.length})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showMaxImagesWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Límite de imágenes alcanzado (${widget.maxImages})'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedImages.isEmpty)
          // Estado Vacío: Caja interactiva grande con borde punteado
          GestureDetector(
            onTap: _showImageSourceSelector,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  style: BorderStyle.solid, // Dash style can be simulated or solid
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: theme.colorScheme.secondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Añadir fotos del alojamiento',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Formatos aceptados: JPG, PNG (Máx. ${widget.maxImages} fotos)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Estado con imágenes: Grid de miniaturas + botón de agregar más
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: _selectedImages.length < widget.maxImages
                ? _selectedImages.length + 1
                : _selectedImages.length,
            itemBuilder: (context, index) {
              // Si es el último elemento y no hemos alcanzado el límite, mostrar caja para añadir más
              if (index == _selectedImages.length) {
                return GestureDetector(
                  onTap: _showImageSourceSelector,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: theme.colorScheme.secondary,
                      size: 24,
                    ),
                  ),
                );
              }

              final item = _selectedImages[index];

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen de vista previa con esquinas redondeadas
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.previewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: theme.colorScheme.error,
                          ),
                        );
                      },
                    ),
                  ),
                  // Overlay gradiente para el botón de eliminar
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
