
import 'package:get/get.dart';

import 'screen/splash/controller/splash_controller.dart';

import 'screen/home/controller.dart/home_controller.dart';
import 'screen/bottom_bar/controller/bottom_bar_controller.dart';

class MyBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<BottomBarController>(() => BottomBarController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);

    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);



  }
}
