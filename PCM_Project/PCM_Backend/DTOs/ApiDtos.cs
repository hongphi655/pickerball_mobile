namespace PCM.API.DTOs
{
    // Auth DTOs
    public class LoginRequest
    {
        public string Username { get; set; } = null!;
        public string Password { get; set; } = null!;
    }

    public class LoginResponse
    {
        public string Token { get; set; } = null!;
        public UserInfoDto User { get; set; } = null!;
    }

    public class RegisterRequest
    {
        public string Username { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string Password { get; set; } = null!;
        public string FullName { get; set; } = null!;
    }

    public class UserInfoDto
    {
        public string Id { get; set; } = null!;
        public string Username { get; set; } = null!;
        public string Email { get; set; } = null!;
        public MemberDto? Member { get; set; }
        public List<string>? Roles { get; set; }
    }

    // Member DTOs
    public class MemberDto
    {
        public int Id { get; set; }
        public string FullName { get; set; } = null!;
        public DateTime JoinDate { get; set; }
        public double RankLevel { get; set; }
        public bool IsActive { get; set; }
        public decimal WalletBalance { get; set; }
        public string Tier { get; set; } = null!;
        public decimal TotalSpent { get; set; }
        public string? AvatarUrl { get; set; }
    }

    public class MemberUpdateDto
    {
        public string FullName { get; set; } = null!;
        public string? AvatarUrl { get; set; }
    }

    // Wallet DTOs
    public class WalletDepositRequest
    {
        public decimal Amount { get; set; }
        public string? ProofImageUrl { get; set; }
        public string? Description { get; set; }
    }

    public class WalletTransactionDto
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public decimal Amount { get; set; }
        public string Type { get; set; } = null!;
        public string Status { get; set; } = null!;
        public string? RelatedId { get; set; }
        public string? Description { get; set; }
        public DateTime CreatedDate { get; set; }
        public string? ProofImageUrl { get; set; }
    }

    public class ApproveDepositRequest
    {
        public int TransactionId { get; set; }
    }

    // Court DTOs
    public class CourtDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public bool IsActive { get; set; }
        public string? Description { get; set; }
        public string? Location { get; set; }
        public decimal PricePerHour { get; set; }
    }

    public class CreateCourtRequest
    {
        public string Name { get; set; } = null!;
        public string? Description { get; set; }
        public string? Location { get; set; }
        public decimal PricePerHour { get; set; }
    }

    public class UpdateCourtRequest
    {
        public string Name { get; set; } = null!;
        public string? Description { get; set; }
        public string? Location { get; set; }
        public decimal PricePerHour { get; set; }
        public bool IsActive { get; set; }
    }

    // Booking DTOs
    public class BookingDto
    {
        public int Id { get; set; }
        public int CourtId { get; set; }
        public int MemberId { get; set; }
        public CourtDto? Court { get; set; }
        public MemberDto? Member { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public decimal TotalPrice { get; set; }
        public bool IsRecurring { get; set; }
        public string? RecurrenceRule { get; set; }
        public string Status { get; set; } = null!;
        public DateTime CreatedDate { get; set; }
    }

    public class CreateBookingRequest
    {
        public int CourtId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
    }

    public class CreateRecurringBookingRequest
    {
        public int CourtId { get; set; }
        public DateTime FirstBookingDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan Duration { get; set; }
        public string RecurrenceRule { get; set; } = null!; // "Weekly;Tue,Thu"
        public int OccurrenceCount { get; set; }
    }

    // Tournament DTOs
    public class TournamentDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string Format { get; set; } = null!;
        public decimal EntryFee { get; set; }
        public decimal PrizePool { get; set; }
        public string Status { get; set; } = null!;
        public int ParticipantCount { get; set; }
    }

    public class CreateTournamentRequest
    {
        public string Name { get; set; } = null!;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string Format { get; set; } = null!;
        public decimal EntryFee { get; set; }
        public decimal PrizePool { get; set; }
        public string? Settings { get; set; }
    }

    public class UpdateTournamentRequest
    {
        public string Name { get; set; } = null!;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string Format { get; set; } = null!;
        public decimal EntryFee { get; set; }
        public decimal PrizePool { get; set; }
        public string? Settings { get; set; }
    }

    public class JoinTournamentRequest
    {
        public string? TeamName { get; set; }
    }

    public class TournamentParticipantDto
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public string? TeamName { get; set; }
        public DateTime RegisteredDate { get; set; }
        public string? MemberFullName { get; set; }
    }

    // Notification DTOs
    public class NotificationDto
    {
        public int Id { get; set; }
        public string Message { get; set; } = null!;
        public string Type { get; set; } = null!;
        public string? LinkUrl { get; set; }
        public bool IsRead { get; set; }
        public DateTime CreatedDate { get; set; }
    }

    // API Response DTOs
    public class ApiResponse<T>
    {
        public bool Success { get; set; }
        public string Message { get; set; } = null!;
        public T? Data { get; set; }
    }

    public class PaginatedResponse<T>
    {
        public int Total { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public List<T> Items { get; set; } = new();
    }
}
