import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/DeskUi.dart';
import '../../../themes/colors.dart';
import '../controllers/InvoiceController.dart';

class InvoiceIndexView extends StatelessWidget {
  const InvoiceIndexView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<InvoiceController>()
        ? Get.find<InvoiceController>()
        : Get.put(InvoiceController());
    return Scaffold(
        appBar:
            DeskAppBar(group: 'Billing', onBack: () => Get.back(), actions: [
          IconButton(
              tooltip: 'Refresh Invoices',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => controller.loadInvoices(refresh: true))
        ]),
        body: DeskBody(
            onRefresh: () => controller.loadInvoices(refresh: true),
            children: [
              const DeskHero(
                  title: 'All your invoices.',
                  subtitle: 'GST invoices and payment receipts.'),
              const SizedBox(height: 25),
              Obx(() => DeskNote(
                  title: 'Total paid · ${controller.totalPaidAmount}',
                  description:
                      '${controller.totalInvoices} invoices · ${controller.approvedInvoices} approved · ${controller.pendingInvoices} pending')),
              const SizedBox(height: 18),
              Obx(() => Wrap(
                  spacing: 7,
                  runSpacing: 8,
                  children: ['all', 'approved', 'pending', 'cancelled']
                      .map((filter) => ChoiceChip(
                          label: Text(
                              '${filter[0].toUpperCase()}${filter.substring(1)}',
                              style: deskText.copyWith(
                                  fontSize: 10,
                                  color:
                                      controller.selectedFilter.value == filter
                                          ? Colors.white
                                          : AppColors.textSecondary)),
                          selected: controller.selectedFilter.value == filter,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                              side: const BorderSide(color: AppColors.border)),
                          onSelected: (_) => controller.setFilter(filter)))
                      .toList())),
              const SizedBox(height: 24),
              Obx(() {
                if (controller.isLoading.value)
                  return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()));
                if (controller.invoices.isEmpty)
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DeskNote(
                            title: 'No tax invoices found',
                            description: controller.selectedFilter.value ==
                                    'all'
                                ? 'GST invoices and payment receipts appear here once service subscriptions are active.'
                                : 'No invoices found matching "${controller.selectedFilter.value}" status.'),
                        const SizedBox(height: 18),
                        DeskButton(
                            label: 'Refresh List',
                            secondary: true,
                            onPressed: () =>
                                controller.loadInvoices(refresh: true)),
                      ]);
                return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.invoices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final inv = controller.invoices[index];
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DeskRow(
                                title:
                                    '${inv.invoiceNumber} · ${inv.formattedStatus}',
                                subtitle: '${inv.planName} · ${inv.duration}',
                                icon: Icons.receipt_long_outlined,
                                onTap: () =>
                                    controller.showInvoiceDetails(inv)),
                            const SizedBox(height: 15),
                            DeskRow(
                                title: inv.formattedAmount,
                                subtitle: 'Incl. GST · ${inv.displayValidity}',
                                icon: Icons.receipt_long_outlined,
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          tooltip: 'Preview',
                                          icon: const Icon(
                                              Icons.visibility_outlined,
                                              size: 18),
                                          onPressed: () => controller
                                              .showInvoicePreview(inv)),
                                      IconButton(
                                          tooltip: 'Download PDF',
                                          icon: const Icon(
                                              Icons.download_rounded,
                                              size: 18),
                                          onPressed: () => controller
                                              .downloadInvoicePdf(inv)),
                                    ])),
                          ]);
                    });
              }),
            ]));
  }
}
