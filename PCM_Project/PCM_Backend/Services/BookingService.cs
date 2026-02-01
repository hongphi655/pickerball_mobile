using Microsoft.EntityFrameworkCore;
using PCM.API.Data;
using PCM.API.DTOs;
using PCM.API.Models;

namespace PCM.API.Services
{
    public interface IBookingService
    {
        Task<BookingDto?> CreateBookingAsync(int memberId, CreateBookingRequest request);
        Task<BookingDto?> CreateRecurringBookingAsync(int memberId, CreateRecurringBookingRequest request);
        Task<bool> CancelBookingAsync(int bookingId);
        Task<List<BookingDto>> GetMemberBookingsAsync(int memberId);
        Task<List<BookingDto>> GetAvailableSlotsAsync(int courtId, DateTime date);
        Task<bool> IsSlotAvailableAsync(int courtId, DateTime startTime, DateTime endTime);
    }

    public class BookingService : IBookingService
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly IWalletService _walletService;

        public BookingService(ApplicationDbContext dbContext, IWalletService walletService)
        {
            _dbContext = dbContext;
            _walletService = walletService;
        }

        public async Task<BookingDto?> CreateBookingAsync(int memberId, CreateBookingRequest request)
        {
            // Check if slot is available
            if (!await IsSlotAvailableAsync(request.CourtId, request.StartTime, request.EndTime))
                return null;

            var court = await _dbContext.Courts.FindAsync(request.CourtId);
            if (court == null || !court.IsActive)
                return null;

            // Calculate price
            var duration = (request.EndTime - request.StartTime).TotalHours;
            var totalPrice = (decimal)duration * court.PricePerHour;

            // Check wallet balance
            var balance = await _walletService.GetBalanceAsync(memberId);
            if (balance < totalPrice)
                return null;

            // Deduct from wallet
            var deducted = await _walletService.DeductBalanceAsync(
                memberId, 
                totalPrice, 
                $"Booking court {court.Name} from {request.StartTime:yyyy-MM-dd HH:mm} to {request.EndTime:yyyy-MM-dd HH:mm}"
            );

            if (!deducted)
                return null;

            // Create booking
            var booking = new Booking
            {
                CourtId = request.CourtId,
                MemberId = memberId,
                StartTime = request.StartTime,
                EndTime = request.EndTime,
                TotalPrice = totalPrice,
                Status = BookingStatus.Confirmed,
                CreatedDate = DateTime.UtcNow
            };

            _dbContext.Bookings.Add(booking);
            await _dbContext.SaveChangesAsync();

            return MapToDto(booking);
        }

        public async Task<BookingDto?> CreateRecurringBookingAsync(int memberId, CreateRecurringBookingRequest request)
        {
            var court = await _dbContext.Courts.FindAsync(request.CourtId);
            if (court == null || !court.IsActive)
                return null;

            // Parse recurrence rule
            var bookings = new List<Booking>();
            var currentDate = request.FirstBookingDate;

            for (int i = 0; i < request.OccurrenceCount; i++)
            {
                var startTime = currentDate.Add(request.StartTime);
                var endTime = startTime.Add(request.Duration);

                if (await IsSlotAvailableAsync(request.CourtId, startTime, endTime))
                {
                    var totalPrice = (decimal)request.Duration.TotalHours * court.PricePerHour;
                    var booking = new Booking
                    {
                        CourtId = request.CourtId,
                        MemberId = memberId,
                        StartTime = startTime,
                        EndTime = endTime,
                        TotalPrice = totalPrice,
                        IsRecurring = true,
                        RecurrenceRule = request.RecurrenceRule,
                        Status = BookingStatus.Confirmed,
                        CreatedDate = DateTime.UtcNow
                    };

                    bookings.Add(booking);
                }

                // Calculate next date based on recurrence rule
                currentDate = GetNextRecurrenceDate(currentDate, request.RecurrenceRule);
            }

            _dbContext.Bookings.AddRange(bookings);
            await _dbContext.SaveChangesAsync();

            return bookings.Count > 0 ? MapToDto(bookings.First()) : null;
        }

