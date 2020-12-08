import 'package:division/division.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:wholesale/bloc/distributor/toko/distributortoko_bloc.dart';
import 'package:wholesale/models/toko_model.dart';
import 'package:wholesale/static_data.dart';
import 'package:wholesale/ui/components/item_button_process.dart';
import 'package:wholesale/ui/components/item_input_text.dart';

class TambahMitraController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController noTelpController = TextEditingController();
  final isLoading = false.obs;
  void process(DistributorTokoBloc bloc) {
    isLoading.value = true;
    TokoModel toko = TokoModel(
        username: usernameController.text,
        nama: namaController.text,
        email: emailController.text,
        alamat: alamatController.text,
        no_telp: noTelpController.text);
    bloc..add(DistributorTokoTambahEvent(toko));
  }
}

class TambahMitraPage extends StatelessWidget {
  final controller = Get.put(TambahMitraController());
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(StaticData.screenWidth, StaticData.screenHeight),
        allowFontScaling: true);
    return Scaffold(
        appBar: AppBar(
          title: Text("Tambah Mitra / Toko"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocProvider(
            create: (context) => DistributorTokoBloc(),
            child: TambahMitraView(),
          ),
        ));
  }
}

class TambahMitraView extends StatelessWidget {
  final controller = Get.find<TambahMitraController>();
  DistributorTokoBloc bloc;

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<DistributorTokoBloc>(context);
    return BlocListener<DistributorTokoBloc, DistributorTokoState>(
      listener: (context, state) {
        if (state is DistributorTokoStateSuccess) {
          controller.isLoading.value = false;
          Get.back();
          Flushbar(
            title: "Success",
            message: state.data['message'],
            icon: Icon(
              Icons.check,
              color: Colors.greenAccent,
            ),
            duration: Duration(seconds: 2),
            flushbarPosition: FlushbarPosition.TOP,
          )..show(context);
        } else if (state is DistributorTokoStateError) {
          controller.isLoading.value = false;
          Flushbar(
            title: "Error",
            message: state.errors['data']['username'] ??
                state.errors['data']['email'] ??
                state.errors['message'] ??
                "",
            duration: Duration(seconds: 5),
            icon: Icon(
              Icons.do_not_disturb,
              color: Colors.redAccent,
            ),
            flushbarPosition: FlushbarPosition.TOP,
          )..show(Get.context);
        }
      },
      child: Form(
        key: controller.formKey,
        child: ListView(
          children: [
            Txt("Username",
                style: TxtStyle()
                  ..fontSize(16.ssp)
                  ..textColor(Colors.white)),
            SizedBox(
              height: 0.01.sh,
            ),
            ItemInputText(
              hint: "Username",
              controller: controller.usernameController,
              validator: (String value) {
                if (value.isEmpty) {
                  return "Masukkan Username";
                }
                return null;
              },
            ),
            Txt("Nama Toko",
                style: TxtStyle()
                  ..fontSize(16.ssp)
                  ..textColor(Colors.white)),
            SizedBox(
              height: 0.01.sh,
            ),
            ItemInputText(
              hint: "Nama Toko",
              controller: controller.namaController,
              validator: (String value) {
                if (value.isEmpty) {
                  return "Masukkan Nama Toko";
                }
                return null;
              },
            ),
            SizedBox(
              height: 0.02.sh,
            ),
            Txt("Email",
                style: TxtStyle()
                  ..fontSize(16.ssp)
                  ..textColor(Colors.white)),
            SizedBox(
              height: 0.01.sh,
            ),
            ItemInputText(
              tipe: TextInputType.emailAddress,
              hint: "Email",
              controller: controller.emailController,
              validator: (String value) {
                if (value.isEmpty) {
                  return "Masukkan Email";
                }
                return null;
              },
            ),
            SizedBox(
              height: 0.02.sh,
            ),
            Txt("Alamat",
                style: TxtStyle()
                  ..fontSize(16.ssp)
                  ..textColor(Colors.white)),
            SizedBox(
              height: 0.01.sh,
            ),
            ItemInputText(
              hint: "Alamat",
              controller: controller.alamatController,
              validator: (String value) {
                if (value.isEmpty) {
                  return "Masukkan Alamat";
                }
                return null;
              },
            ),
            SizedBox(
              height: 0.02.sh,
            ),
            Txt("No Telp",
                style: TxtStyle()
                  ..fontSize(16.ssp)
                  ..textColor(Colors.white)),
            SizedBox(
              height: 0.01.sh,
            ),
            ItemInputText(
              tipe: TextInputType.number,
              hint: "No Telp",
              controller: controller.noTelpController,
              validator: (String value) {
                if (value.isEmpty) {
                  return "Masukkan No Telp";
                }
                return null;
              },
            ),
            SizedBox(
              height: 0.02.sh,
            ),
            Obx(() => ItemButtonProcess(
                  title: "Kirim Data",
                  isLoading: controller.isLoading.value,
                  onTap: () {
                    if (controller.formKey.currentState.validate()) {
                      controller.process(bloc);
                    }
                  },
                ))
          ],
        ),
      ),
    );
  }
}
