using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PCM.API.DTOs;
using Microsoft.EntityFrameworkCore;
using PCM.API.Data;
using PCM.API.Models;

namespace PCM.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class CourtsController : ControllerBase
    {
        private readonly ApplicationDbContext _dbContext;

        public CourtsController(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetCourts()
        {
            var courts = await _dbContext.Courts
                .Where(c => c.IsActive)
                .ToListAsync();

            var courtDtos = courts.Select(c => new CourtDto
            {
                Id = c.Id,
                Name = c.Name,
                IsActive = c.IsActive,
                Description = c.Description,
                Location = c.Location,
                PricePerHour = c.PricePerHour
            }).ToList();

            return Ok(new ApiResponse<List<CourtDto>>
            {
                Success = true,
                Data = courtDtos
            });
        }

        // Debug endpoint to inspect courts count
        [HttpGet("debug")]
        [AllowAnonymous]
        public async Task<IActionResult> GetCourtsDebug()
        {
            var count = await _dbContext.Courts.CountAsync();
            var first = await _dbContext.Courts.Take(5).ToListAsync();
            return Ok(new ApiResponse<object>
            {
                Success = true,
                Data = new { Count = count, Sample = first }
            });
        }

        [HttpPost]
        public async Task<IActionResult> CreateCourt([FromBody] CreateCourtRequest request)
        {
            var court = new Court
            {
                Name = request.Name,
                Description = request.Description,
                Location = request.Location,
                PricePerHour = request.PricePerHour,
                IsActive = true
            };

            _dbContext.Courts.Add(court);
            await _dbContext.SaveChangesAsync();

            var courtDto = new CourtDto
            {
                Id = court.Id,
                Name = court.Name,
                IsActive = court.IsActive,
                Description = court.Description,
                Location = court.Location,
                PricePerHour = court.PricePerHour
            };

            return Ok(new ApiResponse<CourtDto>
            {
                Success = true,
                Message = "Court created successfully",
                Data = courtDto
            });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCourt(int id, [FromBody] UpdateCourtRequest request)
        {
            var court = await _dbContext.Courts.FindAsync(id);
            if (court == null)
                return NotFound();

            court.Name = request.Name;
            court.Description = request.Description;
            court.Location = request.Location;
            court.PricePerHour = request.PricePerHour;
            court.IsActive = request.IsActive;

            await _dbContext.SaveChangesAsync();

            var courtDto = new CourtDto
            {
                Id = court.Id,
                Name = court.Name,
                IsActive = court.IsActive,
                Description = court.Description,
                Location = court.Location,
                PricePerHour = court.PricePerHour
            };

            return Ok(new ApiResponse<CourtDto>
            {
                Success = true,
                Message = "Court updated successfully",
                Data = courtDto
            });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCourt(int id)
        {
            var court = await _dbContext.Courts.FindAsync(id);
            if (court == null)
                return NotFound();

            _dbContext.Courts.Remove(court);
            await _dbContext.SaveChangesAsync();

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Court deleted successfully"
            });
        }
    }
}
