import 'i_use_case.dart';
import '/services/nudity_detector.dart';

class DetectNudity with IUseCase<bool, String> {
  const DetectNudity();

  @override
  Future<bool> execute({required String params}) async {
    final result = await useNudityDetectModelOnImage(
      imagePath: params,
      modelPath: 'ml/nudity_finder.tflite',
    );

    if (result == NudityInImageCheckResult.nudity) {
      return true;
    }
    return false;
  }
}
