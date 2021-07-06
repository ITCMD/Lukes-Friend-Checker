@echo off
title Lukes Friend Checker - Background Listener
call ..\Data\settings.cmd
set /p usr=<..\Data\usr.ini
set usr=%usr: =%
set bincd=%cd%
cls
echo If you can see this, you probably did something wrong. But that's okay, I forgive you.
echo.
echo This program runs in the background to check and see if Lukes Friends Checker is running.
echo If its not, it makes sure that you were logged off correctly. It should not use any resources except when logging you off.
echo running in %cd%
timeout /t 3

:loop
call CMDS /ts "Lukes Friends Checker [%usr%]"
if %errorlevel%==1 goto checkoffline
timeout /t 120
goto loop

:checkoffline
call :ftp "usertestbg" "cd Online" "stat %usr%.Online"
find "File or directory not found." "usertestbg" >nul
if "%errorlevel%"=="0" (
	echo User went offline correctly. Exiting . . .
	del /f /q usertestbg
	exit
)
del /f /q usertestbg
echo User did not go offline before closing. That's okay, we'll do it for them here.
echo call :ftp "nul" "cd Online" "rm %usr%.online" "rm %usr%.playing"
call :ftp "nul" "cd Online" "rm %usr%.online" "rm %usr%.playing"
echo all set! Exiting!
timeout /t 4 >nul
exit












:ftp "outputfile(or nul)" commands
set ftpnum=%random%%random%%random%
set out=%~1
shift
echo. 2>temp%ftpnum%.ftp 1>nul
:ftploop
if "%~1"=="" goto endftploop
(echo %~1)>>temp%ftpnum%.ftp
shift
goto ftploop
:endftploop
(echo exit)>>temp%ftpnum%.ftp
echo Set oShell = CreateObject ("Wscript.Shell") >WinSCP.vbs
echo Dim strArgs>>WinSCP.vbs
(
echo strArgs = "cmd.exe /c """"%bincd%\winscp.com"" /ini=nul /script=""%cd%\temp%ftpnum%.ftp"" /passive=off /tls ftp://%ftpusr%:%ftppass%@%server%"" >%out%"
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
del /f /q temp%ftpnum%.ftp
del /f /q WinSCP.vbs
exit /b