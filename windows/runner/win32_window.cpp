#include "win32_window.h"

#include <dwmapi.h>
#include <flutter_windows.h>

#include <string>

namespace {

WindowClassRegistrar *g_window_class_registrar = nullptr;

constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";

}  // namespace

Win32Window::Win32Window() {}
Win32Window::~Win32Window() { Destroy(); }

bool Win32Window::Create(const std::wstring &title, const Point &origin,
                         const Size &size) {
  Destroy();

  DWORD window_style = WS_OVERLAPPEDWINDOW;
  HWND window = CreateWindow(kWindowClassName, title.c_str(), window_style,
                             CW_USEDEFAULT, CW_USEDEFAULT, size.width,
                             size.height, nullptr, nullptr, nullptr, this);
  if (!window) {
    return false;
  }

  return OnCreate();
}

bool Win32Window::Show() {
  return ShowWindow(window_handle_, SW_SHOWNORMAL);
}

void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

RECT Win32Window::GetClientArea() {
  RECT frame;
  GetClientRect(window_handle_, &frame);
  return frame;
}

LRESULT Win32Window::MessageHandler(HWND hwnd, UINT const message,
                                    WPARAM const wparam,
                                    LPARAM const lparam) noexcept {
  return DefWindowProc(hwnd, message, wparam, lparam);
}

bool Win32Window::OnCreate() { return true; }

void Win32Window::OnDestroy() {}

LRESULT CALLBACK Win32Window::WndProc(HWND hwnd, UINT message, WPARAM wparam,
                                      LPARAM lparam) noexcept {
  Win32Window *self = GetThisFromHandle(hwnd);
  switch (message) {
    case WM_NCDESTROY:
      if (self) {
        self->window_handle_ = nullptr;
        if (self->quit_on_close_) {
          PostQuitMessage(0);
        }
      }
      break;
    case WM_CREATE:
      if (self) {
        self->window_handle_ = hwnd;
      }
      break;
  }
  return DefWindowProc(hwnd, message, wparam, lparam);
}

Win32Window *Win32Window::GetThisFromHandle(HWND window) noexcept {
  return reinterpret_cast<Win32Window *>(
      GetWindowLongPtr(window, GWLP_USERDATA));
}

void Win32Window::Destroy() {
  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
}
