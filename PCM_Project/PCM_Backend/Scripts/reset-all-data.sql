SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

-- Delete ALL existing test data first
DELETE FROM [001_TournamentParticipants];
DELETE FROM [001_Tournaments];
DELETE FROM [001_WalletTransactions];
DELETE FROM [001_Bookings];
DELETE FROM [001_Courts];
DELETE FROM [001_Members];
DELETE FROM AspNetUserRoles;
DELETE FROM AspNetUsers WHERE UserName IN ('admin', 'john_doe', 'jane_smith', 'mike_wilson', 'sarah_jones', 'tom_brown');

-- Reset identity seeds
DBCC CHECKIDENT ('[001_Members]', RESEED, 0);
DBCC CHECKIDENT ('[001_Courts]', RESEED, 0);
DBCC CHECKIDENT ('[001_Bookings]', RESEED, 0);
DBCC CHECKIDENT ('[001_Tournaments]', RESEED, 0);
DBCC CHECKIDENT ('[001_TournamentParticipants]', RESEED, 0);
DBCC CHECKIDENT ('[001_WalletTransactions]', RESEED, 0);

-- Password123! hash
DECLARE @PasswordHash NVARCHAR(MAX) = N'AQAAAAIAAYagAAAAEOkGj3s1w7jVdTFPJtHKFZPKO0v3qmZJZX0q0YHZ0qEBJk0uNgINdKTKYVQp3oEW7Q==';

-- Get role IDs
DECLARE @AdminRoleId NVARCHAR(128) = (SELECT Id FROM AspNetRoles WHERE Name = 'Admin');
DECLARE @UserRoleId NVARCHAR(128) = (SELECT Id FROM AspNetRoles WHERE Name = 'User');

-- Create user IDs
DECLARE @AdminId NVARCHAR(128) = NEWID();
DECLARE @UserId1 NVARCHAR(128) = NEWID();
DECLARE @UserId2 NVARCHAR(128) = NEWID();
DECLARE @UserId3 NVARCHAR(128) = NEWID();
DECLARE @UserId4 NVARCHAR(128) = NEWID();
DECLARE @UserId5 NVARCHAR(128) = NEWID();

-- Insert users with correct password hash
INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnd, LockoutEnabled, AccessFailedCount)
VALUES 
(@AdminId, N'admin', N'ADMIN', N'admin@pcm.com', N'ADMIN@PCM.COM', 1, @PasswordHash, NEWID(), NEWID(), NULL, 0, 0, NULL, 1, 0),
(@UserId1, N'john_doe', N'JOHN_DOE', N'john@example.com', N'JOHN@EXAMPLE.COM', 1, @PasswordHash, NEWID(), NEWID(), NULL, 0, 0, NULL, 1, 0),
(@UserId2, N'jane_smith', N'JANE_SMITH', N'jane@example.com', N'JANE@EXAMPLE.COM', 1, @PasswordHash, NEWID(), NEWID(), NULL, 0, 0, NULL, 1, 0),
(@UserId3, N'mike_wilson', N'MIKE_WILSON', N'mike@example.com', N'MIKE@EXAMPLE.COM', 1, @PasswordHash, NEWID(), NEWID(), NULL, 0, 0, NULL, 1, 0),
(@UserId4, N'sarah_jones', N'SARAH_JONES', N'sarah@example.com', N'SARAH@EXAMPLE.COM', 1, @PasswordHash, NEWID(), NEWID(), NULL, 0, 0, NULL, 1, 0),
(@UserId5, N'tom_brown', N'TOM_BROWN', N'tom@example.com', N'TOM@EXAMPLE.COM', 1, @PasswordHash, NEWID(), NEWID(), NULL, 0, 0, NULL, 1, 0);

-- Insert user roles
INSERT INTO AspNetUserRoles (UserId, RoleId)
VALUES 
(@AdminId, @AdminRoleId),
(@UserId1, @UserRoleId),
(@UserId2, @UserRoleId),
(@UserId3, @UserRoleId),
(@UserId4, @UserRoleId),
(@UserId5, @UserRoleId);

-- Insert members with IDENTITY_INSERT
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

