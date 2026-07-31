# Flutter-specific CMakeLists for Windows
cmake_minimum_required(VERSION 3.14)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Configuration provided via flutter tool.
include("${EPHEMERAL_DIR}/generated_config.cmake")

# TODO: Move the rest of this into files in ephemeral.
set(WRAPPER_ROOT "${EPHEMERAL_DIR}/cpp_client_wrapper")

# === Flutter library ===
set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/flutter_windows.dll")

# Published as DLL_EXPORTS.
set(FLUTTER_DLL_EXPORTS "${EPHEMERAL_DIR}/flutter_export.h")

# === Wrapper library ===
set(WRAPPER_SOURCES
  "${WRAPPER_ROOT}/flutter_engine.cc"
  "${WRAPPER_ROOT}/flutter_view_controller.cc"
  "${WRAPPER_ROOT}/plugin_registrar.cc"
)

add_library(flutter_wrapper_app STATIC ${WRAPPER_SOURCES})
target_include_directories(flutter_wrapper_app PUBLIC
  "${WRAPPER_ROOT}/include"
  "${EPHEMERAL_DIR}"
)
target_link_libraries(flutter_wrapper_app PUBLIC flutter)
target_compile_definitions(flutter_wrapper_app PRIVATE FLUTTER_WRAPPER_IMPL)

# === Flutter tool backend ===
function(add_flutter_library_target APP_NAME)
  add_library(${APP_NAME} SHARED ${ARGN})
  target_include_directories(${APP_NAME} INTERFACE
    "${EPHEMERAL_DIR}"
  )
  target_link_libraries(${APP_NAME} PRIVATE flutter flutter_wrapper_app)
endfunction()
