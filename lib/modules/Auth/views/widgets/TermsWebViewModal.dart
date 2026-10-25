import '../../../../widgets/DeskUi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../themes/AppColors.dart';

/// Modal Bottom Sheet that opens the official Moneyara Terms & Conditions WebView
/// URL: https://moneyararesearch.in/terms-and-conditions
class TermsWebViewModal extends StatefulWidget {
  final String url;

  const TermsWebViewModal({
    super.key,
    this.url = 'https://moneyararesearch.in/terms-and-conditions',
  });

  static void show(BuildContext context, {String? url}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => TermsWebViewModal(
        url: url ?? 'https://moneyararesearch.in/terms-and-conditions',
      ),
    );
  }

  @override
  State<TermsWebViewModal> createState() => _TermsWebViewModalState();
}

class _TermsWebViewModalState extends State<TermsWebViewModal> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
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
      ..loadRequest(Uri.parse(widget.url));
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
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _isLoading = true;
                          });
                          _controller.reload();
                        },
                        tooltip: 'Reload',
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      )
                    ]),
                    DeskHero(
                        title: 'Terms & Conditions',
                        subtitle: 'Original legal document')
                  ])),
          const SizedBox(height: 8),

          // Loading Progress Bar
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                              label: 'Try Again',
                              onPressed: () {
                                setState(() {
                                  _hasError = false;
                                  _isLoading = true;
                                });
                                _controller.reload();
                              })
                        ]))
                : ClipRRect(
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
