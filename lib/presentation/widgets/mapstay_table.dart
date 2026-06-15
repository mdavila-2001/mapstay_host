import 'package:flutter/material.dart';

/// Alineación horizontal del contenido de una celda en MapStayTable.
enum MapStayTableAlign { left, center, right }

/// Configuración de una columna para MapStayTable.
/// Permite definir título, flex, ancho, alineación y renderizado personalizado.
class MapStayColumnConfig<T> {
  MapStayColumnConfig({
    required this.title,
    required this.key,
    this.flex = 1,
    this.width,
    this.align = MapStayTableAlign.left,
    this.render,
  });

  /// Título visible en el encabezado de la columna.
  final String title;

  /// Clave única identificadora de la columna.
  final String key;

  /// Peso proporcional para distribución de ancho (activo si horizontalScroll es false).
  final int flex;

  /// Ancho fijo físico para la columna (activo si horizontalScroll es true).
  final double? width;

  /// Alineación del texto/contenido en la cabecera y celdas.
  final MapStayTableAlign align;

  /// Constructor opcional para renderizar un widget complejo y personalizado (celda polimórfica).
  /// Si es nulo, la tabla renderiza por defecto el método toString() del objeto.
  final Widget Function(T item)? render;
}

/// Tabla genérica, responsiva y altamente reutilizable para MapStay Anfitriones.
/// Cumple con los principios SOLID y permite representar cualquier conjunto de datos.
class MapStayTable<T> extends StatelessWidget {
  const MapStayTable({
    super.key,
    required this.data,
    required this.columns,
    this.useZebraStriping = true,
    this.horizontalScroll = false,
    this.onRowTap,
  });

  /// Lista de objetos genéricos que representan las filas de datos.
  final List<T> data;

  /// Configuración de las columnas que se desean mostrar en la tabla.
  final List<MapStayColumnConfig<T>> columns;

  /// Si es true, alterna el fondo de las filas impares para facilitar la lectura.
  final bool useZebraStriping;

  /// Si es true, la tabla habilitará el scroll horizontal y columnas con anchos fijos.
  /// Si es false, distribuirá las columnas proporcionalmente en el espacio disponible.
  final bool horizontalScroll;

  /// Callback opcional que se activa al hacer tap en cualquier fila de datos.
  final ValueChanged<T>? onRowTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Contenedor principal con bordes redondeados y recorte antiAlias
    final tableWidget = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155), // Borde fino de slate oscuro
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildTableChildren(context),
      ),
    );

    // Responsividad horizontal
    if (horizontalScroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: tableWidget,
        ),
      );
    }

    return tableWidget;
  }

  /// Construye los elementos internos de la tabla (Cabecera, divisores y filas).
  List<Widget> _buildTableChildren(BuildContext context) {
    final List<Widget> children = [];

    // Cabecera
    children.add(_buildHeader(context));

    if (data.isEmpty) {
      // Estado vacío
      children.add(
        const Divider(height: 1, thickness: 1, color: Color(0xFF334155)),
      );
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Center(
            child: Text(
              'No se encontraron registros',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    } else {
      // Filas de datos
      for (int i = 0; i < data.length; i++) {
        children.add(
          const Divider(height: 1, thickness: 1, color: Color(0xFF334155)),
        );
        children.add(_buildRow(context, data[i], i));
      }
    }

    return children;
  }

  /// Renderiza la fila de encabezado.
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> headerCells = columns.map((col) {
      final headerText = Text(
        col.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: theme.colorScheme.onSurface,
        ),
      );

      return _buildCell(context, headerText, col);
    }).toList();

    return Container(
      color: theme.colorScheme.surfaceContainerHigh, // Fondo elevado #222A3D
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: headerCells,
      ),
    );
  }

  /// Renderiza una fila de datos individual.
  Widget _buildRow(BuildContext context, T item, int index) {
    // Cebrado alterno de colores
    final isOdd = index % 2 != 0;
    final rowColor = useZebraStriping && isOdd
        ? const Color(0xFF131B2E) // Alterno
        : const Color(0xFF0B1326); // Base

    final List<Widget> cells = columns.map((col) {
      Widget cellContent;
      if (col.render != null) {
        cellContent = col.render!(item);
      } else {
        cellContent = Text(
          item.toString(),
          style: const TextStyle(
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }

      return _buildCell(context, cellContent, col);
    }).toList();

    final rowWidget = Container(
      color: rowColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: cells,
      ),
    );

    if (onRowTap != null) {
      return InkWell(
        onTap: () => onRowTap!(item),
        child: rowWidget,
      );
    }

    return rowWidget;
  }

  /// Envoltura utilitaria para cada celda según la distribución y la alineación.
  Widget _buildCell(BuildContext context, Widget child, MapStayColumnConfig<T> col) {
    final alignment = switch (col.align) {
      MapStayTableAlign.left => Alignment.centerLeft,
      MapStayTableAlign.center => Alignment.center,
      MapStayTableAlign.right => Alignment.centerRight,
    };

    final cellContent = Align(
      alignment: alignment,
      child: child,
    );

    if (horizontalScroll) {
      return SizedBox(
        width: col.width ?? 120.0,
        child: cellContent,
      );
    } else {
      return Expanded(
        flex: col.flex,
        child: cellContent,
      );
    }
  }
}
