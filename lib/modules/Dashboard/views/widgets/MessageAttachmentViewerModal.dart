import '../../../../widgets/DeskUi.dart';
import 'package:flutter/material.dart';
import '../../../../includes/Storage.dart';
import '../../../../themes/AppColors.dart';

/// Interactive Zoomable Viewer Modal for Market Advisory & Message Attachments
/// Features pinch-to-zoom (0.8x - 5.0x), drag-to-pan, bearer token headers,
/// smooth loading indicator, and error fallbacks.
class MessageAttachmentViewerModal extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;

  const MessageAttachmentViewerModal({
    super.key,
    required this.imageUrl,
    this.title = 'Market Attachment',
    this.subtitle,
  });

  static void show(
    BuildContext context, {
    required String imageUrl,
    String? title,
    String? subtitle,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => MessageAttachmentViewerModal(
        imageUrl: imageUrl,
        title: title ?? 'Market Attachment',
        subtitle: subtitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = LocalStorage.getToken();
    final bool hasRemoteUrl = imageUrl.trim().isNotEmpty;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 540,
        ),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
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
                          title: title,
                          subtitle: subtitle ?? 'Market attachment')
                    ])),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE9EDF5)),

            // Image Preview Area with InteractiveViewer
            Flexible(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Center(
                  child: hasRemoteUrl
                      ? InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 5.0,
                          child: Image.network(
                            imageUrl,
                            headers: {
                              if (token != null && token.isNotEmpty)
                                'Authorization': 'Bearer $token',
                            },
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              final total = loadingProgress.expectedTotalBytes;
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
                                          const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF5342C3),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'Loading attachment...',
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
                            errorBuilder: (_, __, ___) => _buildErrorWidget(),
                          ),
                        )
                      : _buildErrorWidget(),
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
            title: 'Attachment Preview Unavailable',
            description:
                'Could not load the attachment image from research storage.',
            color: AppColors.error));
  }
}
