@echo off
title RTSP USB Camera Stream
cd /d "%~dp0"

echo ==========================================================
echo           KHOI DONG LUONG RTSP CHO USB CAMERA
echo ==========================================================
echo  Camera: XWF 1080P  PC Camera
echo  RTSP URL (tren may nay): rtsp://127.0.0.1:8554/live
echo  RTSP URL (mang LAN)   : rtsp://localhost:8554/live
echo.
echo  De tat stream, hay dong cua so nay hoac nhan Ctrl+C.
echo ==========================================================
echo.

mediamtx.exe mediamtx.yml
pause

