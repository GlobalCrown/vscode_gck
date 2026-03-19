@echo off
setlocal

title GCKontrol Dev

pushd %~dp0\..

:: Prefer repo-local Node runtime when available
if exist "%~dp0\..\tools\node-v22.22.1-win-x64\node.exe" (
	set "PATH=%~dp0\..\tools\node-v22.22.1-win-x64;%PATH%"
)

:: Support custom VS Build Tools location used on this machine
if "%vs2022_install%"=="" if exist "D:\BuildTools\MSBuild\Current\Bin\MSBuild.exe" (
	set "vs2022_install=D:\BuildTools"
)

:: Get electron, compile, built-in extensions
if "%VSCODE_SKIP_PRELAUNCH%"=="" (
	node build/lib/preLaunch.ts
)

set "NAMESHORT="
for /f "tokens=2 delims=:," %%a in ('findstr /R /C:"\"nameShort\":.*" product.json') do if not defined NAMESHORT set "NAMESHORT=%%~a"
set NAMESHORT=%NAMESHORT: "=%
set NAMESHORT=%NAMESHORT:"=%.exe
set CODE=".build\electron\%NAMESHORT%"

:: Verify executable exists
if not exist %CODE% (
	echo ERROR: %CODE% not found. Run without VSCODE_SKIP_PRELAUNCH or run: npm run electron
	goto end
)

:: Manage built-in extensions
if "%~1"=="--builtin" goto builtin

:: Configuration
set NODE_ENV=development
set VSCODE_DEV=1
set VSCODE_CLI=1
set ELECTRON_ENABLE_LOGGING=1
set ELECTRON_ENABLE_STACK_DUMPING=1

set DISABLE_TEST_EXTENSION="--disable-extension=vscode.vscode-api-tests"
for %%A in (%*) do (
	if "%%~A"=="--extensionTestsPath" (
		set DISABLE_TEST_EXTENSION=""
	)
)

:: Launch Code
%CODE% . %DISABLE_TEST_EXTENSION% %*
goto end

:builtin
%CODE% build/builtin

:end

popd

endlocal