-- Insert courts
INSERT INTO [001_Courts] (Name, Location, IsActive, Description, PricePerHour)
VALUES 
(N'Sân A - Sàn gỗ', N'Tầng 1, Khu vực 1', 1, N'Sân cầu lông chuyên nghiệp với sàn gỗ cao cấp', 200000.0),
(N'Sân B - Sàn gỗ', N'Tầng 1, Khu vực 2', 1, N'Sân cầu lông với sàn gỗ, ánh sáng tốt', 200000.0),
(N'Sân C - Sàn composite', N'Tầng 2, Khu vực 1', 1, N'Sân cầu lông sàn composite, giá tốt', 150000.0),
(N'Sân D - Sàn composite', N'Tầng 2, Khu vực 2', 1, N'Sân cầu lông sàn composite, ánh sáng chuẩn', 150000.0),
(N'Sân E - VIP', N'Tầng 3, Khu vực VIP', 1, N'Sân VIP với đầy đủ tiện nghi cao cấp', 300000.0);

-- Insert bookings
DECLARE @date1 DATETIME = DATEADD(DAY, 1, CAST(GETDATE() AS DATETIME));
DECLARE @date2 DATETIME = DATEADD(DAY, 2, CAST(GETDATE() AS DATETIME));
DECLARE @date3 DATETIME = DATEADD(DAY, 3, CAST(GETDATE() AS DATETIME));
DECLARE @date4 DATETIME = DATEADD(DAY, -1, CAST(GETDATE() AS DATETIME));

INSERT INTO [001_Bookings] (CourtId, MemberId, StartTime, EndTime, TotalPrice, IsRecurring, Status, CreatedDate)
VALUES 
(1, 2, DATEADD(HOUR, 7, @date4), DATEADD(HOUR, 8, @date4), 200000.0, 0, N'Completed', DATEADD(DAY, -5, GETDATE())),
(2, 3, DATEADD(HOUR, 18, @date4), DATEADD(HOUR, 19, @date4), 200000.0, 0, N'Completed', DATEADD(DAY, -4, GETDATE())),
(3, 4, DATEADD(HOUR, 9, @date4), DATEADD(HOUR, 10, @date4), 150000.0, 0, N'Completed', DATEADD(DAY, -3, GETDATE())),
(1, 2, DATEADD(HOUR, 7, @date1), DATEADD(HOUR, 8, @date1), 200000.0, 0, N'Confirmed', GETDATE()),
(2, 3, DATEADD(HOUR, 19, @date1), DATEADD(HOUR, 21, @date1), 400000.0, 0, N'Confirmed', GETDATE()),
(4, 4, DATEADD(HOUR, 10, @date2), DATEADD(HOUR, 11, @date2), 150000.0, 0, N'Confirmed', GETDATE()),
(5, 5, DATEADD(HOUR, 14, @date2), DATEADD(HOUR, 16, @date2), 600000.0, 0, N'Confirmed', GETDATE()),
(1, 6, DATEADD(HOUR, 16, @date3), DATEADD(HOUR, 17, @date3), 200000.0, 0, N'Pending', GETDATE()),
(3, 2, DATEADD(HOUR, 6, @date3), DATEADD(HOUR, 8, @date3), 300000.0, 0, N'Pending', GETDATE());

