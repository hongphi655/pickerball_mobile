using Microsoft.EntityFrameworkCore;
using PCM.API.Data;
using PCM.API.DTOs;
using PCM.API.Models;

namespace PCM.API.Services
{
    public interface IWalletService
    {
        Task<WalletTransactionDto> DepositAsync(int memberId, WalletDepositRequest request);
        Task<WalletTransactionDto?> ApproveDepositAsync(int transactionId);
        Task<WalletTransactionDto?> RejectDepositAsync(int transactionId, string reason);
        Task<List<WalletTransactionDto>> GetTransactionHistoryAsync(int memberId, int pageNumber = 1, int pageSize = 10);
        Task<bool> DeductBalanceAsync(int memberId, decimal amount, string description, string? relatedId = null);
        Task<bool> RefundBalanceAsync(int memberId, decimal amount, string description, string? relatedId = null);
        Task<decimal> GetBalanceAsync(int memberId);
    }

    public class WalletService : IWalletService
    {
        private readonly ApplicationDbContext _dbContext;

        public WalletService(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<WalletTransactionDto> DepositAsync(int memberId, WalletDepositRequest request)
        {
            var transaction = new WalletTransaction
            {
                MemberId = memberId,
                Amount = request.Amount,
                Type = TransactionType.Deposit,
                Status = TransactionStatus.Pending,
                ProofImageUrl = request.ProofImageUrl,
                Description = request.Description ?? "Member deposit request",
                CreatedDate = DateTime.UtcNow
            };

            _dbContext.WalletTransactions.Add(transaction);
            await _dbContext.SaveChangesAsync();

            return MapToDto(transaction);
        }

        public async Task<WalletTransactionDto?> ApproveDepositAsync(int transactionId)
        {
            var transaction = await _dbContext.WalletTransactions.FindAsync(transactionId);
            if (transaction == null || transaction.Status != TransactionStatus.Pending)
                return null;

            var member = await _dbContext.Members.FindAsync(transaction.MemberId);
            if (member == null)
                return null;

            // Update transaction status
            transaction.Status = TransactionStatus.Completed;

            // Update member wallet balance
            member.WalletBalance += transaction.Amount;

            await _dbContext.SaveChangesAsync();

            return MapToDto(transaction);
        }

        public async Task<WalletTransactionDto?> RejectDepositAsync(int transactionId, string reason)
        {
            var transaction = await _dbContext.WalletTransactions.FindAsync(transactionId);
            if (transaction == null || transaction.Status != TransactionStatus.Pending)
                return null;

            transaction.Status = TransactionStatus.Rejected;
            transaction.Description = $"Rejected: {reason}";

            await _dbContext.SaveChangesAsync();

            return MapToDto(transaction);
        }

        public async Task<List<WalletTransactionDto>> GetTransactionHistoryAsync(int memberId, int pageNumber = 1, int pageSize = 10)
        {
            var transactions = await _dbContext.WalletTransactions
                .Where(wt => wt.MemberId == memberId)
                .OrderByDescending(wt => wt.CreatedDate)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return transactions.Select(MapToDto).ToList();
        }

        public async Task<bool> DeductBalanceAsync(int memberId, decimal amount, string description, string? relatedId = null)
        {
            var member = await _dbContext.Members.FindAsync(memberId);
            if (member == null || member.WalletBalance < amount)
                return false;

            var transaction = new WalletTransaction
            {
                MemberId = memberId,
                Amount = -amount,
                Type = TransactionType.Payment,
                Status = TransactionStatus.Completed,
                Description = description,
                RelatedId = relatedId,
                CreatedDate = DateTime.UtcNow
            };

            member.WalletBalance -= amount;
            member.TotalSpent += amount;

            _dbContext.WalletTransactions.Add(transaction);
            await _dbContext.SaveChangesAsync();

            return true;
        }

        public async Task<bool> RefundBalanceAsync(int memberId, decimal amount, string description, string? relatedId = null)
        {
            var member = await _dbContext.Members.FindAsync(memberId);
            if (member == null)
                return false;

            var transaction = new WalletTransaction
            {
                MemberId = memberId,
                Amount = amount,
                Type = TransactionType.Refund,
                Status = TransactionStatus.Completed,
                Description = description,
                RelatedId = relatedId,
                CreatedDate = DateTime.UtcNow
            };

            member.WalletBalance += amount;

            _dbContext.WalletTransactions.Add(transaction);
            await _dbContext.SaveChangesAsync();

            return true;
        }

        public async Task<decimal> GetBalanceAsync(int memberId)
        {
            var member = await _dbContext.Members.FindAsync(memberId);
            return member?.WalletBalance ?? 0;
        }

        private static WalletTransactionDto MapToDto(WalletTransaction transaction)
        {
            return new WalletTransactionDto
            {
                Id = transaction.Id,
                MemberId = transaction.MemberId,
                Amount = transaction.Amount,
                Type = transaction.Type.ToString(),
                Status = transaction.Status.ToString(),
                RelatedId = transaction.RelatedId,
                Description = transaction.Description,
                CreatedDate = transaction.CreatedDate,
                ProofImageUrl = transaction.ProofImageUrl
            };
        }
    }
}
