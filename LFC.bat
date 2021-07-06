@echo off
title Lukes Friend Checker - Offline
setlocal enabledelayedexpansion
@mode con lines=16 cols=50
:menu
cls
call :cd
echo [102;30m              Luke's Friend Checker               [0m
if exist ..\Data\usr.ini (
	set /p usr=<..\Data\usr.ini
	set usr=%usr: =%
	set bincd=%cd%
) Else (
	set usr=User
)
echo.
echo This tool is designed to tell you when your
echo friends are available to hang out digitally.
echo.
echo [4mWhen you are available[0m go online and you will see
echo if any other users are online too you'll see them.
echo If a user goes online or offline while you are
echo online, you'll get a notification.
echo.
echo To avoid distractions, you cannot see if other
echo users are online unless you are. For the best
echo results [4malways[0m use this tool and be honest.
echo.
echo Go online now? (Press Y).
choice /n >nul 2>nul
if %errorlevel%==1 "%bincd%..\Friend Checker.bat"
goto menu

:cd
rem setup script will add main programs dir below this line.
