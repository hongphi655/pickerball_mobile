SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

-- =====================================================
-- PCM (Badminton Court Management) - Sample Data Script
-- =====================================================

-- 1. INSERT SAMPLE USERS (AspNetUsers)
DECLARE @AdminId NVARCHAR(128) = 'admin-001';
DECLARE @UserId1 NVARCHAR(128) = 'user-001';
DECLARE @UserId2 NVARCHAR(128) = 'user-002';
DECLARE @UserId3 NVARCHAR(128) = 'user-003';
DECLARE @UserId4 NVARCHAR(128) = 'user-004';
DECLARE @UserId5 NVARCHAR(128) = 'user-005';

INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnd, LockoutEnabled, AccessFailedCount)
VALUES 
(@AdminId, N'admin', N'ADMIN', N'admin@pcm.com', N'ADMIN@PCM.COM', 1, N'AQAAAAIAAYagAAAAEO5K8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1=', N'admin-stamp', N'admin-stamp', NULL, 0, 0, NULL, 1, 0),
(@UserId1, N'john_doe', N'JOHN_DOE', N'john@example.com', N'JOHN@EXAMPLE.COM', 1, N'AQAAAAIAAYagAAAAEO5K8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1=', N'user-stamp-1', N'user-stamp-1', NULL, 0, 0, NULL, 1, 0),
(@UserId2, N'jane_smith', N'JANE_SMITH', N'jane@example.com', N'JANE@EXAMPLE.COM', 1, N'AQAAAAIAAYagAAAAEO5K8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1=', N'user-stamp-2', N'user-stamp-2', NULL, 0, 0, NULL, 1, 0),
(@UserId3, N'mike_wilson', N'MIKE_WILSON', N'mike@example.com', N'MIKE@EXAMPLE.COM', 1, N'AQAAAAIAAYagAAAAEO5K8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1=', N'user-stamp-3', N'user-stamp-3', NULL, 0, 0, NULL, 1, 0),
(@UserId4, N'sarah_jones', N'SARAH_JONES', N'sarah@example.com', N'SARAH@EXAMPLE.COM', 1, N'AQAAAAIAAYagAAAAEO5K8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1=', N'user-stamp-4', N'user-stamp-4', NULL, 0, 0, NULL, 1, 0),
(@UserId5, N'tom_brown', N'TOM_BROWN', N'tom@example.com', N'TOM@EXAMPLE.COM', 1, N'AQAAAAIAAYagAAAAEO5K8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1Z8Z1=', N'user-stamp-5', N'user-stamp-5', NULL, 0, 0, NULL, 1, 0);

-- 2. INSERT ASPNETUSERROLES
DECLARE @AdminRoleId NVARCHAR(128) = (SELECT Id FROM AspNetRoles WHERE Name = 'Admin');
DECLARE @UserRoleId NVARCHAR(128) = (SELECT Id FROM AspNetRoles WHERE Name = 'User');

INSERT INTO AspNetUserRoles (UserId, RoleId)
VALUES 
(@AdminId, @AdminRoleId),
(@UserId1, @UserRoleId),
(@UserId2, @UserRoleId),
(@UserId3, @UserRoleId),
(@UserId4, @UserRoleId),
(@UserId5, @UserRoleId);

-- 3. INSERT MEMBERS with IDENTITY_INSERT to ensure IDs 1-6
SET IDENTITY_INSERT [001_Members] ON;
INSERT INTO [001_Members] (Id, FullName, JoinDate, RankLevel, IsActive, UserId, Tier, WalletBalance, TotalSpent, AvatarUrl)
VALUES 
(1, N'Nguyễn Văn Admin', '2025-01-01', 10.0, 1, @AdminId, N'Platinum', 5000000.0, 1000000.0, NULL),
(2, N'John Doe', '2025-01-15', 7.5, 1, @UserId1, N'Gold', 2000000.0, 500000.0, NULL),
(3, N'Jane Smith', '2025-01-10', 8.0, 1, @UserId2, N'Gold', 1500000.0, 750000.0, NULL),
(4, N'Mike Wilson', '2025-01-20', 6.0, 1, @UserId3, N'Silver', 1000000.0, 300000.0, NULL),
(5, N'Sarah Jones', '2025-01-25', 7.0, 1, @UserId4, N'Silver', 800000.0, 400000.0, NULL),
(6, N'Tom Brown', '2025-01-28', 5.5, 1, @UserId5, N'Standard', 500000.0, 200000.0, NULL);
SET IDENTITY_INSERT [001_Members] OFF;

