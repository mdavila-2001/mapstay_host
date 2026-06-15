import 'package:flutter/material.dart';

/// Componente utilitario y contenedor modular para MapStay Anfitriones.
/// Proporciona diálogos y paneles inferiores sincronizados estéticamente
/// con el Design System (Material 3) y preparados para áreas seguras y teclados físicos.
class MapStayModal {
  /// Muestra una hoja inferior (Bottom Sheet) modular.
  /// 
  /// Sincronizado estéticamente con el tono elevado de la aplicación (#222A3D)
  /// y configurado para desplazarse de forma nativa al interactuar con el teclado físico.
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    bool isDismissible = true,
  }) {
    final theme = Theme.of(context);
    
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true, // Crucial para permitir reajuste de teclado y scrolls internos
      backgroundColor: theme.colorScheme.surfaceContainerHigh, // Fondo elevado #222A3D
      barrierColor: Colors.black.withValues(alpha: 0.7), // Oscurecimiento posterior slate opaco
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            // Evita que el teclado virtual cubra las entradas de texto del modal
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tirador decorativo de arrastre superior
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Cabecera: Título y botón opcional de cerrar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isDismissible)
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                  // Divisor estructural fino
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFF334155),
                  ),
                  // Contenido principal del BottomSheet
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: content,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Muestra una alerta o ventana emergente (Dialog) centrada en la pantalla.
  /// 
  /// Sincronizado con el fondo base (#171F33) y esquinas redondeadas perimetrales de 12px.
  static Future<T?> showCustomDialog<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool isDismissible = true,
  }) {
    final theme = Theme.of(context);

    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return Dialog(
          backgroundColor: theme.colorScheme.surfaceContainer, // Fondo #171F33
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabecera del diálogo: Título y botón opcional de cerrar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isDismissible)
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                  // Divisor estructural fino
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFF334155),
                  ),
                  // Contenido principal del diálogo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: DefaultTextStyle(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ) ?? const TextStyle(fontSize: 14),
                        child: content,
                      ),
                    ),
                  ),
                  // Acciones inferiores (si se suministran)
                  if (actions != null && actions.isNotEmpty) ...[
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFF334155),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions.map((action) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: action,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
