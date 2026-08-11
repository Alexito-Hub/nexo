import 'package:flutter/material.dart';
import 'package:nexo/core/design/breakpoints.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';

/// Piezas propias del directorio. Aquí solo vive lo que la app no tiene ya:
/// para notas se usa `grade_widgets.dart` (`GradeBadge`, `gradeColor`), para
/// etiquetas `StatusChip`, para avatares `StudentAvatar` y para agrupar
/// contenido `SectionCard`.

/// Rejilla responsiva de tarjetas: una columna en móvil, dos en escritorio.
/// Misma proporción que `gradeTileGrid` para que las pantallas del directorio
/// respiren igual que las de notas.
Widget directoryGrid(BuildContext context, List<Widget> cards) {
  if (cards.isEmpty) return const SizedBox.shrink();
  if (!context.isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          cards[i],
          if (i < cards.length - 1) const Gap(AppSpacing.md),
        ],
      ],
    );
  }
  const spacing = AppSpacing.md;
  return LayoutBuilder(
    builder: (ctx, c) {
      final w = (c.maxWidth - spacing) / 2;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [for (final card in cards) SizedBox(width: w, child: card)],
      );
    },
  );
}

/// Buscador del directorio.
class DirectorySearchField extends StatelessWidget {
  const DirectorySearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: AppIcon.lg,
          color: NexoTheme.textMuted,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                icon: Icon(
                  Icons.close_rounded,
                  size: AppIcon.md,
                  color: NexoTheme.textMuted,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
      ),
    );
  }
}

/// Cifra suelta con su etiqueta. Se usa en rejilla, así que no fija ancho.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: NexoTheme.bg,
        borderRadius: AppRadii.rXl,
        border: Border.all(color: NexoTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadii.rSm,
            ),
            child: Icon(icon, size: AppIcon.lg, color: color),
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.h3,
                    fontWeight: FontWeight.w900,
                    color: NexoTheme.textPrimary,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: AppFont.caption,
                    fontWeight: FontWeight.w600,
                    color: NexoTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila etiqueta/valor de la ficha. La etiqueta ocupa un ancho fijo para que
/// los valores queden alineados entre sí.
class RecordField extends StatelessWidget {
  const RecordField({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.responsive(mobile: 96.0, tablet: 120.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppFont.small,
                color: NexoTheme.textSecondary,
              ),
            ),
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppFont.small,
                fontWeight: FontWeight.w600,
                color: NexoTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra fina de progreso (asistencia, avance de una unidad).
class ThinBar extends StatelessWidget {
  const ThinBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 5,
  });

  /// Entre 0 y 1. Se recorta sola: los datos reales a veces se pasan.
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: color.withValues(alpha: 0.14),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// Aviso suave dentro de una tarjeta (sin datos, bloque vacío…).
class SoftNotice extends StatelessWidget {
  const SoftNotice({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });
  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadii.rSm,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppIcon.md, color: color),
            const Gap.h(AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppFont.small,
                height: 1.4,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
