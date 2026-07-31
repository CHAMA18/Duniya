cmake_minimum_required(VERSION 3.14)
project(Duniya LANGUAGES CXX)

# The name of the executable created for the application.
set(APPLICATION_ID "com.duniyahealthcare.app")

# Explicitly set the standard to C++17.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Define the application target.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "runner.exe.manifest"
  "Runner.rc"
  "runner.ico"
)

# Apply the standard set of build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE
  "NOMINMAX"
  "UNICODE"
  "_UNICODE"
)

# Add dependencies.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_include_directories(${BINARY_NAME} PRIVATE
  "${CMAKE_SOURCE_DIR}"
)

# Copy the Flutter assets.
add_custom_command(
  TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  "${CMAKE_CURRENT_SOURCE_DIR}/../flutter/ephemeral/.plugin_symlinks"
  "${CMAKE_CURRENT_BINARY_DIR}/plugin_symlinks"
)
