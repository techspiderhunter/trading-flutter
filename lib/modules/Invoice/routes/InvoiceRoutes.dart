import 'package:get/get.dart';
import '../views/InvoiceIndexView.dart';
import '../controllers/InvoiceController.dart';

class InvoiceRoutes {
  static const invoice = '/client/invoices';
  static const invoiceIndex = '/client/invoices/index';

  static final routes = [
    GetPage(
      name: invoice,
      page: () => const InvoiceIndexView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<InvoiceController>(() => InvoiceController());
      }),
    ),
    GetPage(
      name: invoiceIndex,
      page: () => const InvoiceIndexView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<InvoiceController>(() => InvoiceController());
      }),
    ),
  ];
}
