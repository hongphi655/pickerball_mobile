-- Fix authentication and authorization issues
-- Run this script to setup admin user and roles

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON

-- 1. Create Admin role if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM AspNetRoles WHERE Name = 'Admin')
BEGIN
    INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (NEWID(), 'Admin', 'ADMIN', NEWID())
END

-- 2. Create User role if it doesn't exist  
IF NOT EXISTS (SELECT 1 FROM AspNetRoles WHERE Name = 'User')
BEGIN
    INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (NEWID(), 'User', 'USER', NEWID())
END

-- 3. Get Admin role ID
DECLARE @AdminRoleId NVARCHAR(MAX) = (SELECT Id FROM AspNetRoles WHERE Name = 'Admin')

-- 4. Create admin user if it doesn't exist
-- Password: Admin123! (hashed with ASP.NET Identity)
IF NOT EXISTS (SELECT 1 FROM AspNetUsers WHERE UserName = 'admin')
BEGIN
    INSERT INTO AspNetUsers (
        Id, UserName, NormalizedUserName, Email, NormalizedEmail, 
        EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, 
        PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled, AccessFailedCount
    )
    VALUES (
        NEWID(), 'admin', 'ADMIN', 'admin@pcm.com', 'ADMIN@PCM.COM',
        1,
        'AQAAAAIAAYagAAAAEK0dNy+JTvYXHEV0L/7XLHjQ5/IZqW4JI8V7AZvvnI9XcM+hMkIZ4C7LfmQHpMyDLQ==',
        'AQAAA', 'AQAAA',
        0, 0, 1, 0
    )
END

-- 5. Get admin user ID
DECLARE @AdminUserId NVARCHAR(MAX) = (SELECT Id FROM AspNetUsers WHERE UserName = 'admin')

-- 6. Assign Admin role to admin user if not already assigned
IF NOT EXISTS (
    SELECT 1 FROM AspNetUserRoles 
    WHERE UserId = @AdminUserId AND RoleId = @AdminRoleId
)
BEGIN
    INSERT INTO AspNetUserRoles (UserId, RoleId)
    VALUES (@AdminUserId, @AdminRoleId)
END

-- 7. Create sample user if it doesn't exist
-- Password: User123! (hashed with ASP.NET Identity)
DECLARE @UserRoleId NVARCHAR(MAX) = (SELECT Id FROM AspNetRoles WHERE Name = 'User')

IF NOT EXISTS (SELECT 1 FROM AspNetUsers WHERE UserName = 'testuser')
BEGIN
    DECLARE @TestUserId NVARCHAR(MAX) = NEWID()
    INSERT INTO AspNetUsers (
        Id, UserName, NormalizedUserName, Email, NormalizedEmail, 
        EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, 
        PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled, AccessFailedCount
    )
    VALUES (
        @TestUserId, 'testuser', 'TESTUSER', 'testuser@pcm.com', 'TESTUSER@PCM.COM',
        1,
        'AQAAAAIAAYagAAAAEMuSgWvj8X6/vJG8T0B9vUZvJE1KL5PeFArGK+ZhG7T7hZmMeYYVAEv5hPj2oDDrIw==',
        'AQAAA', 'AQAAA',
        0, 0, 1, 0
    )
    
    INSERT INTO AspNetUserRoles (UserId, RoleId)
    VALUES (@TestUserId, @UserRoleId)
END

-- Verification query
SELECT 'User Setup Complete' as Status

SELECT u.UserName, STRING_AGG(r.Name, ', ') as Roles
FROM AspNetUsers u
LEFT JOIN AspNetUserRoles ur ON u.Id = ur.UserId
LEFT JOIN AspNetRoles r ON ur.RoleId = r.Id
WHERE u.UserName IN ('admin', 'testuser')
GROUP BY u.UserName
