SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

-- Password123! hash - from create-users-with-password.sql
UPDATE AspNetUsers 
SET PasswordHash = 'AQAAAAIAAYagAAAAEOkGj3s1w7jVdTFPJtHKFZPKO0v3qmZJZX0q0YHZ0qEBJk0uNgINdKTKYVQp3oEW7Q=='
WHERE UserName = 'admin';

PRINT 'Admin password updated!';
