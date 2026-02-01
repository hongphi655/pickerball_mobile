using Microsoft.AspNetCore.Identity;

namespace PCM.API.Models
{
    // Enums
    public enum MemberTier
    {
        Standard,
        Silver,
        Gold,
        Diamond
    }

    public enum TransactionType
    {
        Deposit,
        Withdraw,
        Payment,
        Refund,
        Reward
    }

    public enum TransactionStatus
    {
        Pending,
        Completed,
        Rejected,
        Failed
    }

    public enum BookingStatus
    {
        PendingPayment,
        Confirmed,
        Cancelled,
        Completed
    }

    public enum TournamentFormat
    {
        RoundRobin,
        Knockout,
        Hybrid
    }

    public enum TournamentStatus
    {
        Open,
        Registering,
        DrawCompleted,
        Ongoing,
        Finished
    }

    public enum MatchStatus
    {
        Scheduled,
        InProgress,
        Finished
    }

    public enum WinningSide
    {
        Team1,
        Team2,
        Draw
    }

    // Core Models
    public class Member
    {
        public int Id { get; set; }
        public string FullName { get; set; } = null!;
        public DateTime JoinDate { get; set; }
        public double RankLevel { get; set; } = 0;
        public bool IsActive { get; set; } = true;
        
        // Identity Link
        public string UserId { get; set; } = null!;
        public IdentityUser? User { get; set; }
        
        // Advanced Fields
        public decimal WalletBalance { get; set; } = 0;
        public MemberTier Tier { get; set; } = MemberTier.Standard;
        public decimal TotalSpent { get; set; } = 0;
        public string? AvatarUrl { get; set; }
        
        // Navigation
        public ICollection<WalletTransaction> WalletTransactions { get; set; } = new List<WalletTransaction>();
        public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
        public ICollection<TournamentParticipant> TournamentParticipants { get; set; } = new List<TournamentParticipant>();
        public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
    }

    public class WalletTransaction
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public Member? Member { get; set; }
        
        public decimal Amount { get; set; }
        public TransactionType Type { get; set; }
        public TransactionStatus Status { get; set; } = TransactionStatus.Pending;
        public string? RelatedId { get; set; } // For Booking or Tournament
        public string? Description { get; set; }
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
        public string? ProofImageUrl { get; set; } // For deposit proof
    }

    public class News
    {
        public int Id { get; set; }
        public string Title { get; set; } = null!;
        public string Content { get; set; } = null!;
        public bool IsPinned { get; set; } = false;
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
        public string? ImageUrl { get; set; }
    }

    public class Court
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public bool IsActive { get; set; } = true;
        public string? Description { get; set; }
        public string? Location { get; set; }
        public decimal PricePerHour { get; set; }
        
        public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    }

    public class Booking
    {
        public int Id { get; set; }
        public int CourtId { get; set; }
        public Court? Court { get; set; }
        
        public int MemberId { get; set; }
        public Member? Member { get; set; }
        
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public decimal TotalPrice { get; set; }
        
        public int? TransactionId { get; set; }
        public WalletTransaction? Transaction { get; set; }
        
        public bool IsRecurring { get; set; } = false;
        public string? RecurrenceRule { get; set; } // "Weekly;Tue,Thu"
        public int? ParentBookingId { get; set; }
        
        public BookingStatus Status { get; set; } = BookingStatus.PendingPayment;
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }

    public class Tournament
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        
        public TournamentFormat Format { get; set; }
        public decimal EntryFee { get; set; }
        public decimal PrizePool { get; set; }
        public TournamentStatus Status { get; set; } = TournamentStatus.Open;
        public string? Settings { get; set; } // JSON settings
        
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
        
        public ICollection<TournamentParticipant> Participants { get; set; } = new List<TournamentParticipant>();
        public ICollection<Match> Matches { get; set; } = new List<Match>();
    }

    public class TournamentParticipant
    {
        public int Id { get; set; }
        public int TournamentId { get; set; }
        public Tournament? Tournament { get; set; }
        
        public int MemberId { get; set; }
        public Member? Member { get; set; }
        
        public string? TeamName { get; set; }
        public bool PaymentStatusCompleted { get; set; } = false;
        public DateTime RegisteredDate { get; set; } = DateTime.UtcNow;
    }

    public class Match
    {
        public int Id { get; set; }
        public int? TournamentId { get; set; }
        public Tournament? Tournament { get; set; }
        
        public string RoundName { get; set; } = null!; // "Group A", "Quarter Final"
        public DateTime Date { get; set; }
        public TimeSpan StartTime { get; set; }
        
        public int Team1_Player1Id { get; set; }
        public int? Team1_Player2Id { get; set; }
        public int Team2_Player1Id { get; set; }
        public int? Team2_Player2Id { get; set; }
        
        public int Score1 { get; set; } = 0;
        public int Score2 { get; set; } = 0;
        public string? Details { get; set; } // "11-9, 5-11, 11-8"
        public WinningSide? WinningSide { get; set; }
        
        public bool IsRanked { get; set; } = true;
        public MatchStatus Status { get; set; } = MatchStatus.Scheduled;
    }

    public class Notification
    {
        public int Id { get; set; }
        public int ReceiverId { get; set; }
        public Member? Receiver { get; set; }
        
        public string Message { get; set; } = null!;
        public string Type { get; set; } = "Info"; // Info, Success, Warning
        public string? LinkUrl { get; set; }
        public bool IsRead { get; set; } = false;
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }

    public class TransactionCategory
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public string Type { get; set; } = null!; // "Thu" (Revenue) or "Chi" (Expense)
    }
}
