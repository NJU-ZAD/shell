::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAnk
::fBw5plQjdG8=
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFAFVSDimOXixEroM1MbR2mxHY8jmmWXiicHewrHu
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off
setlocal enabledelayedexpansion

set "file=NJU_user"
if not exist %file% (
    echo File %file% does not exist, creating %file%...
    echo.> %file%
)

set "username="
set "password="
set /a count=0

for /f "tokens=*" %%A in (%file%) do (
    set /a count+=1
    if !count! equ 1 set "username=%%A"
    if !count! equ 2 set "password=%%A"
)

if "%username%"=="" (
    set /p username=Please enter your username: 
    echo %username%> %file%
)
if "%password%"=="" (
    set /p password=Please enter your password: 
    echo %password%>> %file%
)

if "%count%" lss 2 (
    (
        echo %username%
        echo %password%
    ) > %file%
)

if not "%username%"=="" if not "%password%"=="" (
    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Already running with administrator privileges
    ) else (
        echo Requesting administrator privileges...
        powershell -Command "Start-Process '%~f0' -Verb RunAs"
        exit /b
    )
    curl -s "http://p2.nju.edu.cn/portal_io/logout"
    timeout /t 3 /nobreak
    curl -s "http://p2.nju.edu.cn/api/portal/v1/login" -d "{\"domain\":\"default\",\"username\":\"%username%\",\"password\":\"%password%\"}"
    echo.
    echo.
    echo OK
    pause
)