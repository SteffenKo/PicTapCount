import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

class CountControls extends StatelessWidget {
  final bool canUndo;
  final bool canReset;
  final double dotSize;
  final ValueChanged<double> onDotSizeChanged;
  final VoidCallback onUndo;
  final VoidCallback onReset;

  const CountControls({
    required this.canUndo,
    required this.canReset,
    required this.dotSize,
    required this.onDotSizeChanged,
    required this.onUndo,
    required this.onReset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        border: Border(top: BorderSide(color: cs.outlineVariant, width: 0.5)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.circle_outlined, size: 14, color: cs.primary),
              Expanded(
                child: Slider(
                  value: dotSize,
                  min: 1.0,
                  max: 15.0,
                  onChanged: onDotSizeChanged,
                ),
              ),
              Icon(Icons.circle_outlined, size: 26, color: cs.primary),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canUndo ? onUndo : null,
                  icon: const Icon(Icons.undo),
                  label: Text(l10n.undo),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canReset ? onReset : null,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.reset),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: canReset ? cs.error : cs.outline),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
