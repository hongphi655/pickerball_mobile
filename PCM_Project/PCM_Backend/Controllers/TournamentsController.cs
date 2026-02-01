using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PCM.API.DTOs;
using PCM.API.Services;

namespace PCM.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TournamentsController : ControllerBase
    {
        private readonly ITournamentService _tournamentService;

        public TournamentsController(ITournamentService tournamentService)
        {
            _tournamentService = tournamentService;
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CreateTournament([FromBody] CreateTournamentRequest request)
        {
            var tournament = await _tournamentService.CreateTournamentAsync(request);
            return Ok(new ApiResponse<TournamentDto>
            {
                Success = true,
                Message = "Tournament created successfully",
                Data = tournament
            });
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateTournament(int id, [FromBody] UpdateTournamentRequest request)
        {
            var tournament = await _tournamentService.UpdateTournamentAsync(id, request);
            if (tournament == null)
                return NotFound(new { message = "Tournament not found or invalid format" });

            return Ok(new ApiResponse<TournamentDto>
            {
                Success = true,
                Message = "Tournament updated successfully",
                Data = tournament
            });
        }

        [HttpGet]
        public async Task<IActionResult> GetAllTournaments()
        {
            try
            {
                Console.WriteLine("[GetAllTournaments] Fetching tournaments");
                var tournaments = await _tournamentService.GetTournamentsAsync();
                Console.WriteLine($"[GetAllTournaments] Success - returned {tournaments?.Count ?? 0} tournaments");
                return Ok(new ApiResponse<List<TournamentDto>>
                {
                    Success = true,
                    Data = tournaments
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GetAllTournaments] Error: {ex.GetType().Name} - {ex.Message}");
                if (ex.InnerException != null)
                    Console.WriteLine($"[GetAllTournaments] Inner Exception: {ex.InnerException.Message}");
                return StatusCode(500, new ApiResponse<object>
                {
                    Success = false,
                    Message = $"Error fetching tournaments: {ex.Message}"
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetTournament(int id)
        {
            var tournament = await _tournamentService.GetTournamentAsync(id);
            if (tournament == null)
                return NotFound();

            return Ok(new ApiResponse<TournamentDto>
            {
                Success = true,
                Data = tournament
            });
        }

        [HttpPost("{id}/join")]
        [Authorize]
        public async Task<IActionResult> JoinTournament(int id, [FromBody] JoinTournamentRequest request)
        {
            var memberId = int.Parse(User.FindFirst("MemberId")?.Value ?? "0");
            if (memberId == 0)
                return Unauthorized();

            var success = await _tournamentService.JoinTournamentAsync(memberId, id, request.TeamName);
            if (!success)
                return BadRequest(new { message = "Failed to join tournament. Check tournament status and wallet balance." });

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Joined tournament successfully"
            });
        }

        [HttpGet("{id}/participants")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetParticipants(int id)
        {
            var participants = await _tournamentService.GetParticipantsAsync(id);
            return Ok(new ApiResponse<List<TournamentParticipantDto>>
            {
                Success = true,
                Data = participants
            });
        }

        [HttpDelete("{id}/leave")]
        [Authorize]
        public async Task<IActionResult> LeaveTournament(int id)
        {
            var memberId = int.Parse(User.FindFirst("MemberId")?.Value ?? "0");
            if (memberId == 0)
                return Unauthorized();

            var success = await _tournamentService.LeaveTournamentAsync(id, memberId);
            if (!success)
                return BadRequest(new { message = "Failed to leave tournament" });

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Left tournament successfully"
            });
        }

        [HttpPost("{id}/generate-schedule")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GenerateSchedule(int id)
        {
            var success = await _tournamentService.GenerateScheduleAsync(id);
            if (!success)
                return BadRequest(new { message = "Failed to generate schedule" });

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Schedule generated successfully"
            });
        }
    }
}
