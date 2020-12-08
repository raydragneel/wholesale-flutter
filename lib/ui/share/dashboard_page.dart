import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wholesale/controllers/home_controller.dart';
import 'package:wholesale/static_data.dart';
import 'package:wholesale/ui/home_page.dart';
import 'package:wholesale/utils/greeting_utils.dart';
import 'package:wholesale/utils/role_utils.dart';

class DashboradController extends GetxController {
  final listIcon = [].obs;
  @override
  void onInit() async {
    if (await RoleUtils.whatRole(1)) {
      listIcon.value = [
        {"title": "Mitra", "icon": Icons.group, "onpress": 4},
        {"title": "Barang", "icon": Icons.local_offer, "onpress": 2},
        {"title": "Penjualan", "icon": Icons.bar_chart, "onpress": 3},
      ];
    }
    super.onInit();
  }
}

class DashboardPage extends StatelessWidget {
  final controller = Get.put(DashboradController());
  final homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(StaticData.screenWidth, StaticData.screenHeight),
        allowFontScaling: true);
    return Container(
      height: 1.sh,
      width: 1.sw,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
            ),
          ),
          Parent(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Txt("Selamat " + GreetingUtils.show(),
                      style: TxtStyle()
                        ..fontSize(18.sp)
                        ..textColor(Colors.white)),
                  SizedBox(
                    height: 0.02.sh,
                  ),
                  Txt(homeController.userModel.value.nama.capitalizeFirst ?? "",
                      style: TxtStyle()
                        ..fontSize(18.sp)
                        ..textColor(Colors.white)),
                  SizedBox(
                    height: 0.05.sh,
                  ),
                ],
              ),
              style: ParentStyle()
                ..background
                    .image(path: "assets/images/night.jpg", fit: BoxFit.cover)
                ..height(0.25.sh)
                ..width(1.sw)),
          Positioned(
            top: 0.18.sh,
            left: 0.05.sw,
            right: 0.05.sw,
            child: Parent(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Txt(
                        "Keuntungan",
                        style: TxtStyle()
                          ..fontSize(14.sp)
                          ..fontWeight(FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Txt("1.000.000"),
                          Icon(Icons.arrow_right_rounded)
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Txt(
                        "Aset",
                        style: TxtStyle()
                          ..fontSize(14.sp)
                          ..fontWeight(FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Txt("1.000.000"),
                          Icon(Icons.arrow_right_rounded)
                        ],
                      )
                    ],
                  ),
                  Divider(),
                  Expanded(
                      child: Obx(() => ListView.builder(
                            itemExtent: 80,
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.listIcon.length,
                            itemBuilder: (context, index) => Parent(
                              gesture: Gestures()
                                ..onTap(() {
                                  homeController.actionsList = [];
                                  if (homeController.userModel.value.role_id ==
                                          1 &&
                                      controller.listIcon[index]['title']
                                          .contains('Barang')) {
                                    homeController.updateListBarang();
                                  }
                                  homeController.page.value =
                                      controller.listIcon[index]['onpress'];
                                }),
                              style: ParentStyle()
                                ..ripple(true, splashColor: Colors.blueAccent)
                                ..borderRadius(all: 10),
                              child: Column(
                                children: [
                                  Icon(
                                      controller.listIcon[index]['icon'] ??
                                          Icons.ac_unit,
                                      size: 40.sp,
                                      color: Colors.grey),
                                  Txt(
                                    controller.listIcon[index]['title'] ?? "",
                                    style: TxtStyle()
                                      ..fontSize(14.sp)
                                      ..textColor(Colors.grey),
                                  )
                                ],
                              ),
                            ),
                          )))
                ],
              ),
              style: ParentStyle()
                ..height(0.2.sh)
                ..padding(all: 10)
                ..background.color(Colors.white)
                ..borderRadius(all: 20)
                ..elevation(3),
            ),
          ),
        ],
      ),
    );
  }
}
