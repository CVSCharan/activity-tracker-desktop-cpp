@echo off
setlocal
cd /d "%~dp0"
echo ======================================================
echo    CVS Activity Tracker - Production Release Build
echo ======================================================

set "CMAKE_BIN=C:\Qt\Tools\CMake_64\bin\cmake.exe"
set "QT_BIN=C:\Qt\6.9.3\msvc2022_64\bin"
set "WINDEPLOYQT=%QT_BIN%\windeployqt6.exe"

echo [1/4] Configuring CMake (MSVC 2022 64-bit)...
"%CMAKE_BIN%" -B build -G "Visual Studio 17 2022" -A x64 .
if %errorlevel% neq 0 (
    echo [ERROR] CMake configuration failed.
    pause
    exit /b %errorlevel%
)

echo [2/4] Compiling Release executable (Optimized)...
"%CMAKE_BIN%" --build build --config Release
if %errorlevel% neq 0 (
    echo [ERROR] Release compilation failed.
    pause
    exit /b %errorlevel%
)

echo [3/4] Packaging Qt DLLs with windeployqt6...
"%WINDEPLOYQT%" --qmldir qml "build\Release\ActivityTracker.exe"
if %errorlevel% neq 0 (
    echo [ERROR] windeployqt failed.
    pause
    exit /b %errorlevel%
)

echo.
echo ======================================================
echo [SUCCESS] Release package ready!
echo Output: %~dp0build\Release\ActivityTracker.exe
echo ======================================================
choice /m "Do you want to launch the Release app now"
if %errorlevel% equ 1 (
    start "" "build\Release\ActivityTracker.exe"
)
