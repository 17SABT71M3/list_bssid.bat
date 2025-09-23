@echo off
setlocal enabledelayedexpansion
set pinged_google=0
cd /d "%~dp0"
title connect
REM for /f "delims=" %%i in ('powershell -c "write-host -nonewline `t"') do set "tab=%%i"
set networks=0
for /f "tokens=1,2 delims=:" %%i in ('netsh wlan show interfaces ^| findstr /iR "Name GUID BSSID"') do (
set temp_name=%%i
set temp_name=!temp_name: =!
if /i "!temp_name!"=="Name" set /a networks+=1&for /f "tokens=* delims= " %%s in ("%%j") do set "name_[!networks!]=%%s"
REM set guid_[!networks!]=
if /i "!temp_name!"=="GUID" for /f "tokens=* delims= " %%d in ("%%j") do set guid_[!networks!]=%%d
)
set total_network=!networks!
call :pick_interface
for /l %%a in (1,1,!networks!) do if "!name_[%%a]!"=="!interfacename!" set real_guid=!guid_[%%a]!
for /f "delims=" %%i in ('dir /b "%ProgramData%\Microsoft\Wlansvc\Profiles\Interfaces\*" ^| find /i "%real_guid%"') do set guid_dir=%ProgramData%\Microsoft\Wlansvc\Profiles\Interfaces\%%i
:start
set /a all_ears=0
set ssid_connected=
for /f "tokens=1,* delims=:" %%i in ('netsh wlan show interfaces ^| findstr /ir "Name.*[:] State.*[:] ssid.*[:]"') do (
if !all_ears! NEQ 1 for /f "tokens=1 delims= " %%b in ("%%i") do if /i "%%b"=="name" for /f "tokens=* delims= " %%a in ("%%j") do set all_ears=9&if "%%a"=="!interfacename!" set /a all_ears=1
if !all_ears!==1 for /f "tokens=1 delims= " %%b in ("%%i") do if /i "%%b"=="ssid" for /f "tokens=* delims= " %%a in ("%%j") do set "ssid_connected=%%a"
)
call :picknext
    set networks=0
    for /f "tokens=1,2,3,*" %%a in ('netsh wlan show networks mode^=bssid interface^="!interfacename!" ') do (

        if "%%a"=="SSID" (
            set /a networks=networks+1
            set ssid_[!networks!]=%%d
            set encrypt_[!networks!]=
            set auth_[!networks!]=
            set signal_strength_[!networks!]=
            set bssid_[!networks!]=
            set nutindex=0
        )

	if "%%a"=="Authentication" (
            set auth_[!networks!]=%%c
        )

        if "%%a"=="Encryption" (
            set encrypt_[!networks!]=%%c
        )

        if "%%a"=="Signal" (
            set temp=00%%c
            if "%%c" NEQ "" set temp=!temp:~-4!
            for %%z in ("!networks!") do set signal_strength_[%%~z]=!signal_strength_[%%~z]![!nutindex!]!temp!
        )
        
        if "%%a"=="BSSID" (
            REM !bssid_[%%~z]!%%d^(!nutindex!^)$
            for %%z in ("!networks!") do set /a nutindex+=1&set bssid_[%%~z]=!bssid_[%%~z]!%%d{!NUTINDEX!}
        )


    )
    set total_found_networks=!networks!
    type nul >"%tmp%\wifi_sign.txt"
    for /l %%a in ( 1, 1, !networks! ) do (

        if "!ssid_[%%a]!" == "" ( 
            (echo:!signal_strength_[%%a]!/!bssid_[%%a]!/"")>>"%tmp%\wifi_sign.txt"
        ) else (
            if "!signal_strength_[%%a]!"=="" set signal_strength_[%%a]=signal_is_not_available
            if "!bssid_[%%a]!"=="" set bssid_[%%a]=N.A.
            (echo:!signal_strength_[%%a]!/!bssid_[%%a]!/"!ssid_[%%a]!")>>"%tmp%\wifi_sign.txt"
        )

    )
    set list_empty=1
    for /f "delims=" %%i in ('type "%tmp%\wifi_sign.txt"') do set /a list_empty=0
    if %list_empty%==1 echo (list empty)
    if %list_empty%==1 (set choice_list=) else (set choice_list=123456789)
    :print_info
    set skip=0
    set /a displaycurtain=networks
    set corecount=9
    :repat
    set /a displaycurtain=displaycurtain-9
    set /a escape=0 
    if !displaycurtain! LEQ 0 set escape=1
    set counter=0
 rem   echo:===============================================================================
  rem  echo:#^)SSID NAME%tab%SIGNAL:%tab%BSSID:
   rem echo:===============================================================================
    if !skip!==0 for /f "tokens=1,2,* delims=/" %%i in ('type "%tmp%\wifi_sign.txt" ^| sort /R /+4 ') do set /a counter+=1 & (if !counter! GTR 9 goto :eof) & set "ssid_[!counter!]=%%~k"&echo:%%j
    
REM    if !skip! GTR 0 for /f "skip=%skip% tokens=1,2,* delims=/" %%i in ('type "%tmp%\wifi_sign.txt" ^| sort /R /+4') do set /a corecount+=1&set /a counter+=1 & (if !counter! GTR 9 goto :eof) & set "ssid_[!counter!]=%%~k"&(if "%%~k"=="" echo:!counter!^)-HIDDEN%tab%signal:%%i%tab%%tab%bssids:%%j ) &if "%%~k"=="!ssid_connected!" (if "%%~k" NEQ "" echo !corecount!^)^(!counter!^) %%~k*%tab%signal:%%i%tab%%tab%bssids:%%j) else (if "%%~k" NEQ "" echo !corecount!^)^(!counter!^) %%~k%tab%signal:%%i%tab%%tab%bssids%%j)
goto :eof
:colors

Set Black1=[40m

Set Red1=[41m

Set Green1=[42m
Set Yellow1=[43m

Set Blue1=[44m

Set Magenta1=[45m
Set white1=[107m
Set Cyan1=[46m

Set Black=[30m
Set Red=[31m
Set Green=[32m
Set Blue=[34m
Set Yellow=[33m
Set Magenta=[35m
Set Cyan=[36m
Set white=[37m

for /f "delims=" %%i in (%3) do echo|set/p=!%~11!!%~2!%%~i[0m
REM powershell -c "write-host -nonewline -backgroundcolor %first% -foregroundcolor %second% \"%~3\""
goto :eof
:pick_interface
set counters=0
    for /f "tokens=2* delims=:" %%a in ('netsh wlan show interfaces ^|  findstr "Name.*[:]"') do set /a counters+=1 & set "ifacename[!counters!]=%%a"
    if !counters! LEQ 1 for /f %%i in ("%counters%") do set interfacename=!ifacename[%%i]!
    if !counters! GTR 1 (
    set choices=
    echo Select an interface
    for /l %%i in (1,1,!counters!) do echo %%i^) !ifacename[%%i]! & set choices=!choices!%%i
    choice /c !choices!
    for /f "delims=" %%i in ("!errorlevel!") do set interfacename=!ifacename[%%i]!
    )
    for /f "tokens=* delims= " %%a in ("!interfacename!") do set "interfacename=%%a"
exit /b
    :picknext
    if "!interfacename!" == "" echo: & echo:***No Wireless interface found^!*** & echo: &  GOTO :eof

goto :eof
