import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:division/division.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:wholesale/bloc/distributor/barang/distributor_barang_bloc.dart';
import 'package:wholesale/models/distributor_barang_model.dart';
import 'package:wholesale/static_data.dart';
import 'package:wholesale/ui/components/item_button_process.dart';
import 'package:wholesale/ui/components/item_input_text.dart';
import 'package:wholesale/ui/components/item_picker_comp.dart';
import 'package:wholesale/utils/compress_utils.dart';

class EditDistributorBarangController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController namaBarangController = TextEditingController();
  TextEditingController stokController = TextEditingController();
  TextEditingController hargaDasarController = TextEditingController();
  TextEditingController hargaJualController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();
  final jeniss = [].obs;
  final selectedJenis = "".obs;
  final ukurans = [].obs;
  final selectedUkuran = "".obs;
  final isLoading = false.obs;
  final barang = DistributorBarangModel().obs;
  void process(DistributorBarangBloc bloc) {
    if (barang.value.jenis_barang_id == null) {
      Flushbar(
        title: "Error",
        message: "Jenis Barang harus diisi",
        duration: Duration(seconds: 5),
        icon: Icon(
          Icons.do_not_disturb,
          color: Colors.redAccent,
        ),
      )..show(Get.context);
      return;
    }
    if (barang.value.ukuran_barang_id == null) {
      Flushbar(
        title: "Error",
        message: "Ukuran Barang harus diisi",
        duration: Duration(seconds: 5),
        icon: Icon(
          Icons.do_not_disturb,
          color: Colors.redAccent,
        ),
      )..show(Get.context);
      return;
    }
    isLoading.value = true;
    barang.update((val) {
      val.nama_barang = namaBarangController.text;
      val.stok = int.parse(stokController.text);
      val.harga_dasar = int.parse(hargaDasarController.text);
      val.harga_jual = int.parse(hargaJualController.text);
      val.keterangan = keteranganController.text;
    });
    bloc..add(DistributorBarangEditEvent(barang.value));
  }

  void showJenisBarangPicker(DistributorBarangBloc bloc) {
    bloc..add(DistributorBarangGetStaticEvent());
    int initialIndex = 0;
    if (barang.value.jenis_barang_id != null) {
      int no = 0;
      for (var jenis in jeniss) {
        if (barang.value.jenis_barang_id == int.parse(jenis['id'])) {
          initialIndex = no;
        }
        no = no + 1;
      }
    }
    showModalBottomSheet(
        context: Get.context,
        builder: (BuildContext context) {
          return Container(
            height: 200.0,
            child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: initialIndex),
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  selectedJenis.value = jeniss[index]['nama'];
                  barang.update((val) {
                    val.jenis_barang_id = int.parse(jeniss[index]['id']);
                  });
                },
                children: new List<Widget>.generate(jeniss.length, (int index) {
                  return new Center(
                    child: new Text(jeniss[index]['nama']),
                  );
                })),
          );
        });
  }

  void showUkuranBarangPicker(DistributorBarangBloc bloc) {
    bloc..add(DistributorBarangGetStaticEvent());
    int initialIndex = 0;
    if (barang.value.ukuran_barang_id != null) {
      int no = 0;
      for (var jenis in ukurans) {
        if (barang.value.ukuran_barang_id == int.parse(jenis['id'])) {
          initialIndex = no;
        }
        no = no + 1;
      }
    }
    showModalBottomSheet(
        context: Get.context,
        builder: (BuildContext context) {
          return Container(
            height: 200.0,
            child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: initialIndex),
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  selectedUkuran.value = ukurans[index]['nama'];
                  barang.update((val) {
                    val.ukuran_barang_id = int.parse(ukurans[index]['id']);
                  });
                },
                children:
                    new List<Widget>.generate(ukurans.length, (int index) {
                  return new Center(
                    child: new Text(ukurans[index]['nama']),
                  );
                })),
          );
        });
  }

  void setData() {
    namaBarangController.text = "";
    stokController.text = "";
    hargaDasarController.text = "";
    hargaJualController.text = "";
    keteranganController.text = "";

    namaBarangController.text = barang.value.nama_barang;
    stokController.text = barang.value.stok.toString();
    hargaDasarController.text = barang.value.harga_dasar.toString();
    hargaJualController.text = barang.value.harga_jual.toString();
    keteranganController.text = barang.value.keterangan;
  }

  String getFromList(Map<String, dynamic> data, String pembanding, String table,
      String id, String nama) {
    var datas = data[table] as List;
    String hasil = "";
    datas.forEach((e) {
      if (pembanding == e[id]) {
        hasil = e[nama];
      }
    });
    return hasil;
  }

  void staticData(Map<String, dynamic> data) {
    selectedJenis.value = getFromList(
        data, barang.value.jenis_barang_id.toString(), 'jeniss', 'id', 'nama');
    selectedUkuran.value = getFromList(data,
        barang.value.ukuran_barang_id.toString(), 'ukurans', 'id', 'nama');
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Pilih Foto Difabel",
          allViewTitle: "Semua Foto",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    print("data $error");
    if (resultList.length != 0) {
      ByteData image = await resultList[0].getByteData();
      Uint8List imageUint8List =
          image.buffer.asUint8List(image.offsetInBytes, image.lengthInBytes);
      Uint8List imageCompress = await CompressUtils.image(list: imageUint8List);
      List<int> imageListInt = imageCompress.cast<int>();
      String imageFile = base64Encode(imageListInt);
      barang.update((val) {
        val.foto = imageFile;
      });
    }
  }

  void showImage() {
    Widget image;
    if (barang.value.foto.contains("img_") ||
        barang.value.foto == 'kosong.png') {
      image = CachedNetworkImage(
          imageUrl: "${StaticData.baseUrl}/uploads/${barang.value.foto}",
          fit: BoxFit.fill,
          placeholder: (context, url) => new CircularProgressIndicator(),
          errorWidget: (context, url, error) => new Icon(Icons.error));
    } else {
      List<int> imageListInt = base64Decode(barang.value.foto);
      image = Image.memory(
        imageListInt,
        fit: BoxFit.fill,
      );
    }
    showDialog(
        context: Get.context,
        child: AlertDialog(
          title: Txt("Foto"),
          content: image,
        ));
  }

  @override
  void onInit() {
    barang.value = Get.arguments;
    super.onInit();
  }
}

