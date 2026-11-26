@echo off
chcp 65001 >nul
setlocal
title GMod Addon Manager Pro - Installer
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install.ps1"
pause
