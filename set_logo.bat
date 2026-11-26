@echo off
echo ==============================================
echo NM Research Partner Logo & Launcher Icon Updater
echo ==============================================

set "SRC=assets\system\logo.png"

echo Updating Flutter asset logo...
if exist "assets\system\launcher-icon.png" (
    call dart run flutter_launcher_icons
)

echo.
echo [SUCCESS] NM Research Partner logo and launcher icons active!
pause
