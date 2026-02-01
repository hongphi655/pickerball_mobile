using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PCM.API.DTOs;
using PCM.API.Services;

namespace PCM.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BookingsController : ControllerBase
    {
        private readonly IBookingService _bookingService;

        public BookingsController(IBookingService bookingService)
        {
            _bookingService = bookingService;
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreateBooking([FromBody] CreateBookingRequest request)
        {
            var memberId = int.Parse(User.FindFirst("MemberId")?.Value ?? "0");
            if (memberId == 0)
                return Unauthorized();

            var booking = await _bookingService.CreateBookingAsync(memberId, request);
            if (booking == null)
                return BadRequest(new { message = "Failed to create booking. Check slot availability and wallet balance." });

            return Ok(new ApiResponse<BookingDto>
            {
                Success = true,
                Message = "Booking created successfully",
                Data = booking
            });
        }

        [HttpPost("recurring")]
        [Authorize]
        public async Task<IActionResult> CreateRecurringBooking([FromBody] CreateRecurringBookingRequest request)
        {
            var memberId = int.Parse(User.FindFirst("MemberId")?.Value ?? "0");
            if (memberId == 0)
                return Unauthorized();

            var booking = await _bookingService.CreateRecurringBookingAsync(memberId, request);
            if (booking == null)
                return BadRequest(new { message = "Failed to create recurring booking" });

            return Ok(new ApiResponse<BookingDto>
            {
                Success = true,
                Message = "Recurring booking created successfully",
                Data = booking
            });
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> CancelBooking(int id)
        {
            var success = await _bookingService.CancelBookingAsync(id);
            if (!success)
                return BadRequest(new { message = "Failed to cancel booking" });

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Booking cancelled successfully"
            });
        }

        [HttpGet("my-bookings")]
        [Authorize]
        public async Task<IActionResult> GetMyBookings()
        {
            var memberId = int.Parse(User.FindFirst("MemberId")?.Value ?? "0");
            if (memberId == 0)
                return Unauthorized();

            var bookings = await _bookingService.GetMemberBookingsAsync(memberId);
            return Ok(new ApiResponse<List<BookingDto>>
            {
                Success = true,
                Data = bookings
            });
        }

        [HttpGet("calendar")]
        public async Task<IActionResult> GetCalendar([FromQuery] int courtId, [FromQuery] DateTime date)
        {
            var bookings = await _bookingService.GetAvailableSlotsAsync(courtId, date);
            return Ok(new ApiResponse<List<BookingDto>>
            {
                Success = true,
                Data = bookings
            });
        }
    }
}
