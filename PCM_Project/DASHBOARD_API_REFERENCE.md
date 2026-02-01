# Dashboard API Reference & Integration Guide

## Overview
This guide documents the API endpoints and integration points needed for the dashboard implementation.

---

## Existing Implemented Endpoints

### Authentication
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
GET /api/auth/validate
```

### Courts (Currently Used)
```
GET /api/courts
  Response: List<CourtDto> with fields:
  {
    "id": int,
    "name": string,
    "location": string,
    "description": string,
    "pricePerHour": decimal,
    "isActive": boolean
  }

POST /api/courts (Admin)
PUT /api/courts/{id} (Admin)
DELETE /api/courts/{id} (Admin)
```

### Bookings (Currently Used)
```
GET /api/bookings/my-bookings
  Response: List<BookingDto>
  {
    "id": int,
    "courtId": int,
    "courtName": string,
    "memberId": int,
    "memberName": string,
    "startTime": datetime,
    "endTime": datetime,
    "totalPrice": decimal,
    "status": string (Confirmed/Pending/Cancelled)
  }

POST /api/bookings
PUT /api/bookings/{id}
DELETE /api/bookings/{id}

GET /api/bookings/calendar?courtId={id}&date={date}
```

### Wallet (Currently Used)
```
GET /api/wallet/balance
  Response: { "balance": decimal }

POST /api/wallet/deposit
  Body: { "amount": decimal }

GET /api/wallet/transactions
  Response: List<TransactionDto>
  {
    "id": int,
    "type": string (Deposit/Withdrawal),
    "amount": decimal,
    "date": datetime,
    "status": string
  }
```

### Tournaments (Currently Used)
```
GET /api/tournaments
  Response: List<TournamentDto>
  {
    "id": int,
    "name": string,
    "description": string,
    "startDate": datetime,
    "endDate": datetime,
    "courtId": int
  }
```

---

## Endpoints Needed for Dashboard Integration

### Priority 1: Admin Statistics (REQUIRED for complete dashboard)

#### Get Members Count
```http
GET /api/admin/stats/members-count
Authorization: Bearer {token}
Role Required: Admin

Response (200 OK):
{
  "count": 1248,
  "activeCount": 1200,
  "inactiveCount": 48,
  "newThisMonth": 42
}
```

**Recommended Backend Code (C#)**:
```csharp
[HttpGet("members-count")]
[Authorize(Roles = "Admin")]
public async Task<IActionResult> GetMembersCount()
{
    var totalCount = await _context.Members.CountAsync();
    var activeCount = await _context.Members
        .Where(m => m.IsActive)
        .CountAsync();
    
    var newThisMonth = await _context.Members
        .Where(m => m.CreatedDate >= DateTime.Now.AddMonths(-1))
        .CountAsync();
    
    return Ok(new {
        count = totalCount,
        activeCount = activeCount,
        inactiveCount = totalCount - activeCount,
        newThisMonth = newThisMonth
    });
}
```

#### Get Revenue Statistics
```http
GET /api/admin/stats/revenue?startDate={date}&endDate={date}
Authorization: Bearer {token}
Role Required: Admin

Query Parameters:
- startDate: Optional, default: beginning of month
- endDate: Optional, default: today

Response (200 OK):
{
  "totalRevenue": 45200000,
  "monthlyRevenue": 3500000,
  "totalTransactions": 892,
  "pendingAmount": 125000,
  "confirmedAmount": 45200000,
  "breakdown": {
    "bookings": 35000000,
    "deposits": 10200000
  }
}
```

**Recommended Backend Code (C#)**:
```csharp
[HttpGet("revenue")]
[Authorize(Roles = "Admin")]
public async Task<IActionResult> GetRevenue(
    [FromQuery] DateTime? startDate = null,
    [FromQuery] DateTime? endDate = null)
{
    startDate ??= new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
    endDate ??= DateTime.Now;
    
    var deposits = await _context.WalletTransactions
        .Where(t => t.Type == "Deposit" && 
                    t.Date >= startDate && 
                    t.Date <= endDate)
        .SumAsync(t => t.Amount);
    
    var bookings = await _context.Bookings
        .Where(b => b.CreatedDate >= startDate && 
                    b.CreatedDate <= endDate &&
                    b.Status == "Confirmed")
        .SumAsync(b => b.TotalPrice);
    
    var totalRevenue = deposits + bookings;
    var pending = await _context.WalletTransactions
        .Where(t => t.Type == "Deposit" && t.Status == "Pending")
        .SumAsync(t => t.Amount);
    
    return Ok(new {
        totalRevenue = totalRevenue,
        monthlyRevenue = totalRevenue,
        totalTransactions = await _context.Bookings
            .Where(b => b.CreatedDate >= startDate && b.CreatedDate <= endDate)
            .CountAsync(),
        pendingAmount = pending,
        confirmedAmount = totalRevenue,
        breakdown = new {
            bookings = bookings,
            deposits = deposits
        }
    });
}
```

### Priority 2: Admin Activity Feed

#### Get Recent Activities
```http
GET /api/admin/activities?limit={limit}&days={days}
Authorization: Bearer {token}
Role Required: Admin