        public async Task<bool> CancelBookingAsync(int bookingId)
        {
            var booking = await _dbContext.Bookings.FindAsync(bookingId);
            if (booking == null || booking.Status == BookingStatus.Cancelled)
                return false;

            booking.Status = BookingStatus.Cancelled;

            // Refund if booked less than 24 hours ago
            var hoursUntilBooking = (booking.StartTime - DateTime.UtcNow).TotalHours;
            if (hoursUntilBooking > 24)
            {
                await _walletService.RefundBalanceAsync(
                    booking.MemberId,
                    booking.TotalPrice,
                    $"Refund for cancelled booking"
                );
            }

            await _dbContext.SaveChangesAsync();
            return true;
        }

        public async Task<List<BookingDto>> GetMemberBookingsAsync(int memberId)
        {
            var bookings = await _dbContext.Bookings
                .Include(b => b.Court)
                .Include(b => b.Member)
                .Where(b => b.MemberId == memberId)
                .OrderByDescending(b => b.StartTime)
                .ToListAsync();

            return bookings.Select(MapToDto).ToList();
        }

        public async Task<List<BookingDto>> GetAvailableSlotsAsync(int courtId, DateTime date)
        {
            var dayStart = date.Date;
            var dayEnd = date.Date.AddDays(1);

            var bookings = await _dbContext.Bookings
                .Include(b => b.Court)
                .Where(b => b.CourtId == courtId && 
                           b.StartTime >= dayStart && 
                           b.EndTime <= dayEnd &&
                           b.Status != BookingStatus.Cancelled)
                .OrderBy(b => b.StartTime)
                .ToListAsync();

            return bookings.Select(MapToDto).ToList();
        }

        public async Task<bool> IsSlotAvailableAsync(int courtId, DateTime startTime, DateTime endTime)
        {
            var conflict = await _dbContext.Bookings
                .Where(b => b.CourtId == courtId &&
                           b.Status != BookingStatus.Cancelled &&
                           b.StartTime < endTime &&
                           b.EndTime > startTime)
                .FirstOrDefaultAsync();

            return conflict == null;
        }

        private DateTime GetNextRecurrenceDate(DateTime current, string rule)
        {
            // Simple implementation: rule format "Weekly;Tue,Thu"
            if (rule.StartsWith("Weekly"))
            {
                return current.AddDays(1); // Simplified for demo
            }
            return current.AddDays(1);
        }

        private BookingDto MapToDto(Booking booking)
        {
            return new BookingDto
            {
                Id = booking.Id,
                CourtId = booking.CourtId,
                MemberId = booking.MemberId,
                Court = booking.Court != null ? new CourtDto
                {
                    Id = booking.Court.Id,
                    Name = booking.Court.Name,
                    IsActive = booking.Court.IsActive,
                    Description = booking.Court.Description,
                    PricePerHour = booking.Court.PricePerHour
                } : null,
                Member = booking.Member != null ? new MemberDto
                {
                    Id = booking.Member.Id,
                    FullName = booking.Member.FullName,
                    JoinDate = booking.Member.JoinDate,
                    RankLevel = booking.Member.RankLevel,
                    IsActive = booking.Member.IsActive,
                    WalletBalance = booking.Member.WalletBalance,
                    Tier = booking.Member.Tier.ToString(),
                    TotalSpent = booking.Member.TotalSpent,
                    AvatarUrl = booking.Member.AvatarUrl
                } : null,
                StartTime = booking.StartTime,
                EndTime = booking.EndTime,
                TotalPrice = booking.TotalPrice,
                IsRecurring = booking.IsRecurring,
                RecurrenceRule = booking.RecurrenceRule,
                Status = booking.Status.ToString(),
                CreatedDate = booking.CreatedDate
            };
        }
    }
}
