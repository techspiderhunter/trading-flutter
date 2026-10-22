import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../includes/Storage.dart';
import '../../../models/InvoiceModel.dart';
import '../../../themes/AppColors.dart';
import '../requests/InvoiceRequest.dart';
import '../views/widgets/InvoiceDetailModal.dart';
import '../views/widgets/InvoicePreviewModal.dart';

class InvoiceController extends GetxController {
  final InvoiceRequest _request = InvoiceRequest();

  final isLoading = false.obs;
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;

  final invoices = <InvoiceModel>[].obs;
  final metrics = <String, dynamic>{}.obs;
  final selectedFilter = 'all'.obs; // 'all', 'approved', 'pending', 'cancelled'
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
  }

  int get totalInvoices => (metrics['total'] is int) ? metrics['total'] as int : invoices.length;
  int get approvedInvoices => (metrics['approved'] is int) ? metrics['approved'] as int : invoices.where((i) => i.isApproved).length;
  int get pendingInvoices => (metrics['pending'] is int) ? metrics['pending'] as int : invoices.where((i) => i.isPending).length;
  String get totalPaidAmount => metrics['formatted_total_paid']?.toString() ?? '₹0.00';

  Future<void> loadInvoices({bool refresh = false}) async {
    if (!LocalStorage.hasToken()) return;

    try {
      if (!refresh && invoices.isEmpty) {
        isLoading.value = true;
      }

      final res = await _request.getInvoices(
        status: selectedFilter.value,
        search: searchQuery.value,
      );

      if (res.success && res.data != null) {
        invoices.assignAll(res.data!.invoices);
        metrics.assignAll(res.data!.metrics);
      } else if (!res.success) {
        Get.snackbar(
          'Notice',
          res.message.isNotEmpty ? res.message : 'Could not fetch invoices.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: AppColors.textPrimary,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      // Graceful error handling
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      loadInvoices(refresh: true);
    }
  }

  void searchInvoices(String query) {
    searchQuery.value = query;
    loadInvoices(refresh: true);
  }

  /// Show detailed tax invoice bottom sheet
  void showInvoiceDetails(InvoiceModel invoice) {
    final ctx = Get.context;
    if (ctx == null) return;

    InvoiceDetailModal.show(
      ctx,
      invoice: invoice,
      onPreview: () => showInvoicePreview(invoice),
      onDownload: () => downloadInvoicePdf(invoice),
    );
  }

  /// Show in-app WebView preview modal
  void showInvoicePreview(InvoiceModel invoice) {
    final ctx = Get.context;
    if (ctx == null) return;

    InvoicePreviewModal.show(
      ctx,
      invoice: invoice,
      onDownload: () => downloadInvoicePdf(invoice),
    );
  }

  /// Download / Open Invoice PDF via external application (System PDF Viewer / Browser)
  Future<void> downloadInvoicePdf(InvoiceModel invoice) async {
    final secureUrl = invoice.secureDownloadUrl;
    if (secureUrl.isEmpty) {
      Get.snackbar(
        'Invoice Unavailable',
        'Download link is not available for this invoice.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isDownloading.value = true;
      downloadProgress.value = 0.0;

      // Always copy link to clipboard for convenience
      await Clipboard.setData(ClipboardData(text: secureUrl));

      final uri = Uri.parse(secureUrl);
      bool launched = false;

      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

      Get.snackbar(
        'Opening Invoice PDF',
        'Opening PDF in browser / download manager...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF059669),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 28),
      );
    } catch (e) {
      Get.snackbar(
        'Download Link Copied',
        'Invoice link copied to clipboard. You can paste it into your browser to download.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: AppColors.textPrimary,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.link_rounded, color: AppColors.primary),
      );
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }
}
