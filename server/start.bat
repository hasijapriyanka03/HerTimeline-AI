@echo off
echo ========================================
echo  Mensa Pregnancy Tracker - Backend
echo ========================================
echo.

echo Checking Node.js installation...
node --version
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed!
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

echo.
echo Installing dependencies...
call npm install

echo.
echo Starting server...
echo Server will run on http://localhost:3000
echo Press Ctrl+C to stop
echo.

call npm start
