import 'package:contorno/features/auth/domain/services/crp_validator_service.dart';

class MockCrpValidatorServiceImpl implements ICrpValidatorService {
  @override
  Future<bool> validarCrp(String crp) async {
    await Future.delayed(const Duration(seconds: 1));
    return crp.trim().isNotEmpty;
  }
}
