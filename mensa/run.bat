@echo off
echo ========================================
echo  Mensa Pregnancy Tracker - Flutter App
echo ========================================
echo.

echo Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed!
    echo Please install Flutter from https://flutter.dev/
    pause
    exit /b 1
)

echo.
echo Getting dependencies...
call flutter pub get

echo.
echo Checking connected devices...
call flutter devices

echo.
echo Starting Flutter app...
echo.

call flutter run
