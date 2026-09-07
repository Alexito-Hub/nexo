# ============================================================================
#  build_installer.ps1 - Compila el stub autoextraible de Nexo y le adjunta
#  la app como overlay, produciendo un instalador .exe de un solo archivo.
#
#  100% con TU toolchain (cl.exe de Visual Studio) - sin Inno, sin warp, sin
#  descargar nada. La app (build Release) se comprime a payload.zip y se pega
#  al final del stub; el stub la extrae con el tar.exe de Windows y lanza tu
#  SetupWizard.
#
#  (Archivo en ASCII a proposito: PowerShell 5.1 lee .ps1 sin BOM como ANSI y
#   los acentos rompen el parser. Los textos con acentos van en main.cpp.)
#
#  Uso:
#    installer\build_installer.ps1 -ReleaseDir <...\Release> -OutFile <...\nexo-vX-setup-x64.exe>
# ============================================================================
param(
  [Parameter(Mandatory)][string]$ReleaseDir,
  [Parameter(Mandatory)][string]$OutFile,
  [string]$WorkDir = (Join-Path $env:TEMP ("nexo_setup_" + [Guid]::NewGuid().ToString('N')))
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainCpp = Join-Path $here 'main.cpp'
if (-not (Test-Path $mainCpp)) { throw "No se encontro main.cpp en $here" }
if (-not (Test-Path $ReleaseDir)) { throw "ReleaseDir no existe: $ReleaseDir" }

# --- 1) Localizar vcvars64.bat (toolchain MSVC de Visual Studio) -------------
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) {
  throw "No se encontro vswhere.exe. Instala Visual Studio con 'Desktop development with C++'."
}
$vsPath = & $vswhere -latest -products * `
  -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
  -property installationPath
if (-not $vsPath) { $vsPath = (& $vswhere -latest -property installationPath) }
$vcvars = Join-Path $vsPath 'VC\Auxiliary\Build\vcvars64.bat'
if (-not (Test-Path $vcvars)) { throw "No se encontro vcvars64.bat en $vsPath" }

New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null
$stubExe = Join-Path $WorkDir 'nexo_setup_stub.exe'

# --- 2) Compilar el stub (subsistema GUI = sin ventana de consola) -----------
#     /utf-8 => cl interpreta main.cpp como UTF-8 (textos en espanol correctos).
$bat = Join-Path $WorkDir 'compile.bat'
$log = Join-Path $WorkDir 'build.log'
# Toda la salida se redirige DENTRO del .bat (redireccion de cmd), para evitar
# el gotcha de PowerShell 5.1 que convierte el stderr nativo en error fatal.
@"
@echo off
call "$vcvars" >nul 2>nul
cd /d "$WorkDir"
cl /nologo /O2 /EHsc /utf-8 /DUNICODE /D_UNICODE "$mainCpp" /Fe:"$stubExe" /link /SUBSYSTEM:WINDOWS shell32.lib ole32.lib user32.lib gdi32.lib >build.log 2>&1
"@ | Set-Content -Encoding ascii $bat

& cmd /c "`"$bat`"" | Out-Null
if (-not (Test-Path $stubExe)) {
  if (Test-Path $log) { Write-Host (Get-Content -Raw $log) }
  throw "Fallo la compilacion del stub (cl.exe)."
}

# --- 3) Comprimir el build Release a payload.zip -----------------------------
$payloadZip = Join-Path $WorkDir 'payload.zip'
Compress-Archive -Path (Join-Path $ReleaseDir '*') -DestinationPath $payloadZip -Force

# --- 4) Overlay: stub + payload.zip + [uint64 zipLen (LE)] + "NEXOZIP1" -------
$stubBytes = [System.IO.File]::ReadAllBytes($stubExe)
$zipBytes = [System.IO.File]::ReadAllBytes($payloadZip)
$lenBytes = [System.BitConverter]::GetBytes([UInt64]$zipBytes.LongLength)  # LE en x64
$magic = [System.Text.Encoding]::ASCII.GetBytes('NEXOZIP1')

$outDir = Split-Path -Parent $OutFile
if ($outDir) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
$fs = [System.IO.File]::Open($OutFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
try {
  $fs.Write($stubBytes, 0, $stubBytes.Length)
  $fs.Write($zipBytes, 0, $zipBytes.Length)
  $fs.Write($lenBytes, 0, 8)
  $fs.Write($magic, 0, 8)
} finally { $fs.Dispose() }

# --- 5) Limpieza -------------------------------------------------------------
Remove-Item $WorkDir -Recurse -Force -ErrorAction SilentlyContinue

$mb = [math]::Round((Get-Item $OutFile).Length / 1MB, 1)
Write-Host "OK: $OutFile ($mb MB)"
