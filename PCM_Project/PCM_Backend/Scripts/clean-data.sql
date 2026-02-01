SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

-- Clear existing sample data before inserting new data
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

PRINT 'Dữ liệu cũ đã được xóa và identity reset!';
