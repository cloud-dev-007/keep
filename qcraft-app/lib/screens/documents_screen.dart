import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../api/models.dart';
import '../main.dart';
import '../widgets/ui_bits.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late Future<List<DocumentModel>> _future;
  bool _uploading = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _future = apiClient.getDocuments();
  }

  void _reload() {
    setState(() {
      _future = apiClient.getDocuments();
    });
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx', 'doc', 'pptx', 'txt'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) {
      if (mounted) showSnack(context, 'Could not access file', error: true);
      return;
    }
    setState(() {
      _uploading = true;
      _uploadProgress = 0;
    });
    try {
      await apiClient.uploadDocument(
        File(path),
        onProgress: (sent, total) {
          if (!mounted || total <= 0) return;
          setState(() => _uploadProgress = sent / total);
        },
      );
      if (!mounted) return;
      showSnack(context, 'Upload complete — embedding in background');
      _reload();
    } on ApiException catch (e) {
      if (mounted) {
        showSnack(
          context,
          e.message,
          error: true,
          actionLabel: 'Retry',
          onAction: _pickAndUpload,
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _confirmDelete(DocumentModel doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text('${doc.displayName} will be removed along with its embeddings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await apiClient.deleteDocument(doc.id);
      if (!mounted) return;
      showSnack(context, 'Deleted');
      _reload();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
          const LogoutButton(),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: FutureBuilder<List<DocumentModel>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LoadingView(label: 'Fetching documents…');
                }
                if (snap.hasError) {
                  final msg = snap.error is ApiException
                      ? (snap.error as ApiException).message
                      : 'Could not load documents';
                  return ErrorView(message: msg, onRetry: _reload);
                }
                final items = snap.data ?? const [];
                if (items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      EmptyView(
                        icon: Icons.upload_file,
                        title: 'No documents yet',
                        message: 'Upload a PDF, DOCX, PPTX, or TXT to get started.',
                        action: FilledButton.icon(
                          onPressed: _uploading ? null : _pickAndUpload,
                          icon: const Icon(Icons.add),
                          label: const Text('Upload'),
                        ),
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, i) => _DocCard(
                    doc: items[i],
                    onDelete: () => _confirmDelete(items[i]),
                  ),
                );
              },
            ),
          ),
          if (_uploading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Uploading… ${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: _uploadProgress > 0 ? _uploadProgress : null),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploading ? null : _pickAndUpload,
        icon: const Icon(Icons.add),
        label: const Text('Upload'),
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  const _DocCard({required this.doc, required this.onDelete});

  final DocumentModel doc;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final subtitleParts = <String>[
      doc.formatType.replaceAll('.', '').toUpperCase(),
      if (doc.pageCount != null) '${doc.pageCount} pages',
      if (doc.createdAt != null) DateFormat.yMMMd().format(doc.createdAt!),
    ];
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: t.colorScheme.secondaryContainer,
              child: Icon(
                _iconFor(doc.formatType),
                color: t.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.displayName,
                    style: t.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleParts.join(' • '),
                    style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.outline),
                  ),
                  if (doc.topics.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: -8,
                      children: doc.topics
                          .take(4)
                          .map((topic) => Chip(
                                label: Text(topic, style: t.textTheme.labelSmall),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(growable: false),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String formatType) {
    final ext = formatType.replaceAll('.', '').toLowerCase();
    return switch (ext) {
      'pdf' => Icons.picture_as_pdf,
      'docx' || 'doc' => Icons.description,
      'pptx' => Icons.slideshow,
      'txt' => Icons.text_snippet,
      _ => Icons.insert_drive_file,
    };
  }
}
