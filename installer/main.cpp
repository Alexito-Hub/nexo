// ============================================================================
//  Nexo UPLA — Stub autoextraíble (bootstrapper estilo Discord), 100% propio.
// ============================================================================
//  Un solo .exe: al doble clic extrae la app y lanza nexo.exe, que muestra TU
//  SetupWizard (Instalar / Portable). No usa Inno ni warp.
//
//  Cómo lleva la app dentro (overlay):
//    [ stub.exe | payload.zip | uint64 zipLen (LE) | "NEXOZIP1" ]
//  El footer son los últimos 16 bytes. Añadir datos AL FINAL del .exe es la
//  práctica estándar de NSIS/Inno/InstallShield — no toca el PE, así que NO
//  dispara la heurística de "binario modificado" que puso a warp en cuarentena.
//
//  Extracción: usa tar.exe (bsdtar, firmado por Microsoft, incluido en
//  Windows 10 1809+) hacia %LOCALAPPDATA%\Nexo\_stage — nunca %TEMP%, para no
//  parecer un "dropper". Luego lanza %LOCALAPPDATA%\Nexo\_stage\nexo.exe.
//
//  Compilación: installer\build_installer.ps1 (usa cl.exe de tu VS).
//  Subsistema GUI vía /SUBSYSTEM:WINDOWS (forma legítima, no parcheando bytes).
// ============================================================================

#ifndef UNICODE
#define UNICODE
#endif
#include <windows.h>
#include <shlobj.h>
#include <objbase.h>
#include <string>
#include <vector>

static const char kMagic[8] = {'N', 'E', 'X', 'O', 'Z', 'I', 'P', '1'};

// --- utilidades -------------------------------------------------------------

static std::wstring SelfPath() {
  std::wstring buf(MAX_PATH, L'\0');
  DWORD n = GetModuleFileNameW(nullptr, &buf[0], (DWORD)buf.size());
  buf.resize(n);
  return buf;
}

static std::wstring LocalAppData() {
  PWSTR p = nullptr;
  std::wstring out;
  if (SUCCEEDED(SHGetKnownFolderPath(FOLDERID_LocalAppData, 0, nullptr, &p))) {
    out = p;
  }
  if (p) CoTaskMemFree(p);
  return out;
}

static std::wstring SystemTar() {
  std::wstring dir(MAX_PATH, L'\0');
  UINT n = GetSystemDirectoryW(&dir[0], (UINT)dir.size());
  dir.resize(n);
  return dir + L"\\tar.exe";
}

static void Fatal(const std::wstring& msg) {
  MessageBoxW(nullptr, msg.c_str(), L"Nexo UPLA — Instalador",
              MB_ICONERROR | MB_OK);
}

// Ejecuta un proceso oculto y espera; devuelve el exit code (o -1 si falla).
static int RunHiddenWait(const std::wstring& cmdLine) {
  std::wstring mutableCmd = cmdLine;  // CreateProcessW puede modificar el buffer
  STARTUPINFOW si{};
  si.cb = sizeof(si);
  si.dwFlags = STARTF_USESHOWWINDOW;
  si.wShowWindow = SW_HIDE;
  PROCESS_INFORMATION pi{};
  if (!CreateProcessW(nullptr, &mutableCmd[0], nullptr, nullptr, FALSE,
                      CREATE_NO_WINDOW, nullptr, nullptr, &si, &pi)) {
    return -1;
  }
  WaitForSingleObject(pi.hProcess, INFINITE);
  DWORD code = 1;
  GetExitCodeProcess(pi.hProcess, &code);
  CloseHandle(pi.hThread);
  CloseHandle(pi.hProcess);
  return (int)code;
}

