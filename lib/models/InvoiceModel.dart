import 'dart:convert';
import 'package:flutter/material.dart';
import '../global/requests/GlobalRequest.dart';
import '../includes/Storage.dart';

/// Complete Tax Invoice Model representing client billing records.
/// Fully synchronized with Laravel ClientPortalController invoices & showInvoice.
class InvoiceModel {
  final int? id;
  final String? uuid;
  final String invoiceNumber;
  final int? userId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final int? serviceId;
  final String serviceName;
  final String categoryName;
  final String planName;
  final String duration;
  final String? startDate;
  final String? endDate;
  final String? startDateFormatted;
  final String? endDateFormatted;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String formattedAmount;
  final String formattedSubtotal;
  final String formattedTax;
  final String currency;
  final String status; // 'pending', 'approved', 'cancelled'
  final String formattedStatus;
  final String? cancellationReason;
  final String? notes;
  final String? approvedAt;
  final String? createdAt;
  final String? createdDate;
  final String? downloadUrl;
  final String? previewUrl;
  final String? pdfUrl;

  InvoiceModel({
    this.id,
    this.uuid,
    required this.invoiceNumber,
    this.userId,
    this.clientName = 'Client User',
    this.clientEmail = '',
    this.clientPhone = '',
    this.serviceId,
    this.serviceName = 'Research Advisory',
    this.categoryName = '',
    this.planName = 'Standard Plan',
    this.duration = '-',
    this.startDate,
    this.endDate,
    this.startDateFormatted,
    this.endDateFormatted,
    this.subtotal = 0.0,
    this.taxRate = 18.0,
    this.taxAmount = 0.0,
    this.totalAmount = 0.0,
    this.formattedAmount = '₹0.00',
    this.formattedSubtotal = '₹0.00',
    this.formattedTax = '₹0.00',
    this.currency = 'INR',
    this.status = 'pending',
    this.formattedStatus = 'Pending',
    this.cancellationReason,
    this.notes,
    this.approvedAt,
    this.createdAt,
    this.createdDate,
    this.downloadUrl,
    this.previewUrl,
    this.pdfUrl,
  });

  bool get isApproved =>
      status.trim().toLowerCase() == 'approved' ||
      status.trim().toLowerCase() == 'active' ||
      (approvedAt != null &&
          approvedAt!.trim().isNotEmpty &&
          approvedAt!.toLowerCase() != 'null');

  bool get isCancelled => status.trim().toLowerCase() == 'cancelled';

  bool get isPending => !isApproved && !isCancelled;

  String get displayStatus {
    if (isApproved) return 'APPROVED';
    if (isCancelled) return 'CANCELLED';
    return 'PENDING';
  }

  Color get statusColor {
    if (isApproved) return const Color(0xFF059669);
    if (isPending) return const Color(0xFFD97706);
    if (isCancelled) return const Color(0xFFDC2626);
    return const Color(0xFF64748B);
  }

  Color get statusBgColor {
    if (isApproved) return const Color(0xFFECFDF5);
    if (isPending) return const Color(0xFFFEF3C7);
    if (isCancelled) return const Color(0xFFFEF2F2);
    return const Color(0xFFF1F5F9);
  }

  String get displayValidity {
    if (startDateFormatted != null && endDateFormatted != null) {
      return '$startDateFormatted - $endDateFormatted';
    }
    if (startDate != null && endDate != null) {
      return '$startDate - $endDate';
    }
    return duration.isNotEmpty ? duration : 'Active';
  }

