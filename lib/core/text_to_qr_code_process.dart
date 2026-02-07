import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

class TextToQrCodeProcess {
  Uint8List encodeQrToJpg(String data, {int size = 300, int quality = 90}) {
    try {
      print('Encoding QR with data length: ${data.length}');
      
      final qrcode = Encoder.encode(data, ErrorCorrectionLevel.h);
      final matrix = qrcode.matrix!;
      
      // Use higher scale for better quality and add quiet zone (border)
      final scale = 10;
      final quietZone = 4; // QR code standard quiet zone
      final matrixSize = matrix.width;
      final dimension = (matrixSize + 2 * quietZone) * scale;

      final image = img.Image(
          width: dimension, 
          height: dimension, 
          numChannels: 4);
      
      // Fill with white background
      img.fill(image, color: img.ColorRgba8(255, 255, 255, 255));

      // Draw QR code modules with quiet zone offset
      for (var y = 0; y < matrixSize; y++) {
        for (var x = 0; x < matrixSize; x++) {
          if (matrix.get(x, y) == 1) {
            final offsetX = (x + quietZone) * scale;
            final offsetY = (y + quietZone) * scale;
            img.fillRect(image,
                x1: offsetX,
                y1: offsetY,
                x2: offsetX + scale,
                y2: offsetY + scale,
                color: img.ColorRgba8(0, 0, 0, 255));
          }
        }
      }
      
      print('Generated QR code: ${dimension}x$dimension (matrix: $matrixSize)');
      return img.encodePng(image);
    } catch (e) {
      print('QR encode error: $e');
      rethrow;
    }
  }
}
