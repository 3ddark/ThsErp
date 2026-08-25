@echo off
setlocal enabledelayedexpansion
chcp 1254 > nul
echo Delphi gecici ve derleme dosyalari temizleniyor...
echo.

set "PROJECT_DIR=%~dp0"

REM Silinecek dosya uzantilari
set FILE_EXTENSIONS=dcu dsm ddp map bak dsk bpl bpi tds il identcache

echo Bulunan ve silinecek dosyalar:

REM Her uzantıyı tek tek tarama
for %%X in (%FILE_EXTENSIONS%) do (
    for /r "%PROJECT_DIR%" %%F in (*.%%X) do (
        echo %%F | findstr /i "\\.svn\\" >nul
        if errorlevel 1 (
            echo Siliniyor ^(Dosya^): "%%F"
            del /f /q "%%F"
        )
    )
)

REM __history klasorlerini sil
echo.
echo Bulunan ve silinecek klasorler:

for /f "delims=" %%D in ('dir "%PROJECT_DIR%\__history" /s /b /ad 2^>nul') do (
    echo %%D | findstr /i "\\.svn\\" >nul
    if errorlevel 1 (
        echo Siliniyor ^(Klasor^): "%%D"
        rmdir /s /q "%%D"
    )
)

echo.
echo Temizlik tamamlandi (.svn klasorlerine dokunulmadi).
pause
endlocal