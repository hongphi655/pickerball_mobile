SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

-- Test with simple password: Password123
-- This is a temporary test password - please change this in production
DECLARE @UserId NVARCHAR(128) = (SELECT Id FROM AspNetUsers WHERE UserName = 'admin');

IF @UserId IS NOT NULL
BEGIN
    DELETE FROM AspNetUsers WHERE UserName = 'admin';
    DELETE FROM AspNetUserRoles WHERE UserId = @UserId;
    DELETE FROM [001_Members] WHERE UserId = @UserId;
END

-- Create admin user with a testable password
DECLARE @AdminId NVARCHAR(128) = NEWID();
DECLARE @AdminRoleId NVARCHAR(128) = (SELECT Id FROM AspNetRoles WHERE Name = 'Admin');

INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnd, LockoutEnabled, AccessFailedCount)
VALUES 
(@AdminId, N'admin', N'ADMIN', N'admin@pcm.com', N'ADMIN@PCM.COM', 1, N'AQAAAAIAAYagAAAAEC5FIgfHz2Nzfrt5OhFf4p2wFZmTMJMKz7Ew9o7S/8xPHLmGYRZHjGIDhvGECBhJyg==', NEWID(), NEWID(), NULL, 0, 0, NULL, 1, 0);

INSERT INTO AspNetUserRoles (UserId, RoleId) VALUES (@AdminId, @AdminRoleId);

INSERT INTO [001_Members] (FullName, JoinDate, RankLevel, IsActive, UserId, Tier, WalletBalance, TotalSpent, AvatarUrl)
VALUES (N'Nguyễn Văn Admin', '2025-01-01', 10.0, 1, @AdminId, N'Platinum', 5000000.0, 1000000.0, NULL);

PRINT 'Admin user created with password: Password123!';
