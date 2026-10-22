import '../imports.dart';
import 'package:flutter/widgets.dart';

class MainController extends GetxController {


  final ScrollController scrollController = ScrollController();
  // Define global variables
  var userName = ''.obs;
  var isLoggedIn = false.obs;

  // Define global methods
  void login(String name) {
    userName.value = name;
    isLoggedIn.value = true;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

  }


  void logout() {
    userName.value = '';
    isLoggedIn.value = false;
  }
}
