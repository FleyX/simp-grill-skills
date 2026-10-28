@echo off
setlocal EnableExtensions

if "%~1"=="/?" goto usage
if "%~1"=="-h" goto usage
if "%~1"=="--help" goto usage
if not "%~2"=="" goto usage_error

set "TARGET=%USERPROFILE%\.agents\skills"
if not "%~1"=="" set "TARGET=%~1"

if not exist "%TARGET%\." mkdir "%TARGET%"
if errorlevel 1 exit /b 1

for /d %%D in ("%~dp0simp-*") do (
    if exist "%%~fD\SKILL.md" (
        if not exist "%TARGET%\%%~nxD\." mkdir "%TARGET%\%%~nxD"
        if errorlevel 1 exit /b 1
        xcopy /E /I /Y /Q "%%~fD\*" "%TARGET%\%%~nxD\" >nul
        if errorlevel 1 exit /b 1
        echo Installed %%~nxD to "%TARGET%\%%~nxD"
    )
)

exit /b 0

:usage
echo Usage: %~nx0 [target-directory]
exit /b 0

:usage_error
echo Usage: %~nx0 [target-directory] 1>&2
exit /b 1
