using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PCM.API.DTOs;
using PCM.API.Services;
using System.Security.Claims;

namespace PCM.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class WalletController : ControllerBase
    {
        private readonly IWalletService _walletService;

        public WalletController(IWalletService walletService)
        {
            _walletService = walletService;
        }

        [HttpPost("deposit")]
        public async Task<IActionResult> Deposit([FromBody] WalletDepositRequest request)
        {
            var memberId = int.Parse(User.FindFirst("MemberId")?.Value ?? "0");
            if (memberId == 0)
                return Unauthorized();

            var transaction = await _walletService.DepositAsync(memberId, request);
            return Ok(new ApiResponse<WalletTransactionDto>
            {
                Success = true,
                Message = "Deposit request submitted. Awaiting admin approval.",
                Data = transaction
            });
        }

        [HttpGet("transactions")]
        public async Task<IActionResult> GetTransactions([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10)
        {
            var memberId = int.Parse(User.FindFirst("MemberId")?.Value ?? "0");
            if (memberId == 0)
                return Unauthorized();

            var transactions = await _walletService.GetTransactionHistoryAsync(memberId, pageNumber, pageSize);
            return Ok(new ApiResponse<List<WalletTransactionDto>>
            {
                Success = true,
                Message = "Transactions retrieved",
                Data = transactions
            });
        }

        [HttpGet("balance")]
        public async Task<IActionResult> GetBalance()
        {
            try
            {
                Console.WriteLine("[GetBalance] Fetching wallet balance");
                
                // Allow admin to bypass MemberId requirement
                var isAdmin = User.IsInRole("Admin");
                Console.WriteLine($"[GetBalance] IsAdmin: {isAdmin}");
                
                if (isAdmin)
                {
                    // Admin doesn't need wallet balance
                    return Ok(new ApiResponse<decimal>
                    {
                        Success = true,
                        Message = "Admin user - no wallet balance",
                        Data = 0
                    });
                }
                
                var memberId = int.Parse(User.FindFirst("MemberId")?.Value ?? "0");
                if (memberId == 0)
                {
                    Console.WriteLine("[GetBalance] Error: MemberId not found in token");
                    return Unauthorized(new { message = "MemberId not found in token" });
                }

                var balance = await _walletService.GetBalanceAsync(memberId);
                Console.WriteLine($"[GetBalance] Balance retrieved: {balance}");
                return Ok(new ApiResponse<decimal>
                {
                    Success = true,
                    Data = balance
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GetBalance] Error: {ex.GetType().Name} - {ex.Message}");
                return StatusCode(500, new ApiResponse<object>
                {
                    Success = false,
                    Message = $"Error fetching balance: {ex.Message}"
                });
            }
        }

        [HttpPut("approve/{transactionId}")]
        [Authorize(Roles = "Admin,Treasurer")]
        public async Task<IActionResult> ApproveDeposit(int transactionId)
        {
            var transaction = await _walletService.ApproveDepositAsync(transactionId);
            if (transaction == null)
                return BadRequest(new { message = "Transaction not found or already processed" });

            return Ok(new ApiResponse<WalletTransactionDto>
            {
                Success = true,
                Message = "Deposit approved",
                Data = transaction
            });
        }

        [HttpPut("reject/{transactionId}")]
        [Authorize(Roles = "Admin,Treasurer")]
        public async Task<IActionResult> RejectDeposit(int transactionId, [FromQuery] string reason = "")
        {
            var transaction = await _walletService.RejectDepositAsync(transactionId, reason);
            if (transaction == null)
                return BadRequest(new { message = "Transaction not found or already processed" });

            return Ok(new ApiResponse<WalletTransactionDto>
            {
                Success = true,
                Message = "Deposit rejected",
                Data = transaction
            });
        }
    }
}
