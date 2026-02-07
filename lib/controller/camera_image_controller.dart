import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraImageController {
  List<CameraDescription>? _cameras;

  Future<void> initializeCameras() async {
    await getCameraPermissions();
    _cameras = await availableCameras();
    print("number of cameras: ${_cameras?.length}");
  }

  Future<void> getCameraPermissions() async {
    PermissionStatus status = await Permission.camera.request();
    if (!status.isGranted) {
      throw Exception("Camera permission not granted");
    }
  }

  Future<CameraController> getCameraController() async {
    if (_cameras == null || _cameras!.isEmpty) {
      await initializeCameras();
    }
    
    print("Cameras: $_cameras");
    CameraController cameraController = CameraController(
      _cameras![0],
      ResolutionPreset.high,
    );
    await cameraController.initialize();
    return cameraController;
  }
}
