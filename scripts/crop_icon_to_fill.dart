// Script pour recadrer app_icon.png : supprime les bords blancs et redimensionne
// pour que la boussole remplisse tout l'espace de l'icône.
// Usage: dart run scripts/crop_icon_to_fill.dart

import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final projectRoot = scriptDir.parent;
  final iconPath = projectRoot.path + Platform.pathSeparator + 'assets' + Platform.pathSeparator + 'images' + Platform.pathSeparator + 'app_icon.png';

  final file = File(iconPath);
  if (!file.existsSync()) {
    print('Fichier introuvable: $iconPath');
    exit(1);
  }

  final bytes = file.readAsBytesSync();
  img.Image? image = img.decodeImage(bytes);
  if (image == null) {
    print('Impossible de décoder l\'image.');
    exit(1);
  }

  // Seuil pour considérer un pixel comme "fond" (blanc ou quasi blanc)
  const threshold = 250;
  bool isBackground(int r, int g, int b, int a) {
    if (a < 128) return true;
    return r >= threshold && g >= threshold && b >= threshold;
  }

  int xMin = image.width, xMax = 0, yMin = image.height, yMax = 0;
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r.toInt(), g = pixel.g.toInt(), b = pixel.b.toInt(), a = pixel.a.toInt();
      if (!isBackground(r, g, b, a)) {
        if (x < xMin) xMin = x;
        if (x > xMax) xMax = x;
        if (y < yMin) yMin = y;
        if (y > yMax) yMax = y;
      }
    }
  }

  if (xMin > xMax || yMin > yMax) {
    print('Aucun contenu détecté (image vide ou entièrement blanche).');
    exit(1);
  }

  // Marge minimale (2% de la plus grande dimension du contenu)
  final contentWidth = xMax - xMin + 1;
  final contentHeight = yMax - yMin + 1;
  final margin = ((contentWidth > contentHeight ? contentWidth : contentHeight) * 0.02).round().clamp(5, 80);
  xMin = (xMin - margin).clamp(0, image.width - 1);
  yMin = (yMin - margin).clamp(0, image.height - 1);
  xMax = (xMax + margin).clamp(0, image.width - 1);
  yMax = (yMax + margin).clamp(0, image.height - 1);

  final cropWidth = xMax - xMin + 1;
  final cropHeight = yMax - yMin + 1;
  final side = cropWidth > cropHeight ? cropWidth : cropHeight;

  img.Image cropped = img.copyCrop(image, x: xMin, y: yMin, width: cropWidth, height: cropHeight);
  if (cropWidth != side || cropHeight != side) {
    final padded = img.Image(width: side, height: side);
    img.fill(padded, color: img.ColorRgba8(255, 255, 255, 255));
    final dx = ((side - cropWidth) / 2).round();
    final dy = ((side - cropHeight) / 2).round();
    img.compositeImage(padded, cropped, dstX: dx, dstY: dy);
    cropped = padded;
  }

  final resized = img.copyResize(cropped, width: 1024, height: 1024);
  final pngBytes = img.encodePng(resized);
  if (pngBytes == null) {
    print('Échec de l\'encodage PNG.');
    exit(1);
  }
  file.writeAsBytesSync(pngBytes);
  print('Icône recadrée et redimensionnée (1024x1024) : $iconPath');
  print('Relancez : dart run flutter_launcher_icons');
}
