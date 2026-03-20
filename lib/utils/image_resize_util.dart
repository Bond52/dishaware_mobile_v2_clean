import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Redimensionne une image (JPEG/PNG) pour limiter la taille envoyée au backend.
List<int> resizeImageBytesToJpeg(
  List<int> bytes, {
  int maxWidth = 800,
  int quality = 85,
}) {
  final decoded = img.decodeImage(Uint8List.fromList(bytes));
  if (decoded == null) {
    throw FormatException('Image invalide ou format non supporté');
  }
  final img.Image resized = decoded.width > maxWidth
      ? img.copyResize(decoded, width: maxWidth)
      : decoded;
  return img.encodeJpg(resized, quality: quality);
}
