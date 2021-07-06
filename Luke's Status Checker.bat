@echo off
echo Starting up . . .
@mode con lines=14 cols=50
rem see :ftp for help on how the ftp cmdlet works
SetLocal EnableDelayedExpansion
rem create and enter bin
if not exist "Bin\" md Bin
set Bincd=%cd%\Bin
if not exist "Data\" md Data
cd Data
if exist "OnlinePlayerList.ini" del /f /q "OnlinePlayerList.ini"
if exist "PreviousPlayerList.ini" del /f /q "PreviousPlayerList.ini"
title Lukes Friends Checker
rem Grab Dependencies
if not exist "%bincd%\WinSCP.com" curl https://raw.githubusercontent.com/ITCMD/ITCMD-STORAGE/master/WinSCP.com -s -o "%bincd%\WinSCP.com" >nul
if not exist "%bincd%\WinSCP.exe" curl https://raw.githubusercontent.com/ITCMD/ITCMD-STORAGE/master/WinSCP.exe -s -o "%bincd%\WinSCP.exe" >nul
if not exist "%bincd%\CMDS.bat" curl https://raw.githubusercontent.com/ITCMD/CMDS/master/CMDS.bat -s -o "%bincd%\CMDS.bat" >nul
if not exist "%bincd%\Notification.exe" curl https://raw.githubusercontent.com/ITCMD/ITCMD-STORAGE/master/notification.exe -s -o "%bincd%\Notification.exe" >nul
if not exist "%bincd%\File-Chooser.bat" curl https://raw.githubusercontent.com/ITCMD/ITCMD-STORAGE/master/File-Choser.bat -s -o "%bincd%\File-Chooser.bat" >nul
if not exist "Online.ico" curl https://raw.githubusercontent.com/ITCMD/ITCMD-STORAGE/master/Online.ico -o "%Online.ico" >nul
if not exist "Offline.ico" curl https://raw.githubusercontent.com/ITCMD/ITCMD-STORAGE/master/Offline.ico -o "Offline.ico" >nul
if not exist "%bincd%\BackgroundCheck.bat" curl https://raw.githubusercontent.com/ITCMD/Lukes-Friend-Checker/main/BackgroundCheck.bat -s -o "%bincd%\BackgroundCheck.bat" >nul
if exist "%bincd%\bGC-Hidden-Launcher.vbs" goto skipvbs
	echo Set objShell = CreateObject("WScript.Shell") > "%bincd%\bGC-Hidden-Launcher.vbs"
	echo objShell.CurrentDirectory = "%bincd%" >> "%bincd%\bGC-Hidden-Launcher.vbs"
	echo Set oShell = CreateObject("WScript.Shell") >> "%bincd%\bGC-Hidden-Launcher.vbs"
	echo oShell.Run """%bincd%\BackgroundCheck.bat""", 0 >> "%bincd%\bGC-Hidden-Launcher.vbs"
:skipvbs
rem Check Settings
if not exist "settings.cmd" goto initialsetup
:setupcomplete
call "Settings.cmd"
rem Check for variables
if /i "%~1"=="" goto start
if /i "%~1"=="/help" goto help
if /i "%~1"=="--help" goto help
if /i "%~1"=="/h" goto help
if /i "%~1"=="-h" goto help
if /i "%~1"=="-?" goto help
if /i "%~1"=="/?" goto help
rem Check variables
rem this part is not here yet, but will allow other programs to set your status for you
exit /b

:start
cls
if not exist "usr.ini" goto user
set /p usr=<usr.ini
set usr=%usr: =%
goto autologin

