import 'i_use_case.dart';
import '/services/nudity_detector.dart';

class DetectNudityParams {
  const DetectNudityParams({required this.imagePath, required this.isFemale});
  final String imagePath;
  final bool isFemale;
}

class DetectNudity with IUseCase<bool, DetectNudityParams> {
  const DetectNudity();

  @override
  Future<bool> execute({required DetectNudityParams params}) async {
    final result = await useNudityDetectModelOnImage(
      imagePath: params.imagePath,
      modelPath: 'assets/ml/nudity_finder.tflite',
      isFemale: params.isFemale,
    );

    if (result == NudityInImageCheckResult.nudity) {
      return true;
    }
    return false;
  }
}
