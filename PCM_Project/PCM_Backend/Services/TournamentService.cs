using Microsoft.EntityFrameworkCore;
using PCM.API.Data;
using PCM.API.DTOs;
using PCM.API.Models;

namespace PCM.API.Services
{
    public interface ITournamentService
    {
        Task<TournamentDto?> CreateTournamentAsync(CreateTournamentRequest request);
        Task<TournamentDto?> UpdateTournamentAsync(int id, UpdateTournamentRequest request);
        Task<List<TournamentDto>> GetTournamentsAsync();
        Task<List<TournamentParticipantDto>> GetParticipantsAsync(int tournamentId);
        Task<TournamentDto?> GetTournamentAsync(int id);
        Task<bool> JoinTournamentAsync(int memberId, int tournamentId, string? teamName = null);
        Task<bool> LeaveTournamentAsync(int memberId, int tournamentId);
        Task<bool> GenerateScheduleAsync(int tournamentId);
        Task<bool> DeleteTournamentAsync(int id);
    }

    public class TournamentService : ITournamentService
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly IWalletService _walletService;

        public TournamentService(ApplicationDbContext dbContext, IWalletService walletService)
        {
            _dbContext = dbContext;
            _walletService = walletService;
        }

        public async Task<TournamentDto?> CreateTournamentAsync(CreateTournamentRequest request)
        {
            // Parse format enum from string
            if (!Enum.TryParse<TournamentFormat>(request.Format, true, out var format))
                return null;

            var tournament = new Tournament
            {
                Name = request.Name,
                StartDate = request.StartDate,
                EndDate = request.EndDate,
                Format = format,
                Status = TournamentStatus.Open,
                EntryFee = request.EntryFee,
                PrizePool = request.PrizePool,
                Settings = request.Settings
            };

            _dbContext.Tournaments.Add(tournament);
            await _dbContext.SaveChangesAsync();

            return MapToDto(tournament);
        }

        public async Task<List<TournamentDto>> GetTournamentsAsync()
        {
            var tournaments = await _dbContext.Tournaments
                .Include(t => t.Participants)
                .ToListAsync();

            return tournaments.Select(MapToDto).ToList();
        }

        public async Task<TournamentDto?> GetTournamentAsync(int id)
        {
            var tournament = await _dbContext.Tournaments
                .Include(t => t.Participants)
                .Include(t => t.Matches)
                .FirstOrDefaultAsync(t => t.Id == id);

            return tournament == null ? null : MapToDto(tournament);
        }

        public async Task<bool> JoinTournamentAsync(int memberId, int tournamentId, string? teamName = null)
        {
            var tournament = await _dbContext.Tournaments
                .Include(t => t.Participants)
                .FirstOrDefaultAsync(t => t.Id == tournamentId);

            if (tournament == null || tournament.Status != TournamentStatus.Open)
                return false;

            // Check if already joined
            var existing = await _dbContext.TournamentParticipants
                .FirstOrDefaultAsync(p => p.TournamentId == tournamentId && p.MemberId == memberId);

            if (existing != null)
                return false;

            // Deduct entry fee
            var deductSuccess = await _walletService.DeductBalanceAsync(
                memberId,
                tournament.EntryFee,
                $"Tournament registration: {tournament.Name}",
                tournamentId.ToString()
            );

            if (!deductSuccess)
                return false;

            var participant = new TournamentParticipant
            {
                TournamentId = tournamentId,
                MemberId = memberId,
                TeamName = teamName,
                PaymentStatusCompleted = true,
                RegisteredDate = DateTime.UtcNow
            };

            _dbContext.TournamentParticipants.Add(participant);
            await _dbContext.SaveChangesAsync();

            return true;
        }

        public async Task<bool> LeaveTournamentAsync(int memberId, int tournamentId)
        {
            var participant = await _dbContext.TournamentParticipants
                .FirstOrDefaultAsync(p => p.TournamentId == tournamentId && p.MemberId == memberId);

            if (participant == null)
                return false;

            var tournament = await _dbContext.Tournaments.FindAsync(tournamentId);
            if (tournament != null)
            {
                // Refund entry fee if tournament hasn't started
                if (tournament.Status == TournamentStatus.Open)
                {
                    await _walletService.RefundBalanceAsync(
                        memberId,
                        tournament.EntryFee,
                        $"Tournament cancellation: {tournament.Name}",
                        tournamentId.ToString()
                    );
                }
            }

            _dbContext.TournamentParticipants.Remove(participant);
            await _dbContext.SaveChangesAsync();

            return true;
        }

