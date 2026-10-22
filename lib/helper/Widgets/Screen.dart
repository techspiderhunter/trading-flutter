import '../../imports.dart';

late BuildContext appContext;

class screen {
  static double get width => MediaQuery.of(appContext).size.width;
  static double get height => MediaQuery.of(appContext).size.height;
}