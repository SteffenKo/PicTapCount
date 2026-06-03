import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/platform/image_storage.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../photos/domain/models/photo.dart';

class SessionListTile extends StatelessWidget {
  final Photo photo;
  final VoidCallback onTap;
  final VoidCallback onRename;

  const SessionListTile({
    required this.photo,
    required this.onTap,
    required this.onRename,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          image: imageProvider(photo),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: 60,
            height: 60,
            color: cs.surfaceContainerHighest,
            child: Icon(Icons.broken_image_outlined, color: cs.onSurfaceVariant),
          ),
        ),
      ),
      title: Text(
        photo.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        DateFormat('dd.MM.yyyy  HH:mm').format(photo.createdAt),
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${photo.totalCount}',
              style: tt.labelLarge?.copyWith(
                color: cs.onTertiaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: cs.onSurfaceVariant,
            tooltip: l10n.rename,
            onPressed: onRename,
          ),
        ],
      ),
    );
  }
}
