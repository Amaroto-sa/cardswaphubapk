import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

class AuthService {
  final LocalAuthentication auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();

  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Scan your fingerprint (or face) to authenticate',
        biometricOnly: true,
        persistAcrossBackgrounding: true, // replaces stickyAuth
        // Optionally add authMessages: <AuthMessages>[...] to customize platform dialogs.
      );
      return didAuthenticate;
    } on LocalAuthException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> enableBiometricLogin(bool enable) async {
    await _storage.write(key: AppConfig.keyBiometricEnabled, value: enable.toString());
  }

  Future<bool> isBiometricEnabled() async {
    String? val = await _storage.read(key: AppConfig.keyBiometricEnabled);
    return val == 'true';
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConfig.keyToken);
    await _storage.delete(key: AppConfig.keyUser);
  }
}
