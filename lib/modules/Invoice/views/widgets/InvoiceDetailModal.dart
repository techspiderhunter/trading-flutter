import '../../../../widgets/DeskUi.dart';
import 'package:flutter/material.dart';
import '../../../../models/InvoiceModel.dart';
import '../../../../themes/AppColors.dart';

class InvoiceDetailModal extends StatelessWidget {
  final InvoiceModel invoice;
  final VoidCallback onPreview;
  final VoidCallback onDownload;

  const InvoiceDetailModal({
    super.key,
    required this.invoice,
    required this.onPreview,
    required this.onDownload,
  });

  static void show(
    BuildContext context, {
    required InvoiceModel invoice,
    required VoidCallback onPreview,
    required VoidCallback onDownload,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InvoiceDetailModal(
        invoice: invoice,
        onPreview: onPreview,
        onDownload: onDownload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: SafeArea(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.9),
              child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  tooltip: 'Close',
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () => Navigator.pop(context))
                            ]),
                        DeskHero(
                            title: invoice.invoiceNumber,
                            subtitle:
                                'Generated on ${invoice.createdDate ?? invoice.createdAt ?? "-"}'),
                        const SizedBox(height: 25),
                        DeskNote(
                            title: invoice.displayStatus,
                            description:
                                '${invoice.planName} · ${invoice.duration}',
                            color: invoice.statusColor),
                        const SizedBox(height: 18),
                        DeskRow(
                            title: 'Validity range',
                            subtitle: invoice.displayValidity),
                        const SizedBox(height: 18),
                        const DeskSection('Tax invoice breakdown'),
                        const SizedBox(height: 8),
                        DeskRow(
                            title: 'Subtotal (excl. GST)',
                            subtitle: invoice.formattedSubtotal,
                            icon: Icons.receipt_long_outlined),
                        const SizedBox(height: 15),
                        DeskRow(
                            title:
                                'GST · ${invoice.taxRate.toStringAsFixed(0)}%',
                            subtitle: invoice.formattedTax,
                            icon: Icons.receipt_long_outlined),
                        const SizedBox(height: 15),
                        DeskRow(
                            title: 'Total amount paid',
                            subtitle: invoice.formattedAmount,
                            icon: Icons.receipt_long_outlined),
                        const SizedBox(height: 24),
                        if (invoice.isCancelled &&
                            invoice.cancellationReason != null) ...[
                          DeskNote(
                              title: 'Cancellation reason',
                              description: invoice.cancellationReason!,
                              color: AppColors.error),
                          const SizedBox(height: 18)
                        ],
                        DeskButton(label: 'Preview', onPressed: onPreview),
                        const SizedBox(height: 20),
                        DeskButton(
                            label: 'Download PDF',
                            secondary: true,
                            onPressed: onDownload),
                      ])))));
}
