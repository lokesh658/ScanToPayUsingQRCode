import 'package:qr_code_scanner/controller/camera_image_controller.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/core/text_to_qr_code_process.dart';
class DependencyInjection {
  static void init() {
    Get.lazyPut<CameraImageController>(() => CameraImageController());
    Get.lazyPut<TextToQrCodeProcess>(() => TextToQrCodeProcess());
  }
}