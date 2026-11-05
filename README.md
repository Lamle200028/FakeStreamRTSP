# FakeStreamRTSP 📹📡

Dự án giả lập và chuyển đổi luồng hình ảnh/âm thanh từ **USB Camera (Webcam)** cắm trên máy tính thành một luồng **RTSP Stream** tiêu chuẩn, độ trễ cực thấp (*Zero Latency*).

---

## 🌟 Tính năng nổi bật

- 🚀 **Độ trễ siêu thấp (< 0.2s)**: Sử dụng preset `ultrafast` và `zerolatency` của thư viện mã hóa H.264.
- 🔊 **Hỗ trợ cả Video & Audio**: Truyền tải đồng thời hình ảnh (Full HD 1080p H.264) và âm thanh từ mic của camera (AAC stereo).
- 🔄 **Khởi động 1-click**: Tự động gọi FFmpeg khi bật MediaMTX qua file `start_stream.bat`.
- 🌐 **Tương thích cao**: Xem được trên mọi phần mềm/hệ thống hỗ trợ RTSP như:
  - VLC Media Player
  - OpenCV / Python (AI, YOLO, Object Detection)
  - Home Assistant / NVR / Agent DVR / iSpy

---

## 🏗️ Kiến trúc hoạt động

```
[USB Camera / Mic] 
        │ (DirectShow)
        ▼
   [FFmpeg] ──── (Mã hóa H.264 + AAC) ────► [MediaMTX RTSP Server] (:8554)
                                                     │
                                                     ▼
                                        [RTSP Client: VLC / OpenCV]
                                          rtsp://localhost:8554/live
```

---

## 📋 Yêu cầu hệ thống

- Hệ điều hành: **Windows 10 / 11**
- **FFmpeg**: Công cụ thu hình ảnh từ camera và mã hóa stream.
- **MediaMTX**: RTSP Server trung gian siêu nhẹ, mã nguồn mở.

---

## 🚀 Hướng dẫn cài đặt chi tiết

### Bước 1: Cài đặt công cụ

Mở PowerShell trên máy tính và cài đặt nhanh qua `winget` (không cần quyền Admin):

```powershell
# Cài đặt FFmpeg
winget install Gyan.FFmpeg

# Cài đặt MediaMTX
winget install bluenviron.mediamtx
```

> **Cách thủ công (nếu không dùng winget):**
> 1. Tải [FFmpeg](https://www.gyan.dev/ffmpeg/builds/) (bản release full build) và thêm thư mục `bin` vào biến môi trường `PATH`.
> 2. Tải [MediaMTX Windows AMD64](https://github.com/bluenviron/mediamtx/releases), giải nén file `mediamtx.exe` đặt vào cùng thư mục với dự án này.

---

### Bước 2: Tìm tên USB Camera của bạn

Mỗi máy tính hoặc camera sẽ có tên hiển thị khác nhau trong hệ thống DirectShow của Windows. Chạy lệnh sau để liệt kê:

```cmd
ffmpeg -list_devices true -f dshow -i dummy
```

Tìm dòng tương tự như sau trong kết quả:
```text
[dshow @ ...] "XWF 1080P  PC Camera" (video)
[dshow @ ...] "Microphone (XWF 1080P  PC Camera)" (audio)
```

---

### Bước 3: Cấu hình `mediamtx.yml`

Mở file `mediamtx.yml` và kiểm tra cấu hình luồng `live`:

```yaml
paths:
  live:
    runOnInit: ffmpeg -f dshow -rtbufsize 100M -i video="TÊN_CAMERA_CỦA_BẠN":audio="TÊN_MICROPHONE_CỦA_BẠN" -c:v libx264 -preset ultrafast -tune zerolatency -pix_fmt yuv420p -c:a aac -f rtsp rtsp://127.0.0.1:8554/live
    runOnInitRestart: yes
```

> 💡 **Mẹo:**
> - Nếu camera của bạn chỉ cần hình ảnh (không cần âm thanh), bỏ phần `:audio="..."` và `-c:a aac`:
>   ```yaml
>   runOnInit: ffmpeg -f dshow -rtbufsize 100M -i video="TÊN_CAMERA_CỦA_BẠN" -c:v libx264 -preset ultrafast -tune zerolatency -pix_fmt yuv420p -f rtsp rtsp://127.0.0.1:8554/live
>   ```
> - Lưu ý các khoảng trắng trong tên camera (ví dụ `"XWF 1080P  PC Camera"` có 2 dấu cách).

---

### Bước 4: Khởi động phát luồng RTSP

- Chỉ cần click đúp vào file **`start_stream.bat`**.
- Server sẽ khởi động và tự động mở camera phát luồng RTSP.

---

## 📺 Cách kết nối và xem luồng RTSP

### 1. Đường dẫn luồng (RTSP URL)
- **Xem trên máy tính đang chạy server**:
  ```text
  rtsp://127.0.0.1:8554/live
  # hoặc
  rtsp://localhost:8554/live
  ```
- **Xem từ máy khác trong cùng mạng LAN**:
  ```text
  rtsp://<ĐỊA_CHỈ_IP_CỦA_MÁY>:8554/live
  ```
  *(Ví dụ: `rtsp://192.168.1.100:8554/live`)*

---

### 2. Xem bằng VLC Media Player
1. Mở **VLC**.
2. Nhấn tổ hợp phím **`Ctrl + N`** (Menu `Media` -> `Open Network Stream...`).
3. Dán URL: `rtsp://127.0.0.1:8554/live`.
4. Bấm **Play**.

---

### 3. Đọc luồng bằng Python (OpenCV)
```python
import cv2

rtsp_url = "rtsp://127.0.0.1:8554/live"
cap = cv2.VideoCapture(rtsp_url)

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        print("Không nhận được tín hiệu RTSP...")
        break
    
    cv2.imshow("Fake RTSP Camera Stream", frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
```

---

## 🛠️ Xử lý lỗi thường gặp (Troubleshooting)

1. **Lỗi `Device or resource busy` / Camera không sáng đèn:**  
   Camera đang bị ứng dụng khác chiếm quyền sử dụng (Zoom, Teams, trình duyệt, ứng dụng Camera của Windows). Hãy đóng các ứng dụng đó lại trước khi chạy script.
2. **Lỗi `bind: Only one usage of each socket address`:**  
   Cổng `8554` đang bị chiếm bởi một phiên bản MediaMTX chạy ngầm trước đó. Mở Task Manager tìm và tắt tiến trình `mediamtx.exe` rồi chạy lại.
3. **Máy khác cùng mạng LAN không kết nối được:**  
   Hãy kiểm tra Windows Firewall và cho phép cổng `8554` (TCP/UDP) đi qua.

---

## 📄 License
Dự án được phát hành theo giấy phép [MIT](LICENSE).
