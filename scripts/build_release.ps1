# build_release.ps1 — Pipeline completo de release de Nexo
#
# Flujo automatizado:
#   1. Lee versión de pubspec.yaml (fuente de verdad)
#   2. Valida estado del repo (sin cambios uncommitted, tag no duplicado)
#   3. Sincroniza config.dart con la versión del pubspec
#   4. Compila artefactos (APK universal, APKs split, Windows)
#   5. Genera SHA256SUMS.txt y release-meta.json
#   6. Genera RELEASE_NOTES.md desde CHANGELOG.md
#   7. Crea tag Git, publica el release en GitHub con los artefactos
#   8. (Opcional) Actualiza el sitio web nexo-releases
#
# Nombres de artefactos (convención del auto-updater):
#   nexo-v<version>-universal.apk     ← preferido por el updater
#   nexo-v<version>-arm64.apk
#   nexo-v<version>-armv7.apk
#   nexo-v<version>-x86_64.apk
#   nexo-v<version>-windows-x64.zip
#   nexo-v<version>-setup-x64.exe     ← instalador de un solo archivo (stub propio)
#   SHA256SUMS.txt
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File scripts\build_release.ps1
#   ... -Publish          # además crea tag, release en GitHub y sube artefactos
#   ... -SkipWindows      # omitir build de Windows
#   ... -SkipSetup        # omitir el instalador .exe de un solo archivo (solo ZIP)
#   ... -SkipSplit        # omitir APKs por ABI
#   ... -SkipBuild        # omitir compilación (usar artefactos ya existentes en dist/)
#   ... -UpdateSite       # actualizar nexo-releases después de publicar
#   ... -DryRun           # mostrar lo que se haría sin ejecutar nada
#
# Requisitos:
#   - Flutter SDK en el PATH
#   - GitHub CLI (`winget install GitHub.cli` + `gh auth login`) para -Publish
#   - Git configurado con push access al repo

param(
  [switch]$Publish,
  [switch]$SkipWindows,
  [switch]$SkipSetup,
  [switch]$SkipSplit,
  [switch]$SkipBuild,
  [switch]$UpdateSite,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$repo = 'Auralix-Studio/nexo'
$scriptsDir = $PSScriptRoot

# ===============================================================
# PASO 0: Leer versión de pubspec.yaml
# ===============================================================s
$verLine = ([System.IO.File]::ReadAllLines((Join-Path $root 'pubspec.yaml'), [System.Text.Encoding]::UTF8) | Where-Object { $_ -match '^\s*version:\s*(.+)$' })
$rawVer = (($verLine -replace '^\s*version:\s*', '').Split('+')[0]).Trim()
if (-not $rawVer) { throw 'No se pudo leer la version de pubspec.yaml' }

$tag = "v$rawVer"
$title = "Nexo $rawVer"

Write-Host ""
Write-Host "╔==========================================╗" -ForegroundColor Cyan
Write-Host "  NEXO RELEASE PIPELINE - $tag             " -ForegroundColor Cyan
Write-Host "╚==========================================╝" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
  Write-Host "[DRY RUN] No se ejecutaran cambios reales.`n" -ForegroundColor Yellow
}

# ===============================================================
# PASO 1: Validaciones previas
# ===============================================================
Write-Host "[1/8] Validaciones previas..." -ForegroundColor Yellow

# Verificar que Git no tiene cambios sin commitear (excepto dist/)
Push-Location $root
try {
  $dirty = git status --porcelain -- ':!dist/' 2>$null
  if ($dirty -and -not $DryRun) {
    Write-Host "`n  Archivos sin commitear:" -ForegroundColor Red
    $dirty | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    Write-Host ""
    throw "Hay cambios sin commitear. Commitea o stashea antes de hacer release."
  }
  if ($dirty) {
    Write-Host "  (advertencia: hay cambios sin commitear, ignorado por DryRun)" -ForegroundColor DarkYellow
  }

  # Verificar que el tag no existe ya
  $existingTag = git tag -l $tag 2>$null
  if ($existingTag -and $Publish) {
    throw "El tag '$tag' ya existe. Bumpea la version primero: scripts\bump_version.ps1 -Type patch"
  }

  Write-Host "  Version : $rawVer" -ForegroundColor Green
  Write-Host "  Tag     : $tag" -ForegroundColor Green
  Write-Host "  Repo    : $repo" -ForegroundColor Green
} finally {
  Pop-Location
}

