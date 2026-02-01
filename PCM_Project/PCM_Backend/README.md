# PCM Backend API - Pickleball Club Management System

## 📋 Project Overview

PCM (Vợt Thủ Phố Núi Pickleball Club Management) is a comprehensive backend API for managing a pickleball club's operations, built with ASP.NET Core Web API, Entity Framework Core, SQL Server, and SignalR for real-time features.

## 🛠️ Technology Stack

- **.NET**: .NET 8.0
- **Database**: SQL Server
- **ORM**: Entity Framework Core 8.0
- **Authentication**: JWT (JSON Web Tokens)
- **Authorization**: Identity & Role-based Access Control
- **Real-time**: SignalR
- **API Documentation**: Swagger/OpenAPI

## 📦 Prerequisites

- .NET 8.0 SDK or later
- SQL Server (with SQL Express or SQL Server)
- Visual Studio 2022 or VS Code with C# extension

## 🚀 Getting Started

### 1. Clone & Setup
```bash
cd PCM_Backend
dotnet restore
```

### 2. Configure Database Connection
Edit `appsettings.json` and update the connection string:
```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=PCM_Database;Trusted_Connection=True;TrustServerCertificate=True;"
}
```

### 3. Apply Migrations
```bash
dotnet ef database update
```

This will create the database schema and apply all migrations.

### 4. Run the API
```bash
dotnet run
```

The API will start at: `https://localhost:5001`

## 📚 API Documentation

Once running, access Swagger UI at: `https://localhost:5001/swagger`

### Main Endpoints

#### Authentication
- `POST /api/auth/login` - User login (returns JWT token)
- `POST /api/auth/register` - User registration

#### Wallet Management
- `POST /api/wallet/deposit` - Request wallet deposit
- `GET /api/wallet/balance` - Get current wallet balance
- `GET /api/wallet/transactions` - Get transaction history
- `PUT /api/admin/wallet/approve/{transactionId}` - Admin: Approve deposit
- `PUT /api/admin/wallet/reject/{transactionId}` - Admin: Reject deposit

#### Courts
- `GET /api/courts` - List all courts
- `POST /api/courts` - Admin: Create new court
- `PUT /api/courts/{id}` - Admin: Update court
- `DELETE /api/courts/{id}` - Admin: Delete court

#### Bookings
- `POST /api/bookings` - Create booking
- `POST /api/bookings/recurring` - Create recurring booking (VIP)
- `DELETE /api/bookings/{id}` - Cancel booking
- `GET /api/bookings/my-bookings` - Get user's bookings
- `GET /api/bookings/calendar` - Get calendar slots

#### Tournaments
- `GET /api/tournaments` - List tournaments
- `POST /api/tournaments` - Admin: Create tournament
- `GET /api/tournaments/{id}` - Get tournament details
- `POST /api/tournaments/{id}/join` - Join tournament
- `DELETE /api/tournaments/{id}/leave` - Leave tournament
- `POST /api/tournaments/{id}/generate-schedule` - Admin: Generate schedule

## 🗄️ Database Schema

### Table Naming Convention
All business tables are prefixed with the last 3 digits of your Student ID (e.g., `001_Members`)

### Core Entities
- **001_Members** - User profiles with wallet & tier system
- **001_WalletTransactions** - Financial transaction history
- **001_Bookings** - Court bookings
- **001_Courts** - Court information
- **001_Tournaments** - Tournament details
- **001_TournamentParticipants** - Tournament registrations
- **001_Matches** - Match records
- **001_Notifications** - User notifications
- **001_News** - Club news & announcements
- **001_TransactionCategories** - Revenue/Expense categories

## 🔐 Authentication & Authorization

### Login Flow
1. User submits credentials to `POST /api/auth/login`
2. API returns JWT token (valid for 24 hours by default)
3. Client includes token in `Authorization: Bearer {token}` header

### User Roles
- **User** - Regular member (default)
- **Admin** - Full access to all operations
- **Treasurer** - Can approve/reject wallet transactions
- **Referee** - Can update match results

## 💡 Key Features

### Wallet System
- Members request deposits with proof image
- Admin/Treasurer reviews and approves
- Automatic balance deduction for bookings & tournament fees
- Automatic refund policy (24h cancellation = 100% refund)

### Smart Booking
- Conflict detection (prevents double-booking)
- Recurring booking for VIP members
- 5-minute hold slot system
- Real-time updates via SignalR

### Tournament Management
- Round-robin and knockout formats
- Automatic schedule generation
- Real-time bracket updates
- Entry fee & prize pool management

### Real-time Features
- SignalR Hub for live notifications
- Match score updates
- Wallet balance changes
- Booking confirmations

## 🔧 Configuration

### appsettings.json
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Your_Connection_String"
  },
  "Jwt": {
    "Secret": "your-long-secret-key-min-64-chars",
    "Issuer": "PCM.API",
    "Audience": "PCM.Mobile",
    "ExpirationMinutes": 1440
  }
}
```

## 📱 Mobile App Integration

Base URL: `https://localhost:5001` (or your deployed URL)

### Required Headers
```
Authorization: Bearer {jwt_token}
Content-Type: application/json
```

### Error Response Format
```json
{
  "success": false,
  "message": "Error description",
  "data": null
}
```

## 🌱 Data Seeding

To seed sample data:
1. Modify `Data/DataSeeder.cs`
2. Run migrations
3. Sample data includes:
   - 1 Admin account
   - 1 Treasurer account
   - 20 members with varying tiers
   - 3 courts
   - 2 sample tournaments

## 🐛 Troubleshooting

### Database Connection Failed
- Verify SQL Server is running
- Check connection string in `appsettings.json`
- Ensure database user has proper permissions

### Migrations Not Applied
```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

### JWT Token Issues
- Ensure JWT Secret in `appsettings.json` is at least 64 characters
- Check token expiration (default 24 hours)
- Verify issuer and audience match

## 📝 Important Notes

1. **Replace "001" with your actual Student ID (last 3 digits)** in all database table names
2. The JWT secret should be changed in production
3. Enable HTTPS in production
4. Set up proper CORS policies for your Flutter app domain
5. Implement rate limiting for production
6. Add logging and monitoring

## 🚀 Deployment

### To Azure
```bash
dotnet publish -c Release
# Follow Azure App Service deployment steps
```

### Connection String for Production
Update with your production database:
```json
"DefaultConnection": "Server=your-server;Database=PCM_DB;User Id=sa;Password=****;"
```

## 📞 Support

For issues or questions:
1. Check API documentation at `/swagger`
2. Review error response messages
3. Check application logs

## 📄 License

This project is part of the Mobile Programming course.

---

**Last Updated**: January 2026
**Developed for**: Pickleball Club Management System
