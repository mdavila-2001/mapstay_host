import 'package:flutter/material.dart';


enum MapStayTableAlign { left, center, right }



class MapStayColumnConfig<T> {
  MapStayColumnConfig({
    required this.title,
    required this.key,
    this.flex = 1,
    this.width,
    this.align = MapStayTableAlign.left,
    this.render,
  });


  final String title;


  final String key;


  final int flex;


  final double? width;


  final MapStayTableAlign align;



  final Widget Function(T item)? render;
}



class MapStayTable<T> extends StatelessWidget {
  const MapStayTable({
    super.key,
    required this.data,
    required this.columns,
    this.useZebraStriping = true,
    this.horizontalScroll = false,
    this.onRowTap,
  });


  final List<T> data;


  final List<MapStayColumnConfig<T>> columns;


  final bool useZebraStriping;



  final bool horizontalScroll;


  final ValueChanged<T>? onRowTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);


    final tableWidget = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155),
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


  List<Widget> _buildTableChildren(BuildContext context) {
    final List<Widget> children = [];


    children.add(_buildHeader(context));

    if (data.isEmpty) {

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

      for (int i = 0; i < data.length; i++) {
        children.add(
          const Divider(height: 1, thickness: 1, color: Color(0xFF334155)),
        );
        children.add(_buildRow(context, data[i], i));
      }
    }

    return children;
  }


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
      color: theme.colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: headerCells,
      ),
    );
  }


  Widget _buildRow(BuildContext context, T item, int index) {

    final isOdd = index % 2 != 0;
    final rowColor = useZebraStriping && isOdd
        ? const Color(0xFF131B2E)
        : const Color(0xFF0B1326);

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
