SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

-- Delete existing test user
DELETE FROM AspNetUsers WHERE UserName = 'test';

-- Create test user
-- Password hash for "Test123!" 
INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnd, LockoutEnabled, AccessFailedCount)
VALUES 
(NEWID(), N'test', N'TEST', N'test@pcm.com', N'TEST@PCM.COM', 1, N'AQAAAAIAAYagAAAAEDepcEXWsRI99vMGmjRcwoKv7Or4d5kzGGv5GiWnvLwg/c0m3kqa260YTAunvyiZlw==', NEWID(), NEWID(), NULL, 0, 0, NULL, 1, 0);

-- Also recreate admin user  
DELETE FROM AspNetUsers WHERE UserName = 'admin';
INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnd, LockoutEnabled, AccessFailedCount)
VALUES 
(NEWID(), N'admin', N'ADMIN', N'admin@pcm.com', N'ADMIN@PCM.COM', 1, N'AQAAAAIAAYagAAAAEDepcEXWsRI99vMGmjRcwoKv7Or4d5kzGGv5GiWnvLwg/c0m3kqa260YTAunvyiZlw==', NEWID(), NEWID(), NULL, 0, 0, NULL, 1, 0);

PRINT 'Test users created successfully!';
PRINT 'test / Test123!';
PRINT 'admin / Test123!';
