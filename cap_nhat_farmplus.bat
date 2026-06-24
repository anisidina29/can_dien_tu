@echo off
chcp 65001 >nul
echo ========================================
echo   CAP NHAT THONG TIN - FARMPLUS
echo ========================================
echo.

:: Dùng PowerShell 32-bit (bắt buộc cho Access JET OLEDB)
C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe ^
    -ExecutionPolicy Bypass ^
    -File "%~dp0cap_nhat_farmplus.ps1"

pause