:settings
cls
echo [106;30m                  Settings Menu                   [0m
echo.
echo 1] [95m[%Notifications_Stay_Open%][0m Repeat Online Notifications Until Clicked
echo 2] [95m[%TTL%][0m Time Until Refresh
echo 3] [95m[%server%][0m Server
echo 4] [95m[%ftpusr%%][0m Login Data
if exist "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\LFC.bat" (
	echo 5] [95m[On][0m Launch on startup
) ELSE (
	echo 5] [95m[Off][0m Launch on startup
)
echo X] Exit back to menu
choice /c 12345x
if %errorlevel%==6 goto loadwho
if %errorlevel%==5 goto startup
if %errorlevel%==1 (
	if "%Notifications_Stay_Open%"=="Y" (
		set Notifications_Stay_Open=N
	) ELSE (
		set Notifications_Stay_Open=Y
	)
)
if %errorlevel%==2 (
	set /p TTL="TTL>"
)
if %errorlevel%==3 (
	set /p server="SRVR>"
)
if %errorlevel%==4 (
	set /p ftpusr="Username>"
	set /p ftppass="Pass>"
)
	
echo set "Notifications_Stay_Open=%Notifications_Stay_Open%">settings.cmd
echo set "TTL=%TTL%">>settings.cmd
echo set "server=%server%">>settings.cmd
echo set "ftpusr=%ftpusr%">>settings.cmd
echo set "ftppass=%ftppass%">>settings.cmd
goto settings

:startup
if exist "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\LFC.bat" (
	del /f /q "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\LFC.bat"
	goto settings
)
curl https://raw.githubusercontent.com/ITCMD/Lukes-Friend-Checker/main/LFC.bat -s -o "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\LFC.bat" >nul
echo. >>"C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\LFC.bat"
echo set cdd=%bincd% >>"C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\LFC.bat"
echo exit /b >>"C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\LFC.bat"
goto settings




:initialsetup
cls
echo [46;97m        Welcome to Luke's Friends Checker.        [0m
echo.
echo [90mNo "settings.cmd" file. Setup required.[0m
echo.
echo Enter FTP Server address to connect to:
set /p server=">"
echo Enter FTP Server username:
set /p ftpusr=">"
echo Enter FTP Server Password:
echo [90mNote: This is stored in insecure plain 
echo text. Enforce Bandwidth Limits and keep folder isolated.[0m
set /p ftppass=">"
echo set "Notifications_Stay_Open=N">settings.cmd
echo set "TTL=30">>settings.cmd
echo set "server=%server%">>settings.cmd
echo set "ftpusr=%ftpusr%">>settings.cmd
echo set "ftppass=%ftppass%">>settings.cmd
goto setupcomplete


:user
echo [92mYou do not yet have a user set.[0m
echo.
echo 1] Use existing user
echo 2] Create user
choice /c 12
if %errorlevel%==1 goto login
:newuser
cls
echo Enter Username
set /p usr=">"
set "usr=%usr: =_%"
call :ftp "usertest" "cd users" "stat %usr%"
find "File or directory not found." "usertest" >nul
if not "%errorlevel%"=="0" (
	echo User Already Exists. Please Log in
	pause
	goto user
)
echo %date%-%time%>%usr%
call :ftp "nul" "cd users" "put %usr%"
del /f /q %usr%
echo Created user "%usr%"
goto user

:login
cls
echo [92mEnter username to login[0m
set /p usr=">"
call :ftp "usertest" "cd users" "stat %usr%"
find "File or directory not found." "usertest" >nul
if "%errorlevel%"=="0" (
	echo User not found. Please create a new user.
	del /f /q usertest
	pause
	goto user
)
del /f /q usertest
echo %usr% >usr.ini
:autologin
echo Logging in . . .
echo %time% on %date% >%usr%.online
call :ftp "useronline" "cd Online" "put %usr%.online"
REM ADD START BG CHECK HERE
start "" "%bincd%\bGC-Hidden-Launcher.vbs"
title Lukes Friends Checker [%usr%]
goto loadwho

:refresh
echo [90mRefreshing. Please wait . . .[0m
:loadwho
if exist PreviousPlayerList.ini del /f /q PreviousPlayerList.ini
if exist OnlinePlayerList.ini ren OnlinePlayerList.ini PreviousPlayerList.ini
if exist *.online del /f /q *.online
if exist *.playing del /f /q *.playing
rem get list of online players
call :ftp "nul" "cd Online" "mget *.online"
rem get rid of self-online
del /f /q "%usr%.online" >nul
rem if nobody is online, dont bother with the rest
rem get files of what people are playing
if not exist "*.online" goto alonecheckprevious
call :ftp "nul" "cd Online" "mget *.playing"
rem create simple list of online players
dir /b "*.online%" > "OnlinePlayerList.ini"
if exist PreviousPlayerList.ini goto checkprevious
for /f "tokens=1,2 usebackq delims=." %%A in ("OnlinePlayerList.ini") do (
	if exist "%%~A.playing" (
			set /p game=<"%%~A.playing"
			set stat=online and playing !game!.
		) ELSE (
			set stat=online.
		)
		set /p gtme=<%%~A.online
		start /MIN "" "%bincd%\Notification.exe" -title "%%~A is !stat!" -body "Online since !gtme!   Click to dismiss." -icon Online.ico -keepopen %Notifications_Stay_Open%
)
goto display

:checkprevious
for /f "tokens=1,2 usebackq delims=." %%A in ("OnlinePlayerList.ini") do (
	find /i "%%~A" "PreviousPlayerList.ini" >nul
	if not !errorlevel!==0 (
		if exist "%%~A.playing" (
			set /p game=<"%%~A.playing"
			set stat=online and playing !game!.
		) ELSE (
			set stat=online.
		)
		set /p gtme=<%%~A.online
		start /MIN "" "%bincd%\Notification.exe" -title "%%~A is !stat!" -body "Online since !gtme!   Click to dismiss." -icon Online.ico -keepopen %Notifications_Stay_Open%
	)
)
for /f "tokens=* usebackq" %%A in ("PreviousPlayerList.ini") do (
	find /i "%%~A" "OnlinePlayerList.ini" >nul
	if not !errorlevel!==0 (
		start /MIN "" "%bincd%\Notification.exe" -title "%%~nA is offline." -body "but some other friends are online." -icon Offline.ico -keepopen n
	)
)
goto display


:alonecheckprevious
for /f "tokens=* usebackq" %%A in ("PreviousPlayerList.ini") do (
	find /i "%%~A" "OnlinePlayerList.ini" >nul
	if not !errorlevel!==0 (
		start /MIN "" "%bincd%\Notification.exe" -title "%%~nA is offline." -body "you're all alone now..." -icon Offline.ico -keepopen n
	)
)
cls
echo.>OnlinePlayerList.ini
echo [91mNo users are online [Except for you].[0m
echo.
goto menu
)



:Display
cls
echo [102;30m                   Online Users                   [0m
echo [90mStatus as of %time%
echo.
for /f "tokens=1,2* usebackq delims=." %%A in ("OnlinePlayerList.ini") do (
	if exist "%%~A.playing" (
		set /p game=<"%%~A.playing"
		set /p _tme=<"%%~A.online"
		echo [92m+%%~A[90m !_tme! [0m!game!
	) ELSE (
		echo [92m+%%~A[90m !_tme! [0m
	)
)
echo.
:menu
echo G] Display Game !CurrentGame!
echo [91mX[0m] Go Offline
echo S] Settings
choice /c GSQX /d Q /t %TTL% /n >nul
if %errorlevel%==3 goto refresh
if %errorlevel%==1 (
	echo Enter Game Name
	set /p CurrentGame=">"
	set CurrentGame=[!CurrentGame!]
	echo !CurrentGame! >"%usr%.playing"
	call :ftp "nul" "cd Online" "put %usr%.playing"
	goto display
)
if %errorlevel%==2 goto settings
if %errorlevel%==4 goto offline

:offline
cls
echo Going Offline . . .
call :ftp "nul" "cd Online" "rm %usr%.Online" "rm %usr%.Playing"
call "%bincd%\CMDS" /tk "Lukes Friend Checker - Background Listener"




:notif
rem notif "title" "message" "icon" "extra"
notification.exe -title "New Message on CB Chattio" -body "New Messages on the CB chattio. Click to open." -icon icon.ico -keepopen n -start "%dir%"
exit /b
 
:ftp "outputfile(or nul)" commands
set out=%~1
shift
echo. 2>temp.ftp 1>nul
:ftploop
if "%~1"=="" goto endftploop
(echo %~1)>>temp.ftp
shift
goto ftploop
:endftploop
(echo exit)>>temp.ftp
echo Set oShell = CreateObject ("Wscript.Shell") >WinSCP.vbs
echo Dim strArgs>>WinSCP.vbs
(
echo strArgs = "cmd.exe /c """"%bincd%\winscp.com"" /ini=nul /script=""%cd%\temp.ftp"" /passive=off /tls ftp://%ftpusr%:%ftppass%@%server%"" >%out%"
)>>WinSCP.vbs
echo oShell.Run strArgs, 0, true>>WinSCP.vbs
cscript WinSCP.vbs >VBResult
if %errorlevel%==0 (
	del /f /q VBResult
) ELSE (
	echo %time% %date% >> VBResult
	ren VBResult VBS-Error-%random%.txt
)
::"%bincd%\WinSCP.com" /open /ini=nul /script=temp.ftp  >%out%
del /f /q temp.ftp
del /f /q WinSCP.vbs
exit /b