-- Insert wallet transactions
INSERT INTO [001_WalletTransactions] (MemberId, Amount, Type, Status, Description, CreatedDate)
VALUES 
(2, 2000000.0, N'Deposit', N'Completed', N'Nạp tiền ban đầu', DATEADD(DAY, -10, GETDATE())),
(3, 1500000.0, N'Deposit', N'Completed', N'Nạp tiền', DATEADD(DAY, -9, GETDATE())),
(4, 1000000.0, N'Deposit', N'Completed', N'Nạp tiền', DATEADD(DAY, -8, GETDATE())),
(5, 800000.0, N'Deposit', N'Completed', N'Nạp tiền', DATEADD(DAY, -7, GETDATE())),
(6, 500000.0, N'Deposit', N'Completed', N'Nạp tiền', DATEADD(DAY, -6, GETDATE())),
(2, 200000.0, N'Payment', N'Completed', N'Thanh toán sân A', DATEADD(DAY, -5, GETDATE())),
(3, 200000.0, N'Payment', N'Completed', N'Thanh toán sân B', DATEADD(DAY, -4, GETDATE())),
(4, 150000.0, N'Payment', N'Completed', N'Thanh toán sân C', DATEADD(DAY, -3, GETDATE())),
(2, 100000.0, N'Deposit', N'Completed', N'Nạp thêm tiền', DATEADD(DAY, -2, GETDATE())),
(3, 150000.0, N'Deposit', N'Completed', N'Nạp thêm tiền', DATEADD(DAY, -2, GETDATE())),
(4, 100000.0, N'Deposit', N'Completed', N'Nạp thêm tiền', DATEADD(DAY, -1, GETDATE())),
(5, 200000.0, N'Payment', N'Completed', N'Thanh toán sân VIP', DATEADD(DAY, -1, GETDATE())),
(2, 300000.0, N'Payment', N'Pending', N'Thanh toán đặt sân', GETDATE()),
(6, 250000.0, N'Deposit', N'Pending', N'Nạp tiền đang xử lý', GETDATE()),
(1, 1000000.0, N'Deposit', N'Completed', N'Nạp tiền admin', DATEADD(DAY, -30, GETDATE()));

-- Insert tournaments
INSERT INTO [001_Tournaments] (Name, StartDate, EndDate, Format, EntryFee, PrizePool, Status, Settings, CreatedDate)
VALUES 
(N'Giải Cầu Lông Hưởng Ứng Tết 2025', DATEADD(DAY, 10, GETDATE()), DATEADD(DAY, 12, GETDATE()), N'Knockout', 500000.0, 10000000.0, N'Registration', N'{}', DATEADD(DAY, -10, GETDATE())),
(N'Giải Cầu Lông Vô Địch Công Ty', DATEADD(DAY, 20, GETDATE()), DATEADD(DAY, 25, GETDATE()), N'RoundRobin', 1000000.0, 50000000.0, N'Pending', N'{}', DATEADD(DAY, -5, GETDATE())),
(N'Giải Cầu Lông Khu Vực Nam', DATEADD(DAY, 15, GETDATE()), DATEADD(DAY, 18, GETDATE()), N'Knockout', 750000.0, 20000000.0, N'Registration', N'{}', DATEADD(DAY, -3, GETDATE())),
(N'Giải Cầu Lông Nữ Vô Địch', DATEADD(DAY, 5, GETDATE()), DATEADD(DAY, 7, GETDATE()), N'RoundRobin', 300000.0, 5000000.0, N'Upcoming', N'{}', GETDATE());

-- Insert tournament participants
INSERT INTO [001_TournamentParticipants] (TournamentId, MemberId, TeamName, PaymentStatusCompleted, RegisteredDate)
VALUES 
(1, 2, N'Team A', 1, DATEADD(DAY, -5, GETDATE())),
(1, 3, N'Team B', 1, DATEADD(DAY, -5, GETDATE())),
(1, 4, N'Team C', 0, DATEADD(DAY, -3, GETDATE())),
(2, 2, N'Team Alpha', 1, DATEADD(DAY, -2, GETDATE())),
(2, 5, N'Team Beta', 1, DATEADD(DAY, -2, GETDATE())),
(2, 6, N'Team Gamma', 0, DATEADD(DAY, -1, GETDATE())),
(3, 3, N'Team X', 1, GETDATE()),
(3, 4, N'Team Y', 0, GETDATE()),
(3, 5, N'Team Z', 1, GETDATE()),
(4, 2, N'Lady Team 1', 1, DATEADD(DAY, -1, GETDATE())),
(4, 3, N'Lady Team 2', 1, DATEADD(DAY, -1, GETDATE())),
(4, 6, N'Lady Team 3', 1, GETDATE());

PRINT 'Dữ liệu đã được khôi phục thành công!';
PRINT '========================================';
PRINT 'Tài khoản đăng nhập (tất cả dùng password: Password123!)';
PRINT '========================================';
PRINT 'Admin: admin';
PRINT 'User 1: john_doe';
PRINT 'User 2: jane_smith';
PRINT 'User 3: mike_wilson';
PRINT 'User 4: sarah_jones';
PRINT 'User 5: tom_brown';
PRINT '========================================';
