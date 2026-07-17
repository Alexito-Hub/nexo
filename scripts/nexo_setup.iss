; ============================================================================
;  nexo_setup.iss — Instalador Inno Setup para Nexo UPLA  (TEMPORAL / OPCIONAL)
; ============================================================================
;  Genera:  nexo-v<version>-setup-x64.exe
;
;  Este .exe es una ALTERNATIVA temporal al ZIP. Instala per-user (sin admin)
;  en %LOCALAPPDATA%\Nexo\bin — EXACTAMENTE la ruta que WinSetupService espera
;  como "instalación oficial" (officialExePath). Gracias a eso, al abrir la app
;  instalada `isInstalledInstance` es true y el asistente interno NO se muestra:
;  el .exe de Inno y el ZIP + asistente conviven sin chocar.
;
;  El ZIP (nexo-v<version>-windows-x64.zip) se sigue generando SIN Inno: se
;  extrae y `nexo.exe` muestra el asistente interno (Instalar / Portable).
;
;  Requisitos: Inno Setup 6 (ISCC.exe). Sin certificado de firma, SmartScreen
;  puede advertir en el primer arranque (igual que con el ZIP) — pero, a
;  diferencia del viejo warp-packer, el stub de Inno NO lo borra el antivirus.
;
;  Defines que inyecta scripts/build_release.ps1 (o manualmente):
;    MyAppVersion → versión numérica (p.ej. 1.5.0)
;    SourceDir    → carpeta Release del build de Flutter (contiene nexo.exe)
;    OutputDir    → carpeta dist donde se escribe el .exe
;
;  Compilación manual de ejemplo:
;    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" ^
;      "/DMyAppVersion=1.5.0" ^
;      "/DSourceDir=C:\...\build\windows\x64\runner\Release" ^
;      "/DOutputDir=C:\...\dist" ^
;      scripts\nexo_setup.iss
; ============================================================================

#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\dist"
#endif

#define MyAppName "Nexo UPLA"
#define MyAppExeName "nexo.exe"
#define MyAppPublisher "Nexo Team"

[Setup]
; AppId ESTABLE — no cambiarlo entre versiones (identifica upgrades/uninstall).
AppId={{A7E4C9B2-3F81-4D6A-B2E5-9C8D1F0A6B34}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
; Instalación per-user en LocalAppData\Nexo → officialExePath = {app}\bin\nexo.exe
DefaultDirName={localappdata}\Nexo
PrivilegesRequired=lowest
DisableProgramGroupPage=yes
DisableDirPage=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Windows 10 1809+ (mismo requisito documentado para el ZIP).
MinVersion=10.0.17763
OutputDir={#OutputDir}
OutputBaseFilename=nexo-v{#MyAppVersion}-setup-x64
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\bin\{#MyAppExeName}
SetupIconFile=..\windows\runner\resources\app_icon.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
; Cierra Nexo si está abierto durante una actualización, para poder reemplazar.
CloseApplications=yes

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Empaqueta TODO el build Release dentro de {app}\bin (nexo.exe, dlls, data\...).
Source: "{#SourceDir}\*"; DestDir: "{app}\bin"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\bin\{#MyAppExeName}"; WorkingDir: "{app}\bin"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\bin\{#MyAppExeName}"; WorkingDir: "{app}\bin"; Tasks: desktopicon

[Run]
Filename: "{app}\bin\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; WorkingDir: "{app}\bin"; Flags: nowait postinstall skipifsilent
