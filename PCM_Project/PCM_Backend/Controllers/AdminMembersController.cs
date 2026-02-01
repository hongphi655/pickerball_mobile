using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PCM.API.Data;
using PCM.API.DTOs;
using PCM.API.Models;

namespace PCM.API.Controllers
{
    [ApiController]
    [Route("api/admin/[controller]")]
    [Authorize(Roles = "Admin")]
    public class MembersController : ControllerBase
    {
        private readonly ApplicationDbContext _dbContext;

        public MembersController(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        [HttpGet]
        public async Task<IActionResult> GetMembers([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10)
        {
            try
            {
                Console.WriteLine($"[GetMembers] Request: page={pageNumber}, size={pageSize}");
                
                var members = await _dbContext.Members
                    .Include(m => m.User)
                    .OrderBy(m => m.FullName)
                    .Skip((pageNumber - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();

                Console.WriteLine($"[GetMembers] Found {members.Count} members");

                var memberDtos = members.Select(m => new MemberDto
                {
                    Id = m.Id,
                    FullName = m.FullName,
                    JoinDate = m.JoinDate,
                    RankLevel = m.RankLevel,
                    IsActive = m.IsActive,
                    WalletBalance = m.WalletBalance,
                    Tier = m.Tier.ToString(),
                    TotalSpent = m.TotalSpent,
                    AvatarUrl = m.AvatarUrl
                }).ToList();

                return Ok(new ApiResponse<List<MemberDto>>
                {
                    Success = true,
                    Data = memberDtos
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GetMembers] ERROR: {ex.GetType().Name}: {ex.Message}");
                Console.WriteLine($"[GetMembers] Stack: {ex.StackTrace}");
                return StatusCode(500, new ApiResponse<List<MemberDto>>
                {
                    Success = false,
                    Message = $"Error retrieving members: {ex.Message}",
                    Data = null
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetMember(int id)
        {
            var member = await _dbContext.Members
                .Include(m => m.Bookings)
                .Include(m => m.WalletTransactions)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (member == null)
                return NotFound();

            var memberDto = new MemberDto
            {
                Id = member.Id,
                FullName = member.FullName,
                JoinDate = member.JoinDate,
                RankLevel = member.RankLevel,
                IsActive = member.IsActive,
                WalletBalance = member.WalletBalance,
                Tier = member.Tier.ToString(),
                TotalSpent = member.TotalSpent,
                AvatarUrl = member.AvatarUrl
            };

            return Ok(new ApiResponse<MemberDto>
            {
                Success = true,
                Data = memberDto
            });
        }

        [HttpPost]
        public async Task<IActionResult> CreateMember([FromBody] MemberUpdateDto request)
        {
            var member = new Member
            {
                FullName = request.FullName,
                JoinDate = DateTime.UtcNow,
                IsActive = true,
                Tier = MemberTier.Standard,
                AvatarUrl = request.AvatarUrl,
                WalletBalance = 0,
                RankLevel = 0
            };

            _dbContext.Members.Add(member);
            await _dbContext.SaveChangesAsync();

            var memberDto = new MemberDto
            {
                Id = member.Id,
                FullName = member.FullName,
                JoinDate = member.JoinDate,
                RankLevel = member.RankLevel,
                IsActive = member.IsActive,
                WalletBalance = member.WalletBalance,
                Tier = member.Tier.ToString(),
                TotalSpent = member.TotalSpent,
                AvatarUrl = member.AvatarUrl
            };

            return Ok(new ApiResponse<MemberDto>
            {
                Success = true,
                Message = "Member created successfully",
                Data = memberDto
            });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateMember(int id, [FromBody] MemberUpdateDto request)
        {
            var member = await _dbContext.Members.FindAsync(id);
            if (member == null)
                return NotFound();

            member.FullName = request.FullName;
            member.AvatarUrl = request.AvatarUrl;

            await _dbContext.SaveChangesAsync();

            var memberDto = new MemberDto
            {
                Id = member.Id,
                FullName = member.FullName,
                JoinDate = member.JoinDate,
                RankLevel = member.RankLevel,
                IsActive = member.IsActive,
                WalletBalance = member.WalletBalance,
                Tier = member.Tier.ToString(),
                TotalSpent = member.TotalSpent,
                AvatarUrl = member.AvatarUrl
            };

            return Ok(new ApiResponse<MemberDto>
            {
                Success = true,
                Message = "Member updated successfully",
                Data = memberDto
            });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteMember(int id)
        {
            var member = await _dbContext.Members.FindAsync(id);
            if (member == null)
                return NotFound();

            _dbContext.Members.Remove(member);
            await _dbContext.SaveChangesAsync();

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Member deleted successfully"
            });
        }

        [HttpGet("pending-deposits")]
        public async Task<IActionResult> GetPendingDeposits()
        {
            var pendingTransactions = await _dbContext.WalletTransactions
                .Include(wt => wt.Member)
                .Where(wt => wt.Type == TransactionType.Deposit && wt.Status == TransactionStatus.Pending)
                .OrderBy(wt => wt.CreatedDate)
                .ToListAsync();

            var transactionDtos = pendingTransactions.Select(wt => new WalletTransactionDto
            {
                Id = wt.Id,
                MemberId = wt.MemberId,
                Amount = wt.Amount,
                Type = wt.Type.ToString(),
                Status = wt.Status.ToString(),
                RelatedId = wt.RelatedId,
                Description = wt.Description,
                CreatedDate = wt.CreatedDate,
                ProofImageUrl = wt.ProofImageUrl
            }).ToList();

            return Ok(new ApiResponse<List<WalletTransactionDto>>
            {
                Success = true,
                Data = transactionDtos
            });
        }

        [HttpGet("revenue-summary")]
        public async Task<IActionResult> GetRevenueSummary()
        {
            var totalDeposited = await _dbContext.WalletTransactions
                .Where(wt => wt.Type == TransactionType.Deposit && wt.Status == TransactionStatus.Completed)
                .SumAsync(wt => wt.Amount);

            var totalSpent = await _dbContext.WalletTransactions
                .Where(wt => wt.Type == TransactionType.Payment && wt.Status == TransactionStatus.Completed)
                .SumAsync(wt => wt.Amount);

            var totalRefunded = await _dbContext.WalletTransactions
                .Where(wt => wt.Type == TransactionType.Refund && wt.Status == TransactionStatus.Completed)
                .SumAsync(wt => wt.Amount);

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Data = new
                {
                    TotalDeposited = totalDeposited,
                    TotalSpent = totalSpent,
                    TotalRefunded = totalRefunded,
                    NetRevenue = totalDeposited - totalSpent - totalRefunded
                }
            });
        }
    }
}
