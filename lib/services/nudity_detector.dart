import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

const double threshold = 0.7;

enum NudityInImageCheckResult {
  nudity,
  safe,
  noLabelFound,
  openImageFileError,
  assetPathError,
  pluginInternalError,
}

Future<NudityInImageCheckResult> useNudityDetectModelOnImage({
  required String imagePath,
  required String modelPath,
}) async {
  late final InputImage image;
  late final String assetPath;

  try {
    assetPath = await platformAssetPath(modelPath);
  } catch (e) {
    debugPrint(e.toString());
    return NudityInImageCheckResult.assetPathError;
  }

  try {
    image = InputImage.fromFilePath(imagePath);
  } catch (e) {
    debugPrint(e.toString());
    return NudityInImageCheckResult.openImageFileError;
  }

  try {
    final imageLabels = await ImageLabeler(
      options: LocalLabelerOptions(
        modelPath: assetPath,
        confidenceThreshold: threshold,
      ),
    ).processImage(image);

    if (imageLabels.isEmpty) {
      return NudityInImageCheckResult.noLabelFound;
    }

    /// 0 is safe
    /// 1 is nudity of any body part in the list
    /// https://github.com/notAI-tech/NudeNet
    final foundBodyParts = imageLabels.where((label) => label.index == 1 && label.confidence >= threshold);
    if (foundBodyParts.isNotEmpty) {
      return NudityInImageCheckResult.nudity;
    }

    return NudityInImageCheckResult.safe;
  } catch (e) {
    debugPrint(e.toString());
  }

  return NudityInImageCheckResult.pluginInternalError;
}

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
