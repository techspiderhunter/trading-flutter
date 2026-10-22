@echo off
echo ==============================================
echo Moneyara Research Logo & Launcher Icon Updater
echo ==============================================

set "SRC=C:\Users\EXPERT\.gemini\antigravity\brain\aeae2673-408c-4448-b630-e5382456c802\.user_uploaded\media_1792004782908_388516e1.png"
if not exist "%SRC%" set "SRC=assets\system\logo.png"

echo Updating Flutter asset logo...
copy /Y "%SRC%" "assets\system\logo.png" >nul

echo Updating Android launcher mipmap icons...
copy /Y "%SRC%" "android\app\src\main\res\mipmap-mdpi\launcher.png" >nul
copy /Y "%SRC%" "android\app\src\main\res\mipmap-hdpi\launcher.png" >nul
copy /Y "%SRC%" "android\app\src\main\res\mipmap-xhdpi\launcher.png" >nul
copy /Y "%SRC%" "android\app\src\main\res\mipmap-xxhdpi\launcher.png" >nul
copy /Y "%SRC%" "android\app\src\main\res\mipmap-xxxhdpi\launcher.png" >nul

copy /Y "%SRC%" "android\app\src\main\res\mipmap-mdpi\app_logo.png" >nul
copy /Y "%SRC%" "android\app\src\main\res\mipmap-hdpi\app_logo.png" >nul
copy /Y "%SRC%" "android\app\src\main\res\mipmap-xhdpi\app_logo.png" >nul
copy /Y "%SRC%" "android\app\src\main\res\mipmap-xxhdpi\app_logo.png" >nul
copy /Y "%SRC%" "android\app\src\main\res\mipmap-xxxhdpi\app_logo.png" >nul

echo.
echo [SUCCESS] Moneyara logo and launcher icons updated successfully!
echo You can now rebuild or run your Flutter app (flutter run).
pause
