import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<String> platformAssetPath(String asset) async {
  if (Platform.isAndroid) return asset;

  final path = '${(await getApplicationSupportDirectory()).path}/$asset';
  final file = File(path);

  await Directory(dirname(path)).create(recursive: true);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
  }

  return file.path;
}

String dirname(String path) {
  final file = path.split("/").last;
  return path.replaceFirst('/$file', '');
}
