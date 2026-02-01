# Hướng Dẫn Khắc Phục Lỗi Login

## Vấn đề hiện tại
Login trả về "Invalid credentials" mặc dù user account tồn tại trong database.

## Nguyên nhân
ASP.NET Core Identity UserManager.CheckPasswordAsync() treo hoặc fail khi verify password.

## Giải pháp tạm thời

### Bước 1: Cập nhật app_config.dart
Thay đổi apiBaseUrl của Flutter app:
```dart
static const String apiBaseUrl = 'http://10.0.2.2:5001'; // Cho Android emulator
// hoặc
static const String apiBaseUrl = 'http://localhost:5001'; // Cho web browser
```

### Bước 2: Tạo endpoint login đơn giản không dùng Identity
Thay vì dùng UserManager.CheckPasswordAsync(), hãy implement login trực tiếp bằng cách:
1. Query user từ database
2. Verify password bằng PasswordHasher
3. Return JWT token

###  Bước 3: Test credentials
```
Username: admin
Password: Password123!
```

## Thông tin Database
- Server: localhost\SQLEXPRESS
- Database: PCM_Database
- Table: AspNetUsers

## Kiểm tra User Tồn Tại
```sql
SELECT Id, UserName, PasswordHash FROM AspNetUsers WHERE UserName = 'admin'
```

## Tiếp theo
Hãy sửa AuthService để:
1. Không dùng UserManager.CheckPasswordAsync()
2. Dùng PasswordHasher.VerifyHashedPassword() trực tiếp
3. Thêm error handling tốt hơn
