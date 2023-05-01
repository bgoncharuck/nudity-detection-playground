import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

const double thresholdForMales = 0.4335938;
const double thresholdForFemales = 0.6;

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
  bool isFemale = true,
}) async {
  late final InputImage image;
  late final String assetPath;
  final threshold = isFemale ? thresholdForFemales : thresholdForMales;

  try {
    assetPath = await assetToFile(modelPath);
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

  final imageLabeler = ImageLabeler(
    options: LocalLabelerOptions(
      modelPath: assetPath,
      confidenceThreshold: threshold,
    ),
  );

  try {
    final imageLabels = await imageLabeler.processImage(image);
    imageLabeler.close();

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
    imageLabeler.close();
  }

  return NudityInImageCheckResult.pluginInternalError;
}

Future<String> assetToFile(String asset) async {
  if (Platform.isAndroid) {
    return 'flutter_assets/$asset';
  }
  final path = '${(await getApplicationSupportDirectory()).path}/$asset';
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}

String dirname(String path) {
  final file = path.split("/").last;
  return path.replaceFirst('/$file', '');
}
