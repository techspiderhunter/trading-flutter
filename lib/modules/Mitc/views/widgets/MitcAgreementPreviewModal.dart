import '../../../../widgets/DeskUi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../includes/Storage.dart';
import '../../../../themes/AppColors.dart';

class MitcAgreementPreviewModal extends StatefulWidget {
  final String previewUrl;
  final VoidCallback? onDownload;

  const MitcAgreementPreviewModal({
    super.key,
    required this.previewUrl,
    this.onDownload,
  });

  static void show(
    BuildContext context, {
    required String previewUrl,
    VoidCallback? onDownload,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => MitcAgreementPreviewModal(
        previewUrl: previewUrl,
        onDownload: onDownload,
      ),
    );
  }

  @override
  State<MitcAgreementPreviewModal> createState() =>
      _MitcAgreementPreviewModalState();
}

class _MitcAgreementPreviewModalState extends State<MitcAgreementPreviewModal> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF1F3FA))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _progress = progress / 100.0;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.previewUrl),
        headers: {
          if (!widget.previewUrl.contains('google.com') &&
              !widget.previewUrl.contains('api/admin') &&
              LocalStorage.getToken() != null &&
              LocalStorage.getToken()!.isNotEmpty)
            'Authorization': 'Bearer ${LocalStorage.getToken()}',
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      if (widget.onDownload != null)
                        IconButton(
                          onPressed: widget.onDownload,
                          tooltip: 'Download PDF',
                          icon: const Icon(
                            Icons.download_rounded,
                            color: Color(0xFF10B981),
                            size: 24,
                          ),
                        ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      )
                    ]),
                    DeskHero(
                        title: 'MITC Agreement', subtitle: 'Agreement preview')
                  ])),
          const SizedBox(height: 8),

          // Progress indicator while loading
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: 2.5,
            )
          else
            const Divider(height: 1, thickness: 1, color: Color(0xFFE9EDF5)),

          // Body: WebView or Error Fallback
          Expanded(
            child: _hasError
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const DeskNote(
                              title: 'Preview unavailable',
                              description:
                                  'Please check your connection and try again.',
                              color: AppColors.error),
                          const SizedBox(height: 18),
                          DeskButton(
                              label: 'Retry Preview',
                              onPressed: () {
                                setState(() {
                                  _hasError = false;
                                  _isLoading = true;
                                });
                                _controller.reload();
                              })
                        ]))
                : ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    child: WebViewWidget(
                      controller: _controller,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
