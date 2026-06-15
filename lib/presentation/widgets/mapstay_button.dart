import 'package:flutter/material.dart';

enum MapStayButtonVariant { primary, secondary, outline, text }

enum MapStayButtonRoundness {
  sm,
  md,
  lg,
  full;

  BorderRadius get borderRadius => switch (this) {
    MapStayButtonRoundness.sm   => BorderRadius.circular(4),
    MapStayButtonRoundness.md   => BorderRadius.circular(12),
    MapStayButtonRoundness.lg   => BorderRadius.circular(16),
    MapStayButtonRoundness.full => BorderRadius.circular(9999),
  };
}

class MapStayButton extends StatelessWidget {
  const MapStayButton({
    super.key,
    this.text,
    this.onPressed,
    this.variant = MapStayButtonVariant.primary,
    this.roundness = MapStayButtonRoundness.md,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  final String? text;

  final VoidCallback? onPressed;

  final MapStayButtonVariant variant;

  final MapStayButtonRoundness roundness;

  final bool isLoading;
  final Widget? icon;

  final bool expand;

  Color _resolveBackgroundColor(ColorScheme cs) => switch (variant) {
    MapStayButtonVariant.primary   => cs.secondary,
    MapStayButtonVariant.secondary => cs.primaryContainer,
    MapStayButtonVariant.outline   => Colors.transparent,
    MapStayButtonVariant.text      => Colors.transparent,
  };

  Color _resolveForegroundColor(ColorScheme cs) => switch (variant) {
    MapStayButtonVariant.primary   => cs.onSecondary,
    MapStayButtonVariant.secondary => cs.primary,
    MapStayButtonVariant.outline   => cs.onSurface,
    MapStayButtonVariant.text      => cs.secondary,
  };

  BoxBorder? _resolveBorder(ColorScheme cs) => switch (variant) {
    MapStayButtonVariant.outline => Border.all(color: cs.outline, width: 1),
    _                           => null,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelMedium;
    final bool isDisabled = onPressed == null;

    final backgroundColor = _resolveBackgroundColor(colorScheme);
    final foregroundColor = _resolveForegroundColor(colorScheme);
    final border = _resolveBorder(colorScheme);
    final borderRadius = roundness.borderRadius;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: SizedBox(
        width: expand ? double.infinity : null,
        height: 48,
        child: Material(
          color: backgroundColor,
          borderRadius: borderRadius,
          child: InkWell(
            onTap: (isDisabled || isLoading) ? null : onPressed,
            borderRadius: borderRadius,
            splashColor: foregroundColor.withValues(alpha: 0.12),
            highlightColor: foregroundColor.withValues(alpha: 0.08),
            child: Container(
              decoration: BoxDecoration(
                border: border,
                borderRadius: borderRadius,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              child: _buildContent(foregroundColor, textStyle),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color foregroundColor, TextStyle? textStyle) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    }

    final List<Widget> children = [];

    if (icon != null) {
      children.add(
        IconTheme(
          data: IconThemeData(color: foregroundColor, size: 20),
          child: icon!,
        ),
      );
    }

    if (text != null) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: 8));
      }
      children.add(
        Text(
          text!,
          style: textStyle?.copyWith(color: foregroundColor),
        ),
      );
    }

    if (children.length == 1) return children.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}