Query Parameters:
- limit: Max results (default: 10)
- days: Days to look back (default: 30)

Response (200 OK):
{
  "activities": [
    {
      "id": "uuid",
      "type": "NewBooking|NewMember|Deposit|BookingCancelled",
      "description": "User [Name] booked [Court]",
      "timestamp": "2026-01-31T10:30:00Z",
      "userId": 123,
      "userName": "John Doe",
      "metadata": {
        "courtId": 5,
        "courtName": "Court A",
        "amount": 150000
      }
    }
  ]
}
```

**Recommended Backend Code (C#)**:
```csharp
[HttpGet("activities")]
[Authorize(Roles = "Admin")]
public async Task<IActionResult> GetActivities(
    [FromQuery] int limit = 10,
    [FromQuery] int days = 30)
{
    var startDate = DateTime.Now.AddDays(-days);
    
    var activities = new List<ActivityDto>();
    
    // Get new bookings
    var newBookings = await _context.Bookings
        .Where(b => b.CreatedDate >= startDate)
        .OrderByDescending(b => b.CreatedDate)
        .Include(b => b.Member)
        .Include(b => b.Court)
        .Take(limit)
        .Select(b => new ActivityDto {
            Type = "NewBooking",
            Description = $"Đặt sân mới: {b.Member.FullName} - {b.Court.Name}",
            Timestamp = b.CreatedDate,
            UserId = b.MemberId,
            UserName = b.Member.FullName
        })
        .ToListAsync();
    
    activities.AddRange(newBookings);
    
    // Get new members
    var newMembers = await _context.Members
        .Where(m => m.CreatedDate >= startDate)
        .OrderByDescending(m => m.CreatedDate)
        .Take(limit)
        .Select(m => new ActivityDto {
            Type = "NewMember",
            Description = $"Thành viên mới: {m.FullName}",
            Timestamp = m.CreatedDate,
            UserId = m.Id,
            UserName = m.FullName
        })
        .ToListAsync();
    
    activities.AddRange(newMembers);
    
    return Ok(new {
        activities = activities
            .OrderByDescending(a => a.Timestamp)
            .Take(limit)
            .ToList()
    });
}
```

### Priority 3: Member Management (For Admin Dashboard)

#### Get All Members List
```http
GET /api/admin/members?page={page}&pageSize={size}&tier={tier}
Authorization: Bearer {token}
Role Required: Admin

Query Parameters:
- page: Page number (default: 1)
- pageSize: Results per page (default: 20)
- tier: Filter by tier (Standard/Silver/Gold/Diamond)

Response (200 OK):
{
  "members": [
    {
      "id": 1,
      "fullName": "John Doe",
      "email": "john@example.com",
      "phone": "0123456789",
      "tier": "Gold",
      "totalSpent": 5500000,
      "joinDate": "2025-06-15",
      "isActive": true,
      "lastBookingDate": "2026-01-30"
    }
  ],
  "totalCount": 1248,
  "pageCount": 63
}
```

#### Get Member Detail
```http
GET /api/admin/members/{id}
Authorization: Bearer {token}
Role Required: Admin

Response (200 OK):
{
  "id": 1,
  "fullName": "John Doe",
  "email": "john@example.com",
  "phone": "0123456789",
  "tier": "Gold",
  "totalSpent": 5500000,
  "joinDate": "2025-06-15",
  "bookingCount": 18,
  "lastBookingDate": "2026-01-30",
  "walletBalance": 250000,
  "recentBookings": [
    {
      "courtName": "Court A",
      "date": "2026-01-30",
      "amount": 150000
    }
  ]
}
```

### Priority 4: Deposit Approvals

#### Get Pending Deposits
```http
GET /api/admin/wallet/pending-deposits
Authorization: Bearer {token}
Role Required: Admin

Response (200 OK):
{
  "deposits": [
    {
      "id": 1,
      "memberId": 10,
      "memberName": "Jane Smith",
      "amount": 500000,
      "requestDate": "2026-01-31T08:00:00Z",
      "paymentMethod": "VNPay",
      "status": "Pending"
    }
  ],
  "totalPending": 125000000
}
```

#### Approve/Reject Deposit
```http
PUT /api/admin/wallet/deposits/{id}/approve
PUT /api/admin/wallet/deposits/{id}/reject
Authorization: Bearer {token}
Role Required: Admin

Body (for reject):
{
  "reason": "Payment failed verification"
}

Response (200 OK):
{
  "success": true,
  "message": "Deposit approved successfully"
}
```

---

## Frontend Integration Examples

### How to Call New Endpoints in api_service.dart

```dart
// Get admin statistics
Future<Map<String, dynamic>> getAdminStats() async {
  try {
    final response = await _dio.get('/api/admin/stats/members-count');
    final members = response.data['count'] ?? 0;
    
    final revenueResponse = await _dio.get('/api/admin/stats/revenue');
    final revenue = revenueResponse.data['totalRevenue'] ?? 0;
    
    return {
      'members': members,
      'revenue': revenue,
      'success': true
    };
  } on DioException catch (e) {
    print('Error fetching admin stats: $e');
    return {'success': false, 'error': e.toString()};
  }
}

