import 'package:get/get.dart';
import '../../modules/imports.dart';

class MainRoutes {
  static const initial = '/';

  static final List<GetPage> routes = [
    ...SplashRoutes.routes,
    ...AuthRoutes.routes,
    ...MainNavRoutes.routes,
    ...DashboardRoutes.routes,
    ...KycRoutes.routes,
    ...ProfileRoutes.routes,
    ...MitcRoutes.routes,
    ...InvoiceRoutes.routes,
  ];
}
