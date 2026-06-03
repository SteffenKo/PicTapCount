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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(l10n.appTitle),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
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
          ),
          const SliverToBoxAdapter(child: Divider(height: 1)),
          _buildPhotoSliver(context, ref, l10n, cs, photosAsync),
        ],
      ),
    );
  }

  Widget _buildPhotoSliver(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ColorScheme cs,
    AsyncValue<List<Photo>> photosAsync,
  ) {
    return photosAsync.when(
      data: (photos) => photos.isEmpty
          ? const SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
          : SliverList.separated(
              itemCount: photos.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final photo = photos[i];
                return Dismissible(
                  key: Key(photo.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _confirmDelete(context, ref, photo),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: cs.errorContainer,
                    child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
                  ),
                  child: SessionListTile(
                    photo: photo,
                    onTap: () => context.push('/count/${photo.id}'),
                    onRename: () => _confirmRename(context, ref, photo),
                  ),
                );
              },
            ),
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Error: $e')),
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
          color: 0xFFEB7E1C,
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

  Future<void> _confirmRename(
    BuildContext context,
    WidgetRef ref,
    Photo photo,
  ) async {
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => _RenameDialog(initialTitle: photo.title),
    );
    if (!context.mounted) return;
    final trimmed = newTitle?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      await ref.read(photoRepositoryProvider).save(photo.copyWith(title: trimmed));
      ref.invalidate(photoListProvider);
    }
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Photo photo,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
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
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(photoRepositoryProvider).delete(photo.id);
      ref.invalidate(photoListProvider);
    }
    return confirmed;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined, size: 64, color: cs.outlineVariant),
          const SizedBox(height: 16),
          Text(
            l10n.noSessions,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  final String initialTitle;

  const _RenameDialog({required this.initialTitle});

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.renameTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.photoName),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.rename),
        ),
      ],
    );
  }
}
