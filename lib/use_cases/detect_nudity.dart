import 'i_use_case.dart';

class DetectNudity with IUseCase<bool, String> {
  @override
  Future<bool> execute({required String params}) async {
    return false;
  }
}
