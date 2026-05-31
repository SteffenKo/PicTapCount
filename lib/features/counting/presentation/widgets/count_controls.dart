import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

class CountControls extends StatelessWidget {
  final bool canUndo;
  final bool canReset;
  final VoidCallback onUndo;
  final VoidCallback onReset;

  const CountControls({
    required this.canUndo,
    required this.canReset,
    required this.onUndo,
    required this.onReset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.white.withValues(alpha: 0.92),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
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
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
