import 'i_use_case.dart';
import '/services/nudity_detector.dart';

class DetectNudity with IUseCase<bool, String> {
  @override
  Future<bool> execute({required String params}) async {
    final result = await useNudityDetectModelOnImage(
      imagePath: params,
      modelPath: 'assets/ml_models/nudity_founder.tflite',
    );

    if (result == NudityInImageCheckResult.nudity) {
      return true;
    }
    return false;
  }
}