class EditDistributorBarangPage extends StatelessWidget {
  final controller = Get.put(EditDistributorBarangController());
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(StaticData.screenWidth, StaticData.screenHeight),
        allowFontScaling: true);
    return Scaffold(
        appBar: AppBar(
            title: Obx(() => Text(
                "Edit Distributor Barang ${controller.barang.value.nama_barang}"))),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocProvider(
            create: (context) => DistributorBarangBloc()
              ..add(DistributorBarangGetEvent(controller.barang.value.id)),
            child: EditDistributorBarangView(),
          ),
        ));
  }
}

class EditDistributorBarangView extends StatelessWidget {
  final controller = Get.find<EditDistributorBarangController>();
  DistributorBarangBloc bloc;

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<DistributorBarangBloc>(context);
    return BlocListener<DistributorBarangBloc, DistributorBarangState>(
      listener: (context, state) {
        if (state is DistributorBarangStaticStateSuccess) {
          controller.isLoading.value = false;
          controller.jeniss.value = state.data['data']['jeniss'];
          controller.ukurans.value = state.data['data']['ukurans'];
          controller.staticData(state.data['data']);
        } else if (state is DistributorBarangStateSuccess) {
          controller.isLoading.value = false;
          bloc..add(DistributorBarangGetStaticEvent());
          controller.barang.value =
              DistributorBarangModel.createFromJson(state.data['data']);
          controller.setData();
        } else if (state is DistributorBarangStateError) {
          controller.isLoading.value = false;
          Flushbar(
              title: "Error",
              message: state.errors['message'] ?? "",
              duration: Duration(seconds: 5),
              icon: Icon(
                Icons.do_not_disturb,
                color: Colors.redAccent,
              ),
              flushbarPosition: FlushbarPosition.TOP)
            ..show(Get.context);
        } else if (state is DistributorBarangFormSuccess) {
          controller.isLoading.value = false;
          Get.back();
          Flushbar(
              title: "Success",
              message: state.data['message'] ?? "",
              duration: Duration(seconds: 5),
              icon: Icon(
                Icons.check,
                color: Colors.greenAccent,
              ),
              flushbarPosition: FlushbarPosition.TOP)
            ..show(Get.context);
        }
      },
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Txt("Nama Barang",
                      style: TxtStyle()
                        ..fontSize(16.ssp)
                        ..textColor(Colors.white)),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  ItemInputText(
                    hint: "Nama Barang",
                    controller: controller.namaBarangController,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Masukkan Nama Barang";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 0.02.sh,
                  ),
                  Txt("Jenis Barang",
                      style: TxtStyle()
                        ..fontSize(16.ssp)
                        ..textColor(Colors.white)),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  Obx(() => ItemPickerComp(
                        title: "Jenis Barang",
                        text: (controller.barang.value.jenis_barang_id != null)
                            ? controller.selectedJenis.value
                            : "Pilih Jenis Barang",
                        onTap: () {
                          controller.showJenisBarangPicker(bloc);
                        },
                      )),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed("/jenisbarang");
                    },
                    child: Txt("Tambah Jenis Barang",
                        style: TxtStyle()
                          ..fontSize(12.ssp)
                          ..textColor(Colors.black87)
                          ..textDecoration(TextDecoration.underline)
                          ..italic()),
                  ),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  Txt("Ukuran Barang",
                      style: TxtStyle()
                        ..fontSize(16.ssp)
                        ..textColor(Colors.white)),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  Obx(() => ItemPickerComp(
                        title: "Ukuran Barang",
                        text: (controller.barang.value.ukuran_barang_id != null)
                            ? controller.selectedUkuran.value
                            : "Pilih Ukuran Barang",
                        onTap: () {
                          controller.showUkuranBarangPicker(bloc);
                        },
                      )),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed("/ukuranbarang");
                    },
                    child: Txt("Tambah Ukuran Barang",
                        style: TxtStyle()
                          ..fontSize(12.ssp)
                          ..textColor(Colors.black87)
                          ..textDecoration(TextDecoration.underline)
                          ..italic()),
                  ),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  Txt("Stok",
                      style: TxtStyle()
                        ..fontSize(16.ssp)
                        ..textColor(Colors.white)),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  ItemInputText(
                    tipe: TextInputType.number,
                    hint: "Stok",
                    controller: controller.stokController,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Masukkan Stok";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 0.02.sh,
                  ),
                  Txt("Harga Dasar",
                      style: TxtStyle()
                        ..fontSize(16.ssp)
                        ..textColor(Colors.white)),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  ItemInputText(
                    tipe: TextInputType.number,
                    hint: "Harga Dasar",
                    controller: controller.hargaDasarController,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Masukkan Harga Dasar";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 0.02.sh,
                  ),
                  Txt("Harga Jual",
                      style: TxtStyle()
                        ..fontSize(16.ssp)
                        ..textColor(Colors.white)),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  ItemInputText(
                    tipe: TextInputType.number,
                    hint: "Harga Jual",
                    controller: controller.hargaJualController,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Masukkan Harga Jual";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 0.02.sh,
                  ),
                  Txt("Keterangan",
                      style: TxtStyle()
                        ..fontSize(16.ssp)
                        ..textColor(Colors.white)),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  ItemInputText(
                    tipe: TextInputType.text,
                    hint: "Keterangan",
                    controller: controller.keteranganController,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Masukkan Keterangan";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 0.02.sh,
                  ),
                  Txt(
                    "Upload Foto",
                    style: TxtStyle()
                      ..fontSize(16.ssp)
                      ..textColor(Colors.white),
                  ),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  Txt(
                    "*tipe file harus jpg atau png",
                    style: TxtStyle()
                      ..fontSize(14.ssp)
                      ..textColor(Colors.white),
                  ),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  Txt(
                    "*ukuran file maksimal 2 MB",
                    style: TxtStyle()
                      ..fontSize(14.ssp)
                      ..textColor(Colors.white),
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Parent(
                          gesture: Gestures()
                            ..onTap(() {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              controller.loadAssets();
                            }),
                          child: Center(
                            child: Txt(
                              "Pilih File",
                              style: TxtStyle()
                                ..fontSize(16.ssp)
                                ..textColor(Colors.black87),
                            ),
                          ),
                          style: ParentStyle()
                            ..background.color(Colors.white)
                            ..height(40)
                            ..elevation(2)
                            ..borderRadius(all: 4)
                            ..ripple(true, splashColor: Colors.blueAccent),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        flex: 2,
                        child: Obx(() =>
                            (controller.barang.value.foto != null &&
                                    controller.barang.value.foto != "")
                                ? Parent(
                                    gesture: Gestures()
                                      ..onTap(() {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        controller.showImage();
                                      }),
                                    child: Center(
                                      child: Txt(
                                        "Tampilkan Foto",
                                        style: TxtStyle()
                                          ..fontSize(14.ssp)
                                          ..textColor(Colors.black87),
                                      ),
                                    ),
                                    style: ParentStyle()
                                      ..background.color(Colors.white)
                                      ..height(40)
                                      ..elevation(4)
                                      ..borderRadius(all: 4)
                                      ..ripple(true,
                                          splashColor: Colors.blueAccent),
                                  )
                                : Txt(
                                    " tidak ada file yang dipilih",
                                    style: TxtStyle()
                                      ..fontSize(14.ssp)
                                      ..textColor(Colors.white),
                                  )),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 0.02.sh,
                  ),
                ],
              ),
            ),
            Obx(
              () => ItemButtonProcess(
                  title: "Kirim Data",
                  isLoading: controller.isLoading.value,
                  onTap: () {
                    if (controller.formKey.currentState.validate()) {
                      controller.process(bloc);
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
