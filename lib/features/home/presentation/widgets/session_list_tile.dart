import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/platform/image_storage.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../photos/domain/models/photo.dart';

class SessionListTile extends StatelessWidget {
  final Photo photo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SessionListTile({
    required this.photo,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
        ),
      ),
      title: Text(
        photo.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        DateFormat('dd.MM.yyyy  HH:mm').format(photo.createdAt),
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA500),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${photo.totalCount}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.grey,
            tooltip: l10n.delete,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
