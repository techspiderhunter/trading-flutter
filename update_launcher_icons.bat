@echo off
cd /d "c:\flutter project\Money-Via-flutter"
echo ========================================================
echo Updating Moneyara Research Logo and Replacing Vnext Icons
echo ========================================================

echo 1. Copying latest Moneyara Research logo from upload...
copy /Y "C:\Users\EXPERT\.gemini\antigravity\brain\aeae2673-408c-4448-b630-e5382456c802\.user_uploaded\media_1791748229330.png" "assets\system\logo.png"
copy /Y "C:\Users\EXPERT\.gemini\antigravity\brain\aeae2673-408c-4448-b630-e5382456c802\.user_uploaded\media_1791748229330.png" "assets\system\launcher-icon.png"

echo 2. Replacing all old Vnext launcher icons in Android mipmap folders...
copy /Y "assets\system\logo.png" "android\app\src\main\res\mipmap-mdpi\launcher.png"
copy /Y "assets\system\logo.png" "android\app\src\main\res\mipmap-hdpi\launcher.png"
copy /Y "assets\system\logo.png" "android\app\src\main\res\mipmap-xhdpi\launcher.png"
copy /Y "assets\system\logo.png" "android\app\src\main\res\mipmap-xxhdpi\launcher.png"
copy /Y "assets\system\logo.png" "android\app\src\main\res\mipmap-xxxhdpi\launcher.png"
copy /Y "assets\system\logo.png" "android\app\src\main\res\mipmap-mdpi\ic_launcher.png"
copy /Y "assets\system\logo.png" "android\app\src\main\res\mipmap-hdpi\ic_launcher.png"
copy /Y "assets\system\logo.png" "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png"
copy /Y "assets\system\logo.png" "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png"
copy /Y "assets\system\logo.png" "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"

echo 3. Running flutter_launcher_icons to rebuild adaptive launcher icons...
call dart run flutter_launcher_icons

echo ========================================================
echo Done! Vnext icons permanently removed. Moneyara Research logo is now active!
echo ========================================================
