# 📱 PCM Mobile - Hướng Dẫn Sử Dụng Tính Năng Mới

## 🔐 Đăng Nhập

**Test Accounts:**
```
Tài khoản Admin:
- Username: admin
- Password: Test123!

Tài khoản User:
- Username: testuser2
- Password: Test123!
```

**Flow:**
1. Mở app
2. Nhập username/password
3. Click "Đăng nhập"
4. ✅ Vào dashboard (không bị redirect)

---

## 🏠 Trang Chủ (Dashboard)

### Admin View:
- Hiển thị thống kê (sân, thành viên, ví, doanh thu)
- Pull-to-refresh để cập nhật
- Menu quản lý dưới đáy

### User View:
- Hiển thị số dư ví
- Thông tin cá nhân
- Pull-to-refresh

---

## 🔍 Tìm Kiếm & Lọc Sân (Đặt Sân Tab)

### Cách sử dụng:

**1. Mở Filter Panel:**
```
- Click tab "Đặt Sân"
- Danh sách sân hiện lên
```

**2. Tìm Kiếm:**
```
- Nhập tên sân (vd: "Sân A")
- Nhập địa điểm (vd: "Quận 1")
- Kết quả tự động lọc
```

**3. Lọc Theo Giá:**
```
- Kéo slider "Giá tối đa"
- Chỉ hiện sân ≤ giá đó
```

**4. Lọc Theo Đánh Giá:**
```
- Click sao 1-5 ⭐
- Chỉ hiện sân ≥ đánh giá đó
```

**5. Sắp Xếp:**
```
- Enable "Sắp xếp theo giá"
- Sân sắp xếp từ rẻ → đắt
```

**6. Reset:**
```
- Click "Đặt lại bộ lọc"
- Quay về danh sách đầy đủ
```

---

## 🔔 Hệ Thống Thông Báo

### Icon Chuông:
```
- Top right của AppBar
- Badge đỏ = số thông báo chưa đọc
- Click → mở panel thông báo
```

### Panel Thông Báo:
```
- Cuộn để xem tất cả
- Click để đánh dấu đã đọc
- Swipe trái → xóa thông báo
- "Đánh dấu tất cả" → mark all
```

### Loại Thông Báo:
```
🟢 Success (thành công) - Xanh
🔴 Error (lỗi) - Đỏ
🟠 Warning (cảnh báo) - Cam
🔵 Booking (đặt sân) - Xanh dương
🟣 Payment (thanh toán) - Tím
ℹ️ Info (thông tin) - Xám
```

### Ví dụ:
```
Đặt sân thành công
→ ✅ Success notification hiện

Hết tiền
→ ❌ Error notification hiện

Hôm nay hết slot
→ ⚠️ Warning notification hiện
```

---

## 🌙 Chế Độ Tối (Dark Mode)

### Bật/Tắt:
```
1. Vào Profile (icon người ở bottom navigation)
2. Tìm "Chế độ tối"
3. Toggle switch
4. App đổi ngay lập tức
```

### Gì thay đổi:
```
Light Mode (Mặc định):
- Nền hồng nhạt (#FDF5FB)
- Chữ đen
- Card trắng

Dark Mode:
- Nền đen (#121212)
- Chữ trắng
- Card xám (#1E1E1E)
```

### Persist Preference:
```
- Tắt app, bật lại → vẫn là dark mode
- Không cần bật lại mỗi lần
```

---

## 👤 Profile & Cài Đặt

### Thông Tin:
```
- Tên
- Email
- Ảnh đại diện (nếu có)
```

### Cài Đặt:
```
✓ Chế độ tối (Dark Mode)
✓ Thông báo (Notifications)
ℹ️ Thông tin ứng dụng
🚪 Đăng xuất
```

### Đăng Xuất:
```
1. Click "Đăng xuất"
2. Xác nhận
3. Quay về login screen
```

---

## 📱 Navigation

### Bottom Navigation Bar:

**Admin:**
```
🏠 Trang chủ → Dashboard
📋 Đặt Sân → Manage bookings
⚽ Giải Đấu → Tournaments
💼 Ví → Wallet
👤 Hồ sơ → Profile
```

**User:**
```
🏠 Trang chủ → Dashboard
📅 Đặt Sân → Book courts
💼 Ví → Wallet
👤 Hồ sơ → Profile
```

### Lưu ý:
```
✅ Clicking vào item → mở screen tương ứng
✅ KHÔNG bị redirect sang login
✅ Navigation mượt mà, không treo
```

---

## 🐛 Troubleshooting

### Problem: "Session hết hạn"
```
Nguyên nhân: Token đã hết hạn
Giải pháp: Click "Đăng nhập lại" → nhập lại credentials
```

### Problem: Thông báo không hiện
```
Nguyên nhân: Notification disabled hoặc lỗi API
Giải pháp: 
- Check Profile → Notification toggle ON
- Restart app
- Check backend logs
```

### Problem: Dark mode không save
```
Nguyên nhân: SharedPreferences lỗi
Giải pháp:
- Xóa app data
- Reinstall app
- Bật lại dark mode
```

### Problem: Lọc sân không hoạt động
```
Nguyên nhân: CourtProvider lỗi hoặc data trống
Giải pháp:
- Pull-to-refresh để reload data
- Check "Đặt lại bộ lọc"
- Restart app
```

---

## 💡 Tips & Tricks

### 1. Pull-to-Refresh:
```
Kéo từ trên xuống trên bất kỳ list
→ Cập nhật dữ liệu mới nhất
```

### 2. Quick Search:
```
Không cần mở filter panel
Chỉ cần gõ tên sân
Kết quả tự động lọc
```

### 3. Combine Filters:
```
Search "Sân" + Filter Price ≤ 200k
+ Sort by Price
→ Kết quả chính xác nhất
```

### 4. Notification Categories:
```
Chỉ muốn xem booking notifications?
Use: getNotificationsByType('booking')
```

### 5. Theme Consistency:
```
App tự điều chỉnh theme
Dựa vào system setting (nếu muốn)
Hoặc manual toggle
```

---

## 🚀 Performance Tips

### 1. Caching:
```
Court list được cache 5 phút
Không cần reload mỗi lần
Kéo-to-refresh để force refresh
```

### 2. Filtering:
```
Filter đơn giản & nhanh
Không ảnh hưởng đến API
Xử lý trên client-side
```

### 3. Notifications:
```
Lưu trong memory
Nhanh để add/delete
Không query database mỗi lần
```

---

## 📞 Support

**Nếu gặp vấn đề:**
1. Check Troubleshooting section trên
2. Restart app
3. Clear cache: Settings → Apps → PCM → Clear Cache
4. Reinstall nếu cần

**Error messages:**
- Báo lỗi cụ thể trong app
- Giúp debug nhanh hơn
- Report trên group dự án

---

## ✅ Checklist Sử Dụng

Để đảm bảo tất cả tính năng hoạt động:

- [ ] Đăng nhập được ✅
- [ ] Không bị redirect login ✅
- [ ] Search/filter hoạt động ✅
- [ ] Notification icon có badge ✅
- [ ] Dark mode bật/tắt được ✅
- [ ] Dark mode persist sau restart ✅
- [ ] Navigation các tab không bị treo ✅
- [ ] Pull-to-refresh hoạt động ✅
- [ ] Logout → login lại bình thường ✅

---

**Version:** 1.0.0
**Last Updated:** 01/02/2026
**Status:** ✅ Ready for Production

Enjoy! 🎉
