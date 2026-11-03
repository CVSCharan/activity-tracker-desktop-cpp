@echo off
setlocal
cd /d "%~dp0"
echo ======================================================
echo    CVS Activity Tracker - Quick Build and Run
echo ======================================================

set "CMAKE_BIN=C:\Qt\Tools\CMake_64\bin\cmake.exe"
set "QT_BIN=C:\Qt\6.9.3\msvc2022_64\bin"

echo [1/3] Configuring CMake (MSVC 2022 64-bit)...
"%CMAKE_BIN%" -B build -G "Visual Studio 17 2022" -A x64 .
if %errorlevel% neq 0 (
    echo [ERROR] CMake configuration failed.
    pause
    exit /b %errorlevel%
)

echo [2/3] Compiling Debug executable...
"%CMAKE_BIN%" --build build --config Debug
if %errorlevel% neq 0 (
    echo [ERROR] Compilation failed.
    pause
    exit /b %errorlevel%
)

echo [3/3] Deploying runtime dependencies if needed...
"%QT_BIN%\windeployqt6.exe" --qmldir qml "build\Debug\ActivityTracker.exe" >nul 2>&1

echo.
echo [SUCCESS] Launching CVS Activity Tracker (Debug)...
start "" "build\Debug\ActivityTracker.exe"

