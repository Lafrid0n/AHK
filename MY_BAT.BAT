@echo off
setlocal

::start set
set "AhkExePath=..\..\..\soft\AHK\AutoHotkey64.exe"
set "AhkScriptsPath=MY_AHK.ahk"

set ButtonMyAhk=ButtonMyAhk.bat
set "StartupMyAhk=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\StartupMyAhk.bat"

for %%i in ("%AhkExePath%") do set "AhkExeFullPath=%%~fi"
for %%i in ("%AhkScriptsPath%") do set "AhkScriptsFullPath=%%~fi"
::end set


:: create TC button MY_AHK.ahk "ButtonMyAhk.bat"
(
    echo @echo off
    echo start "" "%AhkExePath%" "%AhkScriptsPath%" -startup
    echo exit
) > "%ButtonMyAhk%"




:: create startup MY_AHK.ahk StartupMyAhk.bat
(
    echo @echo off
    echo if exist "%AhkScriptsFullPath%" (
    echo     start "" "%AhkExeFullPath%" "%AhkScriptsFullPath%" -startup
    echo ^) else (
    echo     del "%%~f0"
    echo ^)
    echo exit
) > "%StartupMyAhk%"

exit