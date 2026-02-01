-- Seed initial data for PCM_Database
IF NOT EXISTS (SELECT 1 FROM 001_Members WHERE FullName = 'Nguyễn Văn A')
BEGIN
    INSERT INTO 001_Members (FullName, JoinDate, RankLevel, IsActive, WalletBalance, Tier, TotalSpent, AvatarUrl)
    VALUES ('Nguyễn Văn A', GETDATE(), 5.0, 1, 100.00, 'Silver', 50.00, NULL)
END

IF NOT EXISTS (SELECT 1 FROM 001_Members WHERE FullName = 'Trần Thị B')
BEGIN
    INSERT INTO 001_Members (FullName, JoinDate, RankLevel, IsActive, WalletBalance, Tier, TotalSpent, AvatarUrl)
    VALUES ('Trần Thị B', GETDATE(), 4.5, 1, 250.00, 'Gold', 200.00, NULL)
END

IF NOT EXISTS (SELECT 1 FROM 001_Members WHERE FullName = 'Lê Minh C')
BEGIN
    INSERT INTO 001_Members (FullName, JoinDate, RankLevel, IsActive, WalletBalance, Tier, TotalSpent, AvatarUrl)
    VALUES ('Lê Minh C', GETDATE(), 3.0, 1, 50.00, 'Bronze', 100.00, NULL)
END

IF NOT EXISTS (SELECT 1 FROM 001_Courts WHERE Name = 'Court 1')
BEGIN
    INSERT INTO 001_Courts (Name, IsActive, Description, Location, PricePerHour)
    VALUES ('Court 1 - Sân Badminton Hàng A', 1, 'Sân đẹp, máy lạnh, bàn ghế tốt', 'Quận 1, TPHCM', 150.00)
END

IF NOT EXISTS (SELECT 1 FROM 001_Courts WHERE Name = 'Court 2')
BEGIN
    INSERT INTO 001_Courts (Name, IsActive, Description, Location, PricePerHour)
    VALUES ('Court 2 - Sân Badminton Central', 1, 'Trang thiết bị hiện đại', 'Quận 3, TPHCM', 200.00)
END

IF NOT EXISTS (SELECT 1 FROM 001_Courts WHERE Name = 'Court 3')
BEGIN
    INSERT INTO 001_Courts (Name, IsActive, Description, Location, PricePerHour)
    VALUES ('Court 3 - Sân Badminton VIP', 1, 'Sân VIP cao cấp', 'Quận 7, TPHCM', 300.00)
END
