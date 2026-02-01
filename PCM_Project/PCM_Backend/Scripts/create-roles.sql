SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

-- Check if User role exists, if not create it
IF NOT EXISTS (SELECT * FROM AspNetRoles WHERE Name = 'User')
BEGIN
    INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (NEWID(), 'User', 'USER', NEWID())
    PRINT 'Role User created successfully'
END
ELSE
BEGIN
    PRINT 'Role User already exists'
END

SELECT Id, Name FROM AspNetRoles;