# ===============================================================
# PASO 2: Sincronizar config.dart
# ===============================================================
Write-Host "`n[2/8] Sincronizando config.dart..." -ForegroundColor Yellow

if (-not $DryRun) {
  & (Join-Path $scriptsDir 'sync_version.ps1')
} else {
  Write-Host "  (dry run) Se sincronizaría config.dart con versión $rawVer" -ForegroundColor DarkGray
}

# ===============================================================
# PASO 3: Preparar directorio dist/
# ===============================================================
$dist = Join-Path $root 'dist'
if (-not $SkipBuild) {
  if (Test-Path $dist) { Remove-Item "$dist\*" -Force -Recurse -ErrorAction SilentlyContinue }
}
New-Item -ItemType Directory -Force -Path $dist | Out-Null

function Copy-Artifact($src, $name) {
  $fullSrc = Join-Path $root $src
  if (Test-Path $fullSrc) {
    Copy-Item $fullSrc (Join-Path $dist $name) -Force
    $sizeMB = [math]::Round((Get-Item (Join-Path $dist $name)).Length / 1MB, 1)
    Write-Host "  + $name ($sizeMB MB)" -ForegroundColor Green
  } else {
    Write-Host "  (omitido: no existe $src)" -ForegroundColor DarkGray
  }
}