-- 4. INSERT COURTS
INSERT INTO [001_Courts] (Name, Location, IsActive, Description, PricePerHour)
VALUES 
(N'Sân A - Sàn gỗ', N'Tầng 1, Khu vực 1', 1, N'Sân cầu lông chuyên nghiệp với sàn gỗ cao cấp', 200000.0),
(N'Sân B - Sàn gỗ', N'Tầng 1, Khu vực 2', 1, N'Sân cầu lông với sàn gỗ, ánh sáng tốt', 200000.0),
(N'Sân C - Sàn composite', N'Tầng 2, Khu vực 1', 1, N'Sân cầu lông sàn composite, giá tốt', 150000.0),
(N'Sân D - Sàn composite', N'Tầng 2, Khu vực 2', 1, N'Sân cầu lông sàn composite, ánh sáng chuẩn', 150000.0),
(N'Sân E - VIP', N'Tầng 3, Khu vực VIP', 1, N'Sân VIP với đầy đủ tiện nghi cao cấp', 300000.0);

-- 5. INSERT BOOKINGS
DECLARE @date1 DATETIME = DATEADD(DAY, 1, CAST(GETDATE() AS DATETIME));
DECLARE @date2 DATETIME = DATEADD(DAY, 2, CAST(GETDATE() AS DATETIME));
DECLARE @date3 DATETIME = DATEADD(DAY, 3, CAST(GETDATE() AS DATETIME));
DECLARE @date4 DATETIME = DATEADD(DAY, -1, CAST(GETDATE() AS DATETIME));

INSERT INTO [001_Bookings] (CourtId, MemberId, StartTime, EndTime, TotalPrice, IsRecurring, Status, CreatedDate)
VALUES 
-- Past bookings (completed)
(1, 2, DATEADD(HOUR, 7, @date4), DATEADD(HOUR, 8, @date4), 200000.0, 0, N'Completed', DATEADD(DAY, -5, GETDATE())),
(2, 3, DATEADD(HOUR, 18, @date4), DATEADD(HOUR, 19, @date4), 200000.0, 0, N'Completed', DATEADD(DAY, -4, GETDATE())),
(3, 4, DATEADD(HOUR, 9, @date4), DATEADD(HOUR, 10, @date4), 150000.0, 0, N'Completed', DATEADD(DAY, -3, GETDATE())),

-- Current/Upcoming bookings
(1, 2, DATEADD(HOUR, 7, @date1), DATEADD(HOUR, 8, @date1), 200000.0, 0, N'Confirmed', GETDATE()),
(2, 3, DATEADD(HOUR, 19, @date1), DATEADD(HOUR, 21, @date1), 400000.0, 0, N'Confirmed', GETDATE()),
(4, 4, DATEADD(HOUR, 10, @date2), DATEADD(HOUR, 11, @date2), 150000.0, 0, N'Confirmed', GETDATE()),
(5, 5, DATEADD(HOUR, 14, @date2), DATEADD(HOUR, 16, @date2), 600000.0, 0, N'Confirmed', GETDATE()),
(1, 6, DATEADD(HOUR, 16, @date3), DATEADD(HOUR, 17, @date3), 200000.0, 0, N'Pending', GETDATE()),
(3, 2, DATEADD(HOUR, 6, @date3), DATEADD(HOUR, 8, @date3), 300000.0, 0, N'Pending', GETDATE());

-- 6. INSERT WALLET TRANSACTIONS
INSERT INTO [001_WalletTransactions] (MemberId, Amount, Type, Status, Description, CreatedDate)
VALUES 
-- Member 2 (John) - Deposits
(2, 500000.0, N'Deposit', N'Completed', N'Nạp tiền ví', DATEADD(DAY, -30, GETDATE())),
(2, 1000000.0, N'Deposit', N'Completed', N'Nạp tiền ví', DATEADD(DAY, -15, GETDATE())),

-- Member 2 - Payments for bookings
(2, 200000.0, N'Payment', N'Completed', N'Thanh toán booking sân A', DATEADD(DAY, -5, GETDATE())),
(2, 200000.0, N'Payment', N'Completed', N'Thanh toán booking sân A', DATEADD(DAY, -1, GETDATE())),
(2, 300000.0, N'Payment', N'Pending', N'Thanh toán booking sân C (2 giờ)', GETDATE()),

-- Member 3 (Jane) - Deposits
(3, 1000000.0, N'Deposit', N'Completed', N'Nạp tiền ví', DATEADD(DAY, -20, GETDATE())),

