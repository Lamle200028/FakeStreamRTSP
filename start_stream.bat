@echo off
title RTSP USB Camera Stream (Optimized 30 FPS)
cd /d "%~dp0"

echo ==========================================================
echo        KHOI DONG LUONG RTSP (DA TOI UU 30 FPS MUOT MA)
echo ==========================================================
echo  Camera   : XWF 1080P  PC Camera
echo  Che do   : MJPEG 1080p 30fps -> H.264 Zero Latency
echo  RTSP URL : rtsp://127.0.0.1:8554/live
echo.
echo  Nhan Ctrl+C de dung stream.
echo ==========================================================
echo.

mediamtx.exe mediamtx.yml
pause