# ===============================================================
# PASO 4: Compilar artefactos
# ===============================================================
if (-not $SkipBuild) {
  Push-Location $root
  try {
    # 4a) APK universal
    Write-Host "`n[3/8] Compilando APK universal..." -ForegroundColor Yellow
    if (-not $DryRun) {
      flutter build apk --release
      if ($LASTEXITCODE -ne 0) { throw 'flutter build apk fallo' }
      Copy-Artifact 'build/app/outputs/flutter-apk/app-release.apk' "nexo-$tag-universal.apk"
    } else {
      Write-Host "  (dry run) flutter build apk --release" -ForegroundColor DarkGray
    }

    # 4b) APKs por ABI
    if (-not $SkipSplit) {
      Write-Host "`n[4/8] Compilando APKs por ABI..." -ForegroundColor Yellow
      if (-not $DryRun) {
        flutter build apk --split-per-abi --release
        if ($LASTEXITCODE -ne 0) { throw 'flutter build apk --split-per-abi fallo' }
        Copy-Artifact 'build/app/outputs/flutter-apk/app-arm64-v8a-release.apk'   "nexo-$tag-arm64.apk"
        Copy-Artifact 'build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk' "nexo-$tag-armv7.apk"
        Copy-Artifact 'build/app/outputs/flutter-apk/app-x86_64-release.apk'      "nexo-$tag-x86_64.apk"
      } else {
        Write-Host "  (dry run) flutter build apk --split-per-abi --release" -ForegroundColor DarkGray
      }
    } else {
      Write-Host "`n[4/8] APKs por ABI - omitido (SkipSplit)" -ForegroundColor DarkGray
    }

    # 4c) Windows
    if (-not $SkipWindows) {
      Write-Host "`n[5/8] Compilando Windows..." -ForegroundColor Yellow
      if (-not $DryRun) {
        flutter build windows --release
        if ($LASTEXITCODE -ne 0) { throw 'flutter build windows fallo' }
        $winDir = $null
        foreach ($cand in 'build/windows/x64/runner/Release', 'build/windows/runner/Release') {
          if (Test-Path (Join-Path $root $cand)) { $winDir = Join-Path $root $cand; break }
        }
        if ($winDir) {
          $zip = Join-Path $dist "nexo-$tag-windows-x64.zip"
          Compress-Archive -Path "$winDir/*" -DestinationPath $zip -Force
          $sizeMB = [math]::Round((Get-Item $zip).Length / 1MB, 1)
          Write-Host "  + nexo-$tag-windows-x64.zip ($sizeMB MB)" -ForegroundColor Green

          # El ZIP de arriba NO usa nada externo: se extrae y nexo.exe muestra
          # tu asistente interno (SetupWizard en lib/features/settings/).
          # Preserva el diseño al 100%.
          #
          # Además generamos un instalador .exe de UN SOLO ARCHIVO (estilo
          # Discord) con TU propio stub nativo (installer/). Al doble clic
          # extrae la app con el tar.exe de Windows a %LOCALAPPDATA%\Nexo\_stage
          # y lanza nexo.exe → aparece TU mismo SetupWizard. Sin Inno, sin warp.
          # Usa -SkipSetup para omitirlo.
          #
          # (warp se eliminó: su stub sin firmar + el header PE parcheado lo
          #  ponían en cuarentena el antivirus — ese era el "bloqueo". Este stub
          #  NO parchea el binario: el payload va como overlay al final del .exe,
          #  práctica estándar de todo instalador.)
          if (-not $SkipSetup) {
            $mkInstaller = Join-Path $root 'installer\build_installer.ps1'
            $setupExe = Join-Path $dist "nexo-$tag-setup-x64.exe"
            if (Test-Path $mkInstaller) {
              Write-Host "  Compilando instalador de un solo archivo (stub propio)..." -ForegroundColor DarkGray
              try {
                & $mkInstaller -ReleaseDir ($winDir -replace '/', '\') -OutFile $setupExe
                if (Test-Path $setupExe) {
                  $setupMB = [math]::Round((Get-Item $setupExe).Length / 1MB, 1)
                  Write-Host "  + nexo-$tag-setup-x64.exe ($setupMB MB) - Instalador de un solo archivo" -ForegroundColor Green
                } else {
                  Write-Host "  (No se generó el instalador .exe)" -ForegroundColor DarkYellow
                }
              } catch {
                  Write-Host "  (Fallo al compilar el instalador .exe: $_)" -ForegroundColor DarkYellow
              }
            } else {
              Write-Host "  (installer/build_installer.ps1 no encontrado - omitido el .exe)" -ForegroundColor DarkYellow
            }
          }
        } else {
          Write-Host '  (no se encontró el build de Windows)' -ForegroundColor DarkGray
        }
      } else {
        Write-Host "  (dry run) flutter build windows --release" -ForegroundColor DarkGray
      }
    } else {
      Write-Host "`n[5/8] Windows — omitido (SkipWindows)" -ForegroundColor DarkGray
    }
  } finally {
    Pop-Location
  }
} else {
  Write-Host "`n[3-5/8] Build omitido (-SkipBuild). Usando artefactos existentes en dist/." -ForegroundColor DarkGray
}

# ===============================================================
# PASO 5: Generar SHA256SUMS.txt
# ===============================================================
Write-Host "`n[6/8] Generando SHA256SUMS.txt..." -ForegroundColor Yellow

if (-not $DryRun) {
  $excludeFiles = @('SHA256SUMS.txt', 'RELEASE_NOTES.md', 'release-meta.json')
  $sums = Join-Path $dist 'SHA256SUMS.txt'
  Get-ChildItem $dist -File | Where-Object { $excludeFiles -notcontains $_.Name } | ForEach-Object {
    "{0}  {1}" -f (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLower(), $_.Name
  } | Set-Content -Encoding ascii $sums
  Write-Host "  SHA256SUMS.txt generado." -ForegroundColor Green
} else {
  Write-Host "  (dry run) Se calcularían hashes SHA-256" -ForegroundColor DarkGray
}

# ===============================================================
# PASO 6: Generar release notes
# ===============================================================
Write-Host "`n[7/8] Generando release notes..." -ForegroundColor Yellow

if (-not $DryRun) {
  & (Join-Path $scriptsDir 'generate_release_notes.ps1') -Version $rawVer -DistDir $dist
} else {
  Write-Host "  (dry run) Se generaría RELEASE_NOTES.md desde CHANGELOG.md" -ForegroundColor DarkGray
}

# ===============================================================
# Resumen de artefactos
# ===============================================================
Write-Host "`nArtefactos en dist/:" -ForegroundColor Green
if (-not $DryRun) {
  Get-ChildItem $dist -File |
    Select-Object Name, @{ n = 'MB'; e = { [math]::Round($_.Length / 1MB, 1) } } |
    Format-Table -AutoSize
}

# ===============================================================
# PASO 7: Publicar release en GitHub
# ===============================================================
if ($Publish) {
  Write-Host "[8/8] Publicando release $tag en $repo..." -ForegroundColor Yellow

  if (-not $DryRun) {
    # Verificar gh CLI
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
      throw 'gh (GitHub CLI) no está instalado. Instalarlo con: winget install GitHub.cli ; luego gh auth login'
    }

    # Commit de los cambios de sync (config.dart) si los hay
    Push-Location $root
    try {
      $prevEAP = $ErrorActionPreference; $ErrorActionPreference = 'SilentlyContinue'
      $syncChanges = git diff --name-only 2>$null
      $ErrorActionPreference = $prevEAP
      if ($syncChanges) {
        Write-Host "  Commiteando cambios de sync..." -ForegroundColor DarkGray
        $prevEAP = $ErrorActionPreference; $ErrorActionPreference = 'SilentlyContinue'
        git add -A 2>$null
        git commit -m "chore: release $tag — sync version" 2>$null
        $ErrorActionPreference = $prevEAP
      }

      # Crear tag
      Write-Host "  Creando tag $tag..." -ForegroundColor DarkGray
      git tag -a $tag -m "Release $tag"

      # Push commits + tag
      Write-Host "  Pushing..." -ForegroundColor DarkGray
      $prevEAP = $ErrorActionPreference; $ErrorActionPreference = 'SilentlyContinue'
      git push 2>$null
      git push origin $tag 2>$null
      $ErrorActionPreference = $prevEAP
    } finally {
      Pop-Location
    }

    # Crear release con los artefactos
    $notesFile = Join-Path $dist 'RELEASE_NOTES.md'
    $uploadFiles = @(Get-ChildItem $dist -File |
      Where-Object { $_.Name -ne 'RELEASE_NOTES.md' -and $_.Name -ne 'release-meta.json' } |
      ForEach-Object { $_.FullName })

    $ghArgs = @('release', 'create', $tag) + $uploadFiles +
      @('--repo', $repo, '--title', $title)

    if (Test-Path $notesFile) {
      $ghArgs += @('--notes-file', $notesFile)
    } else {
      $ghArgs += @('--generate-notes')
    }

    gh @ghArgs
    if ($LASTEXITCODE -ne 0) { throw 'gh release create fallo' }

    Write-Host "`n  Release $tag publicado exitosamente." -ForegroundColor Green
    Write-Host "  https://github.com/$repo/releases/tag/$tag" -ForegroundColor Cyan
  } else {
    Write-Host "  (dry run) Se crearia tag $tag, push, y gh release create" -ForegroundColor DarkGray
  }

  # --- Actualizar sitio web ---
  if ($UpdateSite) {
    $siteScript = Join-Path $scriptsDir 'update_site.ps1'
    if (Test-Path $siteScript) {
      Write-Host "`n[Bonus] Actualizando sitio web nexo-releases..." -ForegroundColor Yellow
      if (-not $DryRun) {
        & $siteScript -MetaFile (Join-Path $dist 'release-meta.json')
      } else {
        Write-Host "  (dry run) Se actualizarian downloads.html y changelog.html" -ForegroundColor DarkGray
      }
    } else {
      Write-Host "  (update_site.ps1 no encontrado - omitido)" -ForegroundColor DarkGray
    }
  }
} else {
  Write-Host "[8/8] Publicacion omitida (sin -Publish)." -ForegroundColor DarkGray
  Write-Host "`nPara publicar:" -ForegroundColor Cyan
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\build_release.ps1 -Publish -SkipBuild" -ForegroundColor White
  Write-Host "  (usa -SkipBuild para reusar los artefactos de dist/)" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Release pipeline completado: $tag" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