static bool LaunchDetached(const std::wstring& exePath,
                           const std::wstring& workDir) {
  std::wstring cmd = L"\"" + exePath + L"\"";
  STARTUPINFOW si{};
  si.cb = sizeof(si);
  PROCESS_INFORMATION pi{};
  if (!CreateProcessW(nullptr, &cmd[0], nullptr, nullptr, FALSE, 0, nullptr,
                      workDir.c_str(), &si, &pi)) {
    return false;
  }
  CloseHandle(pi.hThread);
  CloseHandle(pi.hProcess);
  return true;
}

// Lee el overlay (payload.zip) desde el final del propio .exe y lo escribe en
// destZip. Devuelve false si el footer no es válido.
static bool ExtractOverlayToFile(const std::wstring& destZip) {
  HANDLE h = CreateFileW(SelfPath().c_str(), GENERIC_READ, FILE_SHARE_READ,
                         nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (h == INVALID_HANDLE_VALUE) return false;

  LARGE_INTEGER size{};
  if (!GetFileSizeEx(h, &size) || size.QuadPart < 16) {
    CloseHandle(h);
    return false;
  }

  // Footer: [uint64 zipLen (8, LE)] [magic (8)]
  unsigned char footer[16];
  LARGE_INTEGER pos;
  pos.QuadPart = size.QuadPart - 16;
  SetFilePointerEx(h, pos, nullptr, FILE_BEGIN);
  DWORD got = 0;
  if (!ReadFile(h, footer, 16, &got, nullptr) || got != 16) {
    CloseHandle(h);
    return false;
  }
  if (memcmp(footer + 8, kMagic, 8) != 0) {
    CloseHandle(h);
    return false;
  }
  unsigned long long zipLen = 0;
  memcpy(&zipLen, footer, 8);  // little-endian nativo
  if (zipLen == 0 ||
      (long long)(zipLen + 16) > size.QuadPart) {
    CloseHandle(h);
    return false;
  }

  LARGE_INTEGER start;
  start.QuadPart = size.QuadPart - 16 - (long long)zipLen;
  SetFilePointerEx(h, start, nullptr, FILE_BEGIN);

  HANDLE out = CreateFileW(destZip.c_str(), GENERIC_WRITE, 0, nullptr,
                           CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (out == INVALID_HANDLE_VALUE) {
    CloseHandle(h);
    return false;
  }

  std::vector<unsigned char> chunk(1 << 20);  // 1 MB
  unsigned long long remaining = zipLen;
  bool ok = true;
  while (remaining > 0) {
    DWORD want = (DWORD)((remaining < chunk.size()) ? remaining : chunk.size());
    DWORD read = 0;
    if (!ReadFile(h, chunk.data(), want, &read, nullptr) || read == 0) {
      ok = false;
      break;
    }
    DWORD wrote = 0;
    if (!WriteFile(out, chunk.data(), read, &wrote, nullptr) || wrote != read) {
      ok = false;
      break;
    }
    remaining -= read;
  }
  CloseHandle(out);
  CloseHandle(h);
  return ok;
}

// --- splash mínima ("Preparando Nexo UPLA…") --------------------------------

static LRESULT CALLBACK SplashProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
  if (msg == WM_PAINT) {
    PAINTSTRUCT ps;
    HDC hdc = BeginPaint(hwnd, &ps);
    RECT rc;
    GetClientRect(hwnd, &rc);
    HBRUSH bg = CreateSolidBrush(RGB(0x0E, 0x0F, 0x1A));  // fondo oscuro Nexo
    FillRect(hdc, &rc, bg);
    DeleteObject(bg);
    SetBkMode(hdc, TRANSPARENT);
    SetTextColor(hdc, RGB(0xE8, 0xEA, 0xF2));
    HFONT font = CreateFontW(-20, 0, 0, 0, FW_SEMIBOLD, FALSE, FALSE, FALSE,
                             DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
                             CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY,
                             DEFAULT_PITCH | FF_DONTCARE, L"Segoe UI");
    HGDIOBJ old = SelectObject(hdc, font);
    DrawTextW(hdc, L"Preparando Nexo UPLA…", -1, &rc,
              DT_CENTER | DT_VCENTER | DT_SINGLELINE);
    SelectObject(hdc, old);
    DeleteObject(font);
    EndPaint(hwnd, &ps);
    return 0;
  }
  return DefWindowProcW(hwnd, msg, wp, lp);
}

static HWND ShowSplash(HINSTANCE hInst) {
  WNDCLASSW wc{};
  wc.lpfnWndProc = SplashProc;
  wc.hInstance = hInst;
  wc.hCursor = LoadCursor(nullptr, IDC_APPSTARTING);
  wc.lpszClassName = L"NexoSetupSplash";
  RegisterClassW(&wc);

  const int w = 380, h = 130;
  int sx = GetSystemMetrics(SM_CXSCREEN), sy = GetSystemMetrics(SM_CYSCREEN);
  HWND hwnd = CreateWindowExW(
      WS_EX_TOPMOST | WS_EX_TOOLWINDOW, wc.lpszClassName, L"Nexo UPLA",
      WS_POPUP | WS_BORDER, (sx - w) / 2, (sy - h) / 2, w, h, nullptr, nullptr,
      hInst, nullptr);
  if (hwnd) {
    ShowWindow(hwnd, SW_SHOW);
    UpdateWindow(hwnd);
  }
  return hwnd;
}

// --- entry point ------------------------------------------------------------

int WINAPI wWinMain(HINSTANCE hInst, HINSTANCE, LPWSTR, int) {
  CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  const std::wstring lad = LocalAppData();
  if (lad.empty()) {
    Fatal(L"No se pudo determinar la carpeta de datos del usuario.");
    return 1;
  }
  const std::wstring stage = lad + L"\\Nexo\\_stage";
  const std::wstring zipPath = stage + L"\\payload.zip";
  const std::wstring exePath = stage + L"\\nexo.exe";

  HWND splash = ShowSplash(hInst);

  // 1) Preparar carpeta de staging limpia.
  SHCreateDirectoryExW(nullptr, stage.c_str(), nullptr);

  // 2) Extraer el overlay (payload.zip) del propio .exe.
  if (!ExtractOverlayToFile(zipPath)) {
    if (splash) DestroyWindow(splash);
    Fatal(L"El instalador está dañado o incompleto (no se encontró el "
          L"contenido de la aplicación). Descárgalo de nuevo.");
    return 2;
  }

  // 3) Descomprimir con el tar.exe de Windows (firmado por Microsoft).
  const std::wstring tar = SystemTar();
  if (GetFileAttributesW(tar.c_str()) == INVALID_FILE_ATTRIBUTES) {
    if (splash) DestroyWindow(splash);
    Fatal(L"Este equipo no incluye tar.exe (requiere Windows 10 1809 o "
          L"posterior). Usa el paquete ZIP como alternativa.");
    return 3;
  }
  std::wstring cmd = L"\"" + tar + L"\" -xf \"" + zipPath + L"\" -C \"" +
                     stage + L"\"";
  int rc = RunHiddenWait(cmd);
  if (rc != 0) {
    if (splash) DestroyWindow(splash);
    Fatal(L"No se pudo descomprimir la aplicación (código " +
          std::to_wstring(rc) + L").");
    return 4;
  }

  // 4) Limpiar el zip temporal.
  DeleteFileW(zipPath.c_str());

  // 5) Lanzar la app; su SetupWizard toma el control desde aquí.
  if (GetFileAttributesW(exePath.c_str()) == INVALID_FILE_ATTRIBUTES) {
    if (splash) DestroyWindow(splash);
    Fatal(L"No se encontró nexo.exe tras la extracción.");
    return 5;
  }
  bool launched = LaunchDetached(exePath, stage);

  if (splash) DestroyWindow(splash);
  CoUninitialize();

  if (!launched) {
    Fatal(L"No se pudo iniciar Nexo tras la instalación.");
    return 6;
  }
  return 0;
}
