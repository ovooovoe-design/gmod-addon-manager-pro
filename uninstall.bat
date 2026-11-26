@echo off
chcp 65001 >nul
setlocal
title GMod Addon Manager Pro - Uninstaller
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\uninstall.ps1"
pause
