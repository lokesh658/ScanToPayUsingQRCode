import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

class QrCodeDecoder {
  String? decodeFromBytes(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        print('Failed to decode image bytes');
        return null;
      }

      final width = decoded.width;
      final height = decoded.height;
      print('Decoding image: ${width}x$height');

      // Create ARGB int array for RGBLuminanceSource
      final pixels = Int32List(width * height);
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixel = decoded.getPixel(x, y);
          final r = pixel.r.toInt();
          final g = pixel.g.toInt();
          final b = pixel.b.toInt();
          final a = pixel.a.toInt();

          // Store as ARGB format
          pixels[y * width + x] = (a << 24) | (r << 16) | (g << 8) | b;
        }
      }

      final source = RGBLuminanceSource(width, height, pixels);
      final reader = QRCodeReader();

      // Try with HybridBinarizer first
      try {
        final bitmap = BinaryBitmap(HybridBinarizer(source));
        final result = reader.decode(bitmap);
        print(
          'QR decoded successfully with HybridBinarizer: ${result.text.length} chars',
        );
        return result.text;
      } catch (e) {
        print('HybridBinarizer failed, trying GlobalHistogramBinarizer: $e');
        // Try with GlobalHistogramBinarizer as fallback
        try {
          final bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));
          final result = reader.decode(bitmap);
          print(
            'QR decoded successfully with GlobalHistogramBinarizer: ${result.text.length} chars',
          );
          return result.text;
        } catch (e2) {
          print('Both binarizers failed: $e2');
          throw e2;
        }
      }
    } catch (e, stackTrace) {
      print('QR decode error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
