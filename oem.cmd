@echo off&color e&mode con:cols=70 lines=18&title[ ~ OEM BACKUP AND RESTORE TOOL ~ ]
setlocal enableextensions
@cd /d "%~dp0"
::===========+
:: OEM.Backup.Restore.cmd
:: Backup.Restore OEM 1.1 - ndog
:: Based on OEM 1.1 - ndog from: forums.mydigitallife.net/threads/37907-oem-logo-backup-batch
::===========+
:MAINMENU
cls
echo            [MAIN MENU]
echo      +=====================+  
echo       A.) BACKUP OEM 
echo.
echo       B.) RESTORE OEM
echo.
echo       C.) COMPUTER Info
echo.
echo       D.) CHECK License
echo.
echo       E.) EXIT The Program
echo      +=====================+ 
echo.
echo.
set choice=
set /p choice= When Ready Select: A, B, C, D, or E then press [ENTER]:
echo.
if not '%choice%'=='' set choice=%choice:~0,1%

if /I '%choice%'=='A' goto BACKUP
if /I '%choice%'=='B' goto RESTORE
if /I '%choice%'=='C' goto INFO
if /I '%choice%'=='D' goto License
if /I '%choice%'=='E' goto EOF
echo.
echo "%choice%" Key is Incorrect!  Please Select Correct Key Then Try Again..
echo.
goto :mainmenu
::===========+
:BACKUP
cls &color e
echo Press any [KEY] To Begin Backup ...&pause>nul&goto :bu
:bu
cls
:: make appropriate folder
set _mmb=HPOEM
md "%_mmb%" 2>nul >nul

:: Backup Welcome screen background
echo d | xcopy "%windir%\system32\oobe\info" "%~dp0%_mmb%\oobe\info" /s/i/y>nul 2>&1
reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" "%~dp0%_mmb%\oem-welcomescreenbackground.reg" /y>nul 2>&1

:: Backup system properties logo and OEM information
reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" "%~dp0%_mmb%\oem-logoinformation.reg" /y>nul 2>&1
for /f "tokens=3 delims= " %%g in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "Logo" 2^>nul') do (set _logofile=%%g)
if defined _logofile copy /y "%_logofile%" "%~dp0%_mmb%">nul 2>&1

:: Backup SLIC certs - if found
for /f "tokens=" %%g in ('dir /b "%windir%\system32\oem\.xrm-ms" 2^>nul') do (
    md "%~dp0%_mmb%\oem" 2>nul >nul
    copy "%windir%\system32\oem\%%g" "%~dp0%_mmb%\oem"
    )

:: Backup desktop background - if found
if exist "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper.jpg" copy /y "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper.jpg" "%~dp0%_mmb%\oem-desktopwallpaper.jpg">nul 2>&1
if exist "%LOCALAPPDATA%\Microsoft\Wallpaper1.bmp" copy /y "%LOCALAPPDATA%\Microsoft\Wallpaper1.bmp" "%~dp0%_mmb%\oem-desktopwallpaper.bmp">nul 2>&1
ping localhost -n 3 >nul
echo.
cls
echo * DONE * == Press Any [KEY] To Return To The Main Menu ==&pause>nul&goto :mainmenu
::===========+
:RESTORE  
cls &color e
echo Press any [KEY] To Begin Restore ...&pause>nul&goto :rs
:rs
cls
:: Choose appropriate folder
set _mmb=HPOEM

:: Restore Welcome screen background
echo d | xcopy "%~dp0%_mmb%\oobe\info" "%windir%\system32\oobe\info" /s/i/y>nul 2>&1
reg import "%~dp0%_mmb%\oem-welcomescreenbackground.reg">nul 2>&1

:: Restore system properties logo and OEM information
reg import "%~dp0%_mmb%\oem-logoinformation.reg">nul 2>&1
for /f "tokens=3 delims= " %%g in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "Logo" 2^>nul') do (
    set _logofilebackupfile=%%~nxg
    set _logofilerestorefull=%%g
    )
if defined _logofilebackupfile (
    mkdir "%_logofilerestorefull%" 2>nul >nul
    rd /s/q "%_logofilerestorefull%" 2>nul >nul
    copy /y "%~dp0%_mmb%\%_logofilebackupfile%" "%_logofilerestorefull%">nul 2>&1
    )

:: Restore SLIC certs
for /f "tokens=" %%g in ('dir /b "%~dp0%_mmb%\oem\.xrm-ms" 2^>nul') do (
    md "%windir%\system32\oem" 2>nul >nul
    copy "%~dp0%_mmb%\oem\%%g" "%windir%\system32\oem">nul 2>&1
    )

:: Apply desktop background to current user (recommend to do this part properly)
REM if exist "%~dp0%_mmb%\oem-desktopwallpaper.jpg" copy /y "%~dp0%_mmb%\oem-desktopwallpaper.jpg" "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper.jpg">nul 2>&1
REM if exist "%~dp0%_mmb%\oem-desktopwallpaper.bmp" copy /y "%~dp0%_mmb%\oem-desktopwallpaper.bmp" "%LOCALAPPDATA%\Microsoft\Wallpaper1.bmp">nul 2>&1
ping localhost -n 3 >nul
echo.
cls
echo * DONE * == Press Any [KEY] To Return To The Main Menu ==&pause>nul&goto :mainmenu
::===========+
:INFO
cls &color e
echo Press any [KEY] To Get Computer Information ...&pause>nul&goto :ci
:ci
cls
:: Get Computer OS
FOR /F "tokens=2 delims='='" %%A in ('wmic os get Name /value') do SET osname=%%A
FOR /F "tokens=1 delims='|'" %%A in ("%osname%") do SET osname=%%A

:: Get Computer Serial Number
FOR /F "tokens=2 delims='='" %%A in ('wmic Bios Get SerialNumber /value') do SET serialnumber=%%A

:: Get Computer Manufacturer
FOR /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Manufacturer /value') do SET manufacturer=%%A

:: Get Computer Model
FOR /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Model /value') do SET model=%%A

:: Get Computer Name
FOR /F "tokens=2 delims='='" %%A in ('wmic OS Get csname /value') do SET system=%%A

:: Get Service Pack
FOR /F "tokens=2 delims='='" %%A in ('wmic os get ServicePackMajorVersion /value') do SET sp=%%A

echo COMPUTER INFORMATION
echo ====================
echo O.S.: %osname%
echo Serial Number: %serialnumber%
echo Manufacturer: %manufacturer%
echo Model: %model%
echo System Name: %system%
echo Service Pack: %sp%
echo ====================
echo.
echo * DONE * == Press Any [KEY] To Return To The Main Menu ==&pause>nul&goto :mainmenu
::===========+
:License
cls &color e
echo Press any [KEY] To Get License Status ...&pause>nul&goto :ls
:ls
cls
:License Status
cscript c:\windows\system32\slmgr.vbs -dlv
echo.
echo * DONE * == Press Any [KEY] To Return To The Main Menu ==&pause>nul&goto :mainmenu
::===========+
:EOF
echo.
set /p =CLOSING MENU In:               <nul
for /l %%a in (5 -1 1) do (
set /p =%%a Seconds... <nul&ping -n 2 127.1 >nul
)
exit,0
::===========+
