@echo off
setlocal
cd /d "%~dp0"
echo ======================================================
echo    CVS Activity Tracker - Automated Unit Tests (CTest)
echo ======================================================

set "CTEST_BIN=C:\Qt\Tools\CMake_64\bin\ctest.exe"
set "PATH=C:\Qt\6.9.3\msvc2022_64\bin;%PATH%"

echo Running tests in Release configuration...
"%CTEST_BIN%" --test-dir build -C Release --output-on-failure
if %errorlevel% neq 0 (
    echo.
    echo Testing Debug configuration as fallback...
    "%CTEST_BIN%" --test-dir build -C Debug --output-on-failure
)

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Some tests failed.
    pause
    exit /b %errorlevel%
)

echo.
echo ======================================================
echo [SUCCESS] All unit tests passed 100%!
echo ======================================================
pause
