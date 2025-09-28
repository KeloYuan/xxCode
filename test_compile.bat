@echo off
echo Starting compilation test...
hvigor assembleHap > compile_output.txt 2>&1
if %ERRORLEVEL% EQU 0 (
    echo BUILD SUCCESS
    type compile_output.txt | findstr /C:"BUILD SUCCESSFUL"
) else (
    echo BUILD FAILED
    type compile_output.txt | findstr /C:"ERROR"
    type compile_output.txt | findstr /C:"WARN"
)
