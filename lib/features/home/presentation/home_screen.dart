import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/platform/image_storage.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../photos/domain/models/count_layer.dart';
import '../../photos/domain/models/photo.dart';
import '../../photos/providers/photo_list_provider.dart';
import '../../photos/providers/repository_providers.dart';
import 'widgets/session_list_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photoListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startSession(context, ref, ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(l10n.openCamera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _startSession(context, ref, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.importGallery),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: photosAsync.when(
              data: (photos) => photos.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      itemCount: photos.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final photo = photos[i];
                        return SessionListTile(
                          photo: photo,
                          onTap: () => context.push('/count/${photo.id}'),
                          onDelete: () => _confirmDelete(context, ref, photo),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startSession(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 100);
    if (picked == null || !context.mounted) return;

    final photoId = const Uuid().v4();
    final imagePath = await saveImage(picked, photoId);

    final now = DateTime.now();
    final photo = Photo(
      id: photoId,
      title: DateFormat('yyyy-MM-dd HH:mm').format(now),
      imagePath: imagePath,
      createdAt: now,
      countLayers: [
        CountLayer(
          id: const Uuid().v4(),
          name: 'Default',
          color: 0xFFFFA500,
          points: const [],
        ),
      ],
    );

    await ref.read(photoRepositoryProvider).save(photo);
    ref.invalidate(photoListProvider);

    if (context.mounted) {
      context.push('/count/${photo.id}');
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Photo photo,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(photoRepositoryProvider).delete(photo.id);
      ref.invalidate(photoListProvider);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            l10n.noSessions,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
