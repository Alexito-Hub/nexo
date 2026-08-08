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

/// Build empaquetada para la Microsoft Store.
///
/// La Store gestiona la instalación y las actualizaciones: una app empaquetada
/// que se auto-instala o se actualiza sola viola sus políticas. Con este flag
/// (`--dart-define=STORE_BUILD=true`) se desactivan el asistente de instalación
/// (`WinSetupService`/`InstallView`) y el auto-actualizador (`UpdateService`).
class StoreBuild {
  static const bool isStore = bool.fromEnvironment('STORE_BUILD');
}

class AppConfig {
  static const String appVersion = '1.6.2';
  static const int appBuild = 11;
  static const String apiBaseUrl = 'https://sigma.upla.edu.pe/api';
  static const String nomSys = 'SIGMA';
  static const Duration httpTimeout = Duration(seconds: 30);
  static const String userAgent =
      'Nexo-UPLA/$appVersion (Flutter; multiplatform)';
  static const String tipDI = '12';
  static String photoUrlFor(String code) =>
      'https://academico.upla.edu.pe/FotosAlum/037000$code.jpg';
}

class MsConfig {
  static const String clientId = 'TODO_AZURE_CLIENT_ID';
  static const String tenant = 'organizations';
  static String get _authority =>
      'https://login.microsoftonline.com/$tenant/oauth2/v2.0';
  static String get deviceCodeUrl => '$_authority/devicecode';
  static String get tokenUrl => '$_authority/token';
  static const String graphBaseUrl = 'https://graph.microsoft.com/v1.0';
  static const List<String> scopes = [
    'offline_access',
    'openid',
    'profile',
    'User.Read',
    'EduRoster.ReadBasic',
    'EduAssignments.ReadBasic',
  ];
  static String get scopeParam => scopes.join(' ');
  static bool get isConfigured => clientId != 'TODO_AZURE_CLIENT_ID';
}
