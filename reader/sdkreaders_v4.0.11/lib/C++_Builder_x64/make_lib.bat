@echo off
rem Скрипт для создания "ILReaders.lib" для интегрирования в проект C++ Builder

echo generate "ILReaders.def"...
impdef "ILReaders.def" "%~dp0..\..\Bin\x64\ILReaders.dll"
if %ERRORLEVEL% GTR 0 goto :lError_gen_def

echo make "ILReaders.lib"...
implib "ILReaders.lib" "ILReaders.def"
if %ERRORLEVEL% GTR 0 goto :lError_makelib

echo Done.
goto :finish

:lError_gen_def
echo generate ILReaders.def error!
pause
goto :finish

:lError_makelib
echo make ILReaders.lib error!
pause
goto :finish

:finish
echo.