-- Member 3 - Payments
(3, 200000.0, N'Payment', N'Completed', N'Thanh toán booking sân B', DATEADD(DAY, -4, GETDATE())),
(3, 400000.0, N'Payment', N'Completed', N'Thanh toán booking sân B (2 giờ)', DATEADD(DAY, -1, GETDATE())),

-- Member 4 (Mike) - Deposits
(4, 500000.0, N'Deposit', N'Completed', N'Nạp tiền ví', DATEADD(DAY, -25, GETDATE())),

-- Member 4 - Payments
(4, 150000.0, N'Payment', N'Completed', N'Thanh toán booking sân C', DATEADD(DAY, -3, GETDATE())),
(4, 150000.0, N'Payment', N'Completed', N'Thanh toán booking sân D', DATEADD(DAY, -1, GETDATE())),

-- Member 5 (Sarah) - Deposits
(5, 600000.0, N'Deposit', N'Completed', N'Nạp tiền ví', DATEADD(DAY, -10, GETDATE())),

-- Member 5 - Payment
(5, 400000.0, N'Payment', N'Pending', N'Thanh toán booking sân E (2 giờ)', GETDATE()),

-- Member 6 (Tom) - Deposits
(6, 300000.0, N'Deposit', N'Completed', N'Nạp tiền ví', DATEADD(DAY, -5, GETDATE()));

-- 7. INSERT TOURNAMENTS
INSERT INTO [001_Tournaments] (Name, StartDate, EndDate, Format, EntryFee, PrizePool, Status, CreatedDate)
VALUES 
(N'Giải Badminton Tháng 2 - Hạng A', DATEADD(DAY, 7, GETDATE()), DATEADD(DAY, 14, GETDATE()), N'Knockout', 500000.0, 8000000.0, N'Registration', GETDATE()),
(N'Giải Badminton Tháng 2 - Hạng B', DATEADD(DAY, 10, GETDATE()), DATEADD(DAY, 17, GETDATE()), N'RoundRobin', 300000.0, 4800000.0, N'Registration', GETDATE()),
(N'Giải Badminton Tháng 2 - Nữ', DATEADD(DAY, 8, GETDATE()), DATEADD(DAY, 15, GETDATE()), N'Knockout', 250000.0, 3000000.0, N'Registration', GETDATE()),
(N'Giải Badminton Tháng 1 - Hạng A', DATEADD(DAY, -14, GETDATE()), DATEADD(DAY, -7, GETDATE()), N'Knockout', 500000.0, 8000000.0, N'Completed', DATEADD(DAY, -20, GETDATE()));

-- 8. INSERT TOURNAMENT PARTICIPANTS
INSERT INTO [001_TournamentParticipants] (TournamentId, MemberId, RegisteredDate, PaymentStatusCompleted)
VALUES 
-- Giải Hạng A
(1, 2, GETDATE(), 1),
(1, 3, GETDATE(), 1),
(1, 4, GETDATE(), 1),

-- Giải Hạng B
(2, 4, GETDATE(), 1),
(2, 5, GETDATE(), 1),
(2, 6, GETDATE(), 1),

-- Giải Nữ
(3, 3, GETDATE(), 1),
(3, 5, GETDATE(), 1),

-- Giải Tháng 1 (Completed)
(4, 2, DATEADD(DAY, -20, GETDATE()), 1),
(4, 3, DATEADD(DAY, -20, GETDATE()), 1),
(4, 4, DATEADD(DAY, -20, GETDATE()), 1);

-- Print confirmation
PRINT '========================================';
PRINT 'Dữ liệu mẫu đã được thêm thành công!';
PRINT '========================================';
PRINT 'AspNetUsers: 1 admin + 5 users';
PRINT 'Members: 6 members';
PRINT 'Courts: 5 courts';
PRINT 'Bookings: 9 bookings';
PRINT 'Wallet Transactions: 15 transactions';
PRINT 'Tournaments: 4 tournaments';
PRINT 'Tournament Participants: 12 participants';
PRINT '========================================';
PRINT 'Tài khoản đăng nhập:';
PRINT 'Admin: admin / Password123!';
PRINT 'User 1: john_doe / Password123!';
PRINT 'User 2: jane_smith / Password123!';
PRINT 'User 3: mike_wilson / Password123!';
PRINT 'User 4: sarah_jones / Password123!';
PRINT 'User 5: tom_brown / Password123!';
PRINT '========================================';
