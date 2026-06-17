import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class MapStayImageItem {
  MapStayImageItem({
    required this.file,
    required this.previewUrl,
  });

  final File file;
  final String previewUrl;
}




class MapStayImageField extends StatefulWidget {
  const MapStayImageField({
    super.key,
    required this.labelText,
    required this.onImagesChanged,
    this.initialImages = const [],
    this.maxImages = 6,
  });


  final String labelText;


  final ValueChanged<List<File>> onImagesChanged;


  final List<File> initialImages;


  final int maxImages;

  @override
  State<MapStayImageField> createState() => _MapStayImageFieldState();
}

class _MapStayImageFieldState extends State<MapStayImageField> {
  final List<MapStayImageItem> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  static final _ipPattern = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');

  static bool _isRemoteUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://') || _ipPattern.hasMatch(path);
  }

  static String _ensureProtocol(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (_ipPattern.hasMatch(url)) return 'http://$url';
    return url;
  }

  @override
  void initState() {
    super.initState();

    for (var file in widget.initialImages) {
      _selectedImages.add(
        MapStayImageItem(
          file: file,
          previewUrl: file.path,
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


  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            if (_selectedImages.length < widget.maxImages) {
              _selectedImages.add(
                MapStayImageItem(
                  file: File(image.path),
                  previewUrl: image.path,
                ),
              );
            }
          }
        });
        _notifyChanges();
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
  }


  Future<void> _pickFromCamera() async {
    try {
      if (_selectedImages.length >= widget.maxImages) {
        _showMaxImagesWarning();
        return;
      }
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(
            MapStayImageItem(
              file: File(image.path),
              previewUrl: image.path,
            ),
          );
        });
        _notifyChanges();
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
  }

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Añadir fotos del alojamiento',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona una opción para capturar imágenes',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: const Text('Tomar Foto con Cámara'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: const Text('Seleccionar de Galería'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),
              ],
            ),
          ),
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
              final isRemote = _isRemoteUrl(item.previewUrl);

              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isRemote
                        ? Image.network(
                            _ensureProtocol(item.previewUrl),
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
                          )
                        : Image.file(
                            item.file,
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