// Get activity feed
Future<List<Activity>> getActivities({int days = 30}) async {
  try {
    final response = await _dio.get(
      '/api/admin/activities',
      queryParameters: {'days': days}
    );
    
    final activities = (response.data['activities'] as List)
        .map((a) => Activity.fromJson(a))
        .toList();
    
    return activities;
  } on DioException catch (e) {
    print('Error fetching activities: $e');
    return [];
  }
}

// Get pending deposits
Future<List<Deposit>> getPendingDeposits() async {
  try {
    final response = await _dio.get('/api/admin/wallet/pending-deposits');
    
    final deposits = (response.data['deposits'] as List)
        .map((d) => Deposit.fromJson(d))
        .toList();
    
    return deposits;
  } on DioException catch (e) {
    print('Error fetching deposits: $e');
    return [];
  }
}

// Approve deposit
Future<bool> approveDeposit(int depositId) async {
  try {
    final response = await _dio.put(
      '/api/admin/wallet/deposits/$depositId/approve'
    );
    return response.statusCode == 200;
  } on DioException catch (e) {
    print('Error approving deposit: $e');
    return false;
  }
}
```

### How to Update AdminDashboard Provider

```dart
// In admin_dashboard_provider.dart (new file)
class AdminDashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  int _memberCount = 0;
  double _revenue = 0;
  List<Activity> _activities = [];
  bool _isLoading = false;
  
  int get memberCount => _memberCount;
  double get revenue => _revenue;
  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  
  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load all data in parallel
      final statsResult = await _apiService.getAdminStats();
      _memberCount = statsResult['members'] ?? 0;
      _revenue = statsResult['revenue'] ?? 0;
      
      _activities = await _apiService.getActivities();
      
      notifyListeners();
    } catch (e) {
      print('Error loading dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## Backend Implementation Checklist

### Required Database Tables
- ✅ Members (already exists)
- ✅ Bookings (already exists)
- ✅ WalletTransactions (already exists)
- ✅ Courts (already exists)
- ⚠️ ActivityLog (optional, for activity feed)

### Required API Endpoints
- [ ] GET /api/admin/stats/members-count
- [ ] GET /api/admin/stats/revenue
- [ ] GET /api/admin/activities (optional)
- [ ] GET /api/admin/members (optional)
- [ ] GET /api/admin/wallet/pending-deposits (optional)
- [ ] PUT /api/admin/wallet/deposits/{id}/approve (optional)

### Required Authorization
- [ ] All admin endpoints require [Authorize(Roles = "Admin")]
- [ ] Verify JWT token validity
- [ ] Log all admin actions for audit trail

---

## Error Handling

### Common HTTP Status Codes Expected
```
200 OK - Success
400 Bad Request - Invalid parameters
401 Unauthorized - Token missing or invalid
403 Forbidden - User doesn't have permission
404 Not Found - Resource doesn't exist
500 Internal Server Error - Server error
```

### Error Response Format
```json
{
  "success": false,
  "message": "User error message",
  "errors": [
    {
      "field": "email",
      "message": "Email already exists"
    }
  ]
}
```

---

## Performance Optimization Tips

1. **Pagination**: Use paging for large datasets (members, activities)
2. **Caching**: Cache admin statistics (update every 5 minutes)
3. **Batch Requests**: Fetch multiple data sources in parallel
4. **Indexing**: Add database indexes on frequently queried fields
   - Members.CreatedDate
   - Bookings.CreatedDate
   - WalletTransactions.Date

---

## Security Considerations

1. **Authentication**: All admin endpoints require Bearer token
2. **Authorization**: Verify "Admin" role before processing
3. **Data Privacy**: Never expose sensitive member information
4. **Rate Limiting**: Consider limiting admin query frequency
5. **Audit Trail**: Log all admin actions for compliance

---

## Testing the New Endpoints

### Using Postman/Insomnia

```
1. Get token by logging in
2. Add Authorization header: Bearer {token}
3. Test GET /api/admin/stats/members-count
4. Test GET /api/admin/stats/revenue
5. Verify response matches expected format
6. Test with invalid token → should get 401
7. Test as regular user → should get 403
```

### Using curl

```bash
# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"Admin@123456"}'

# Get token from response
TOKEN="eyJhbGc..."

# Get member count
curl -X GET http://localhost:5000/api/admin/stats/members-count \
  -H "Authorization: Bearer $TOKEN"
```

---

## Documentation Links

- **API Documentation**: Add Swagger/OpenAPI when deploying
- **Database Schema**: See database migration files
- **Entity Relationships**: Check DbContext configuration

---

**Last Updated**: January 31, 2026  
**Status**: Ready for Implementation
