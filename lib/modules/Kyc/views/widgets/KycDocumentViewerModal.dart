import '../../../../widgets/DeskUi.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../includes/Storage.dart';
import '../../../../themes/AppColors.dart';

/// Modal dialog for viewing an uploaded KYC document proof (PAN Card, Aadhaar Card, etc.)
/// Supports pinch-to-zoom, pan, network authentication headers, and local file fallback.
class KycDocumentViewerModal extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? localFilePath;

  const KycDocumentViewerModal({
    super.key,
    required this.title,
    this.imageUrl,
    this.localFilePath,
  });

  static void show(
    BuildContext context, {
    required String title,
    String? imageUrl,
    String? localFilePath,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => KycDocumentViewerModal(
        title: title,
        imageUrl: imageUrl,
        localFilePath: localFilePath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = LocalStorage.getToken();
    final bool hasLocalFile =
        localFilePath != null && File(localFilePath!).existsSync();
    final bool hasRemoteUrl = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 520,
        ),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                          tooltip: 'Close',
                        )
                      ]),
                      DeskHero(
                          title: title, subtitle: 'Secure document preview')
                    ])),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE9EDF5)),

            // Image Preview Area with InteractiveViewer (Zoom & Pan)
            Flexible(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(0),
                  ),
                  child: Center(
                    child: hasLocalFile
                        ? InteractiveViewer(
                            minScale: 0.8,
                            maxScale: 4.5,
                            child: Image.file(
                              File(localFilePath!),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _buildErrorWidget(),
                            ),
                          )
                        : (hasRemoteUrl
                            ? InteractiveViewer(
                                minScale: 0.8,
                                maxScale: 4.5,
                                child: Image.network(
                                  imageUrl!,
                                  headers: {
                                    if (token != null && token.isNotEmpty)
                                      'Authorization': 'Bearer $token',
                                  },
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    final total =
                                        loadingProgress.expectedTotalBytes;
                                    final loaded =
                                        loadingProgress.cumulativeBytesLoaded;
                                    final progress = total != null && total > 0
                                        ? loaded / total
                                        : null;

                                    return Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                            value: progress,
                                            strokeWidth: 2.5,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(AppColors.primary),
                                          ),
                                          const SizedBox(height: 14),
                                          const Text(
                                            'Loading document...',
                                            style: TextStyle(
                                              fontFamily: 'DeskSans',
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) =>
                                      _buildErrorWidget(),
                                ),
                              )
                            : _buildErrorWidget()),
                  ),
                ),
              ),
            ),

            // Bottom Actions Bar
            Padding(
                padding: const EdgeInsets.all(24),
                child: DeskButton(
                    label: 'Close',
                    secondary: true,
                    onPressed: () => Navigator.of(context).pop())),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: DeskNote(
            title: 'Document Preview Unavailable',
            description: 'The document proof could not be loaded from storage.',
            color: AppColors.error));
  }
}