        public async Task<bool> GenerateScheduleAsync(int tournamentId)
        {
            var tournament = await _dbContext.Tournaments
                .Include(t => t.Participants)
                .FirstOrDefaultAsync(t => t.Id == tournamentId);

            if (tournament == null || tournament.Participants.Count == 0)
                return false;

            // Clear existing matches
            var existingMatches = await _dbContext.Matches
                .Where(m => m.TournamentId == tournamentId)
                .ToListAsync();

            _dbContext.Matches.RemoveRange(existingMatches);

            if (tournament.Format == TournamentFormat.RoundRobin)
            {
                await GenerateRoundRobinMatches(tournament);
            }
            else
            {
                await GenerateKnockoutMatches(tournament);
            }

            await _dbContext.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteTournamentAsync(int id)
        {
            var tournament = await _dbContext.Tournaments.FindAsync(id);
            if (tournament == null)
                return false;

            _dbContext.Tournaments.Remove(tournament);
            await _dbContext.SaveChangesAsync();

            return true;
        }

        public async Task<List<TournamentParticipantDto>> GetParticipantsAsync(int tournamentId)
        {
            var participants = await _dbContext.TournamentParticipants
                .Where(p => p.TournamentId == tournamentId)
                .Include(p => p.Member)
                .ToListAsync();

            return participants.Select(p => new TournamentParticipantDto
            {
                Id = p.Id,
                MemberId = p.MemberId,
                TeamName = p.TeamName,
                RegisteredDate = p.RegisteredDate,
                MemberFullName = p.Member?.FullName
            }).ToList();
        }

        public async Task<TournamentDto?> UpdateTournamentAsync(int id, UpdateTournamentRequest request)
        {
            var tournament = await _dbContext.Tournaments.FindAsync(id);
            if (tournament == null)
                return null;

            if (!Enum.TryParse<TournamentFormat>(request.Format, true, out var format))
                return null;

            tournament.Name = request.Name;
            tournament.StartDate = request.StartDate;
            tournament.EndDate = request.EndDate;
            tournament.Format = format;
            tournament.EntryFee = request.EntryFee;
            tournament.PrizePool = request.PrizePool;
            tournament.Settings = request.Settings;

            _dbContext.Tournaments.Update(tournament);
            await _dbContext.SaveChangesAsync();

            return MapToDto(tournament);
        }

        private async Task GenerateRoundRobinMatches(Tournament tournament)
        {
            var participants = tournament.Participants.ToList();
            var matches = new List<Match>();
            int roundNumber = 1;

            for (int i = 0; i < participants.Count; i++)
            {
                for (int j = i + 1; j < participants.Count; j++)
                {
                    matches.Add(new Match
                    {
                        TournamentId = tournament.Id,
                        Team1_Player1Id = participants[i].MemberId,
                        Team2_Player1Id = participants[j].MemberId,
                        RoundName = $"Round {roundNumber}",
                        Status = MatchStatus.Scheduled,
                        Date = tournament.StartDate.AddDays(roundNumber - 1),
                        StartTime = new TimeSpan(9, 0, 0)
                    });
                }
                roundNumber++;
            }

            await _dbContext.Matches.AddRangeAsync(matches);
        }

        private async Task GenerateKnockoutMatches(Tournament tournament)
        {
            var participants = tournament.Participants.OrderBy(p => Guid.NewGuid()).ToList();
            var matches = new List<Match>();

            // First round - pair up participants
            for (int i = 0; i < participants.Count; i += 2)
            {
                if (i + 1 < participants.Count)
                {
                    matches.Add(new Match
                    {
                        TournamentId = tournament.Id,
                        Team1_Player1Id = participants[i].MemberId,
                        Team2_Player1Id = participants[i + 1].MemberId,
                        RoundName = "Quarter Final",
                        Status = MatchStatus.Scheduled,
                        Date = tournament.StartDate,
                        StartTime = new TimeSpan(9, 0, 0)
                    });
                }
            }

            await _dbContext.Matches.AddRangeAsync(matches);
        }

        private TournamentDto MapToDto(Tournament tournament)
        {
            return new TournamentDto
            {
                Id = tournament.Id,
                Name = tournament.Name,
                StartDate = tournament.StartDate,
                EndDate = tournament.EndDate,
                Format = tournament.Format.ToString(),
                Status = tournament.Status.ToString(),
                EntryFee = tournament.EntryFee,
                PrizePool = tournament.PrizePool,
                ParticipantCount = tournament.Participants.Count
            };
        }
    }
}