  /// Robust URL normalizer resolving baseUrl, relative paths, localhost fallbacks & auth tokens
  String _normalizeUrl(String? rawUrl, String defaultEndpointPath) {
    String base = GlobalRequest.currentBaseUrl.trim();
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    String url = (rawUrl ?? '').trim();
    if (url.isEmpty || url.toLowerCase() == 'null') {
      url = '$base$defaultEndpointPath';
    } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final path = url.startsWith('/') ? url : '/$url';
      url = '$base$path';
    } else if (url.contains('127.0.0.1:8000') ||
        url.contains('localhost:8000') ||
        url.contains('10.0.2.2:8000')) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        final queryStr = uri.hasQuery ? '?${uri.query}' : '';
        url = '$base${uri.path}$queryStr';
      }
    }

    final token = LocalStorage.getToken();
    if (token != null && token.isNotEmpty && !url.contains('token=')) {
      final sep = url.contains('?') ? '&' : '?';
      url = '$url${sep}token=$token';
    }
    return url;
  }

  /// Resolve full URL with base prefix and auth token for webviews & downloads
  String get securePreviewUrl =>
      _normalizeUrl(previewUrl, '/api/client/invoices/${id ?? uuid ?? 1}/preview-html');

  String get secureDownloadUrl =>
      _normalizeUrl(downloadUrl, '/api/client/invoices/${id ?? uuid ?? 1}/download-pdf');

  String get securePdfUrl =>
      _normalizeUrl(pdfUrl ?? downloadUrl, '/api/client/invoices/${id ?? uuid ?? 1}/download-pdf');

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final total = parseDouble(json['total_amount']);
    final sub = parseDouble(json['subtotal']);
    final tax = parseDouble(json['tax_amount']);

    final rawStatus = (json['status']?.toString() ?? 'pending').trim().toLowerCase();
    final rawApprovedAt = json['approved_at']?.toString();
    final isActuallyApproved = rawStatus == 'approved' ||
        rawStatus == 'active' ||
        (rawApprovedAt != null &&
            rawApprovedAt.trim().isNotEmpty &&
            rawApprovedAt.toLowerCase() != 'null');
    final resolvedStatus = isActuallyApproved
        ? 'approved'
        : (rawStatus == 'cancelled' ? 'cancelled' : 'pending');
    final resolvedFormattedStatus = isActuallyApproved
        ? 'Approved'
        : (rawStatus == 'cancelled' ? 'Cancelled' : 'Pending');

    return InvoiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      uuid: json['uuid']?.toString(),
      invoiceNumber: json['invoice_number']?.toString() ?? 'INV-UNKNOWN',
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
      clientName: json['client_name']?.toString() ?? 'Client User',
      clientEmail: json['client_email']?.toString() ?? '',
      clientPhone: json['client_phone']?.toString() ?? '',
      serviceId: json['service_id'] is int ? json['service_id'] : int.tryParse(json['service_id']?.toString() ?? ''),
      serviceName: json['service_name']?.toString() ?? 'Research Advisory',
      categoryName: json['category_name']?.toString() ?? '',
      planName: json['plan_name']?.toString() ?? 'Standard Plan',
      duration: json['duration']?.toString() ?? '-',
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      startDateFormatted: json['start_date_formatted']?.toString(),
      endDateFormatted: json['end_date_formatted']?.toString(),
      subtotal: sub,
      taxRate: parseDouble(json['tax_rate'] ?? 18.0),
      taxAmount: tax,
      totalAmount: total,
      formattedAmount: json['formatted_amount']?.toString() ?? '₹${total.toStringAsFixed(2)}',
      formattedSubtotal: json['formatted_subtotal']?.toString() ?? '₹${sub.toStringAsFixed(2)}',
      formattedTax: json['formatted_tax']?.toString() ?? '₹${tax.toStringAsFixed(2)}',
      currency: json['currency']?.toString() ?? 'INR',
      status: resolvedStatus,
      formattedStatus: resolvedFormattedStatus,
      cancellationReason: json['cancellation_reason']?.toString(),
      notes: json['notes']?.toString(),
      approvedAt: rawApprovedAt,
      createdAt: json['created_at']?.toString(),
      createdDate: json['created_date']?.toString(),
      downloadUrl: json['download_url']?.toString(),
      previewUrl: json['preview_url']?.toString(),
      pdfUrl: json['pdf_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'invoice_number': invoiceNumber,
      'user_id': userId,
      'client_name': clientName,
      'client_email': clientEmail,
      'client_phone': clientPhone,
      'service_id': serviceId,
      'service_name': serviceName,
      'category_name': categoryName,
      'plan_name': planName,
      'duration': duration,
      'start_date': startDate,
      'end_date': endDate,
      'start_date_formatted': startDateFormatted,
      'end_date_formatted': endDateFormatted,
      'subtotal': subtotal,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'formatted_amount': formattedAmount,
      'formatted_subtotal': formattedSubtotal,
      'formatted_tax': formattedTax,
      'currency': currency,
      'status': status,
      'formatted_status': formattedStatus,
      'cancellation_reason': cancellationReason,
      'notes': notes,
      'approved_at': approvedAt,
      'created_at': createdAt,
      'created_date': createdDate,
      'download_url': downloadUrl,
      'preview_url': previewUrl,
      'pdf_url': pdfUrl,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory InvoiceModel.fromJsonString(String source) =>
      InvoiceModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
