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
          color: Colors.white,
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
              padding: const EdgeInsets.fromLTRB(18, 14, 10, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B074).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF00B074),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'Pinch to zoom / Drag to pan',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            // Image Preview Area with InteractiveViewer (Zoom & Pan)
            Flexible(
              child: Container(
                width: double.infinity,
                color: const Color(0xFF0F172A),
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
                                    final loaded = loadingProgress
                                        .cumulativeBytesLoaded;
                                    final progress =
                                        total != null && total > 0
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
                                                    Color>(Color(0xFF00B074)),
                                          ),
                                          const SizedBox(height: 14),
                                          const Text(
                                            'Loading document...',
                                            style: TextStyle(
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_user_rounded,
                          size: 15, color: Color(0xFF00B074)),
                      SizedBox(width: 6),
                      Text(
                        'Encrypted Verification Record',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B074),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image_not_supported_outlined,
                size: 32,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Document Preview Unavailable',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'The document proof could not be loaded from storage.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
