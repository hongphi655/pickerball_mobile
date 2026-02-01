# Integration Testing Guide - Member Management Feature

## Prerequisites
- Backend running on `http://localhost:5001`
- Database: SQL Server (SQLEXPRESS) with PCM_Database
- Admin user account with valid JWT token
- Flutter web app running or built

## Test Scenarios

### Scenario 1: View All Members (Admin)

**Steps**:
1. Start backend: `cd PCM_Backend && dotnet run`
2. Open Flutter web app (or run: `cd PCM_Mobile && flutter run -d chrome`)
3. Login with admin credentials
4. Navigate to member management page
5. Verify member list displays

**Expected Results**:
- ✅ Member list loads without errors
- ✅ Each member shows: Name, Email, Join Date, Wallet Balance
- ✅ Loading indicator appears while fetching
- ✅ No HTTP errors in network tab

**API Call**:
```
GET http://localhost:5001/api/admin/members
Authorization: Bearer <jwt_token>
Response: { success: true, data: [...], message: "..." }
```

---

### Scenario 2: View Member Details with Bookings

**Steps**:
1. From member list, click on a member card
2. View member detail dialog that shows:
   - ID, Email, Join Date
   - Rank Level, Tier
   - Wallet Balance, Total Spent
3. Click "Xem Bookings" button
4. Verify booking history displays

**Expected Results**:
- ✅ Detail dialog displays correct member information
- ✅ Wallet balance shows currency formatted (₫)
- ✅ Booking dialog shows all member's bookings
- ✅ Each booking card shows court name, date/time, price
- ✅ Bookings sorted by date (newest first)

**API Calls**:
```
1st API Call (already cached):
GET /api/admin/members
Returns member list

2nd API Call:
GET /api/admin/members/{memberId}/bookings
Response: { success: true, data: [booking1, booking2, ...], message: "..." }
```

---

### Scenario 3: User Creates Booking

**Steps**:
1. Logout from admin account
2. Login with regular user account
3. Navigate to "Đặt Sân" (Book Court) section
4. Select a court from dropdown
5. Pick a date using date picker
6. Select start time and end time
7. View calculated price
8. Click "Đặt Sân" (Submit Booking)

**Expected Results**:
- ✅ Court dropdown populates from database
- ✅ Date picker allows selecting valid dates
- ✅ Time selection works for start/end
- ✅ Price calculates correctly based on duration and hourly rate
- ✅ Booking submission succeeds with success message
- ✅ Booking appears in database

**DB Verification**:
```sql
SELECT * FROM 001_Bookings 
WHERE MemberId = <user_id> 
AND BookedDate >= DATEADD(DAY, -1, GETDATE())
```

---

### Scenario 4: Verify Booking Appears in Admin View

**Steps**:
1. Logout user
2. Login as admin
3. Go to member management
4. Find the user who just booked
5. Click on user card
6. Click "Xem Bookings"

**Expected Results**:
- ✅ User's newly created booking appears in booking list
- ✅ Booking shows correct court name
- ✅ Booking shows correct date and time
- ✅ Booking shows correct total price

---

## Manual API Testing (Postman/curl)

### Test 1: Get All Members

```bash
curl -X GET http://localhost:5001/api/admin/members \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Expected Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "fullName": "John Doe",
      "email": "john@example.com",
      "joinDate": "2025-01-15T00:00:00",
      "rankLevel": 5.0,
      "isActive": true,
      "walletBalance": 1000000.0,
      "tier": "Gold",
      "totalSpent": 500000.0,
      "avatarUrl": null
    },
    ...
  ],
  "message": "Members retrieved successfully"
}
```

---

### Test 2: Get Specific Member's Bookings

```bash
curl -X GET http://localhost:5001/api/admin/members/1/bookings \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Expected Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "courtId": 1,
      "courtName": "Court A",
      "startTime": "2025-02-01T09:00:00",
      "endTime": "2025-02-01T10:00:00",
      "status": "Confirmed",
      "price": 100000.0,
      "bookedDate": "2025-01-31T14:30:00"
    },
    ...
  ],
  "message": "Member bookings retrieved successfully"
}
```

---

## Database Verification Queries

### Check Member List
```sql
SELECT Id, FullName, Email, JoinDate, WalletBalance, TotalSpent
FROM 001_Members
WHERE IsActive = 1
ORDER BY JoinDate DESC;
```

### Check Member Bookings
```sql
SELECT b.Id, b.CourtId, c.Name as CourtName, b.StartTime, b.EndTime, 
       b.TotalPrice, b.Status, b.CreatedDate
FROM 001_Bookings b
JOIN 001_Courts c ON b.CourtId = c.Id
WHERE b.MemberId = <member_id>
ORDER BY b.StartTime DESC;
```

### Check Wallet Transactions
```sql
SELECT Id, MemberId, Amount, Type, Description, TransactionDate
FROM 001_WalletTransactions
WHERE MemberId = <member_id>
ORDER BY TransactionDate DESC;
```

---

## Error Scenarios & Troubleshooting

### Error: 401 Unauthorized
**Cause**: Missing or invalid JWT token
**Solution**: Ensure you're logged in with admin account and token is valid

### Error: Empty Member List
**Cause**: No members in database
**Solution**: Register test users first, then view them

### Error: Bookings Not Showing
**Cause**: Member has no bookings
**Solution**: Create booking first, then view in admin panel

### Error: 403 Forbidden
**Cause**: User doesn't have Admin role
**Solution**: Login with admin account (role must be "Admin" in database)

### Error: API Connection Failed
**Cause**: Backend not running or wrong port
**Solution**: Check `dotnet run` output, ensure port 5001 is active

---

## Performance Metrics

- **Member List Load Time**: Should be < 2 seconds for 1000 members
- **Booking History Load**: Should be < 1 second per member
- **Database Query**: All queries use `AsNoTracking()` for read-only performance

---

## Sign-Off Checklist

- [ ] Backend builds successfully
- [ ] Frontend builds successfully
- [ ] Admin can view all members
- [ ] Admin can view member details (wallet, bookings)
- [ ] User can create bookings
- [ ] New bookings appear in admin member view
- [ ] No HTTP errors in network log
- [ ] No compile/runtime errors
- [ ] Database persists all data correctly

