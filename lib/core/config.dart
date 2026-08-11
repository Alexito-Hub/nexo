class UpdateConfig {
  static const String repo = 'auralix-studio/nexo';
  static const String latestReleaseApi =
      'https://api.github.com/repos/$repo/releases/latest';
  static bool isApkAsset(String name) => name.toLowerCase().endsWith('.apk');
  static bool isWindowsAsset(String name) {
    final n = name.toLowerCase();
    return n.endsWith('.exe') || n.endsWith('.msix') || n.endsWith('.zip');
  }

  static bool isUniversalApk(String name) =>
      isApkAsset(name) && name.toLowerCase().contains('universal');
  static const Duration checkInterval = Duration(hours: 24);
}

class StoreBuild {
  static const bool isStore = bool.fromEnvironment('STORE_BUILD');
}

class AppConfig {
  static const String appVersion = '1.6.4';
  static const int appBuild = 13;
  static const String apiBaseUrl = 'https://sigma.upla.edu.pe/api';
  static const String nomSys = 'SIGMA';
  static const Duration httpTimeout = Duration(seconds: 30);
  static const String userAgent =
      'Nexo-UPLA/$appVersion (Flutter; multiplatform)';
  static const String tipDI = '12';
  static String photoUrlFor(String code) =>
      'https://academico.upla.edu.pe/FotosAlum/037000$code.jpg';
}

class LegalTerms {
  static const int version = 3;
  static final DateTime updatedAt = DateTime(2026, 8, 10);
}
