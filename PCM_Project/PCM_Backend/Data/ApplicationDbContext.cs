using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using PCM.API.Models;

namespace PCM.API.Data
{
    public class ApplicationDbContext : IdentityDbContext<IdentityUser>
    {
        // Use prefix "001" - REPLACE WITH YOUR ACTUAL MSSV (Last 3 digits)
        private const string TablePrefix = "001";

        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // DbSets - Named with prefix as per requirements
        public DbSet<Member> Members { get; set; }
        public DbSet<WalletTransaction> WalletTransactions { get; set; }
        public DbSet<News> News { get; set; }
        public DbSet<Court> Courts { get; set; }
        public DbSet<Booking> Bookings { get; set; }
        public DbSet<Tournament> Tournaments { get; set; }
        public DbSet<TournamentParticipant> TournamentParticipants { get; set; }
        public DbSet<Match> Matches { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<TransactionCategory> TransactionCategories { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Configure table names with prefix
            builder.Entity<Member>().ToTable($"{TablePrefix}_Members");
            builder.Entity<WalletTransaction>().ToTable($"{TablePrefix}_WalletTransactions");
            builder.Entity<News>().ToTable($"{TablePrefix}_News");
            builder.Entity<Court>().ToTable($"{TablePrefix}_Courts");
            builder.Entity<Booking>().ToTable($"{TablePrefix}_Bookings");
            builder.Entity<Tournament>().ToTable($"{TablePrefix}_Tournaments");
            builder.Entity<TournamentParticipant>().ToTable($"{TablePrefix}_TournamentParticipants");
            builder.Entity<Match>().ToTable($"{TablePrefix}_Matches");
            builder.Entity<Notification>().ToTable($"{TablePrefix}_Notifications");
            builder.Entity<TransactionCategory>().ToTable($"{TablePrefix}_TransactionCategories");

            // Relationships
            builder.Entity<Member>()
                .HasMany(m => m.WalletTransactions)
                .WithOne(wt => wt.Member)
                .HasForeignKey(wt => wt.MemberId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Member>()
                .HasMany(m => m.Bookings)
                .WithOne(b => b.Member)
                .HasForeignKey(b => b.MemberId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Member>()
                .HasMany(m => m.TournamentParticipants)
                .WithOne(tp => tp.Member)
                .HasForeignKey(tp => tp.MemberId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Member>()
                .HasMany(m => m.Notifications)
                .WithOne(n => n.Receiver)
                .HasForeignKey(n => n.ReceiverId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Court>()
                .HasMany(c => c.Bookings)
                .WithOne(b => b.Court)
                .HasForeignKey(b => b.CourtId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Tournament>()
                .HasMany(t => t.Participants)
                .WithOne(tp => tp.Tournament)
                .HasForeignKey(tp => tp.TournamentId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Tournament>()
                .HasMany(t => t.Matches)
                .WithOne(m => m.Tournament)
                .HasForeignKey(m => m.TournamentId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure decimal precision
            builder.Entity<Member>()
                .Property(m => m.WalletBalance)
                .HasPrecision(18, 2);

            builder.Entity<Member>()
                .Property(m => m.TotalSpent)
                .HasPrecision(18, 2);

            builder.Entity<WalletTransaction>()
                .Property(wt => wt.Amount)
                .HasPrecision(18, 2);

            builder.Entity<Court>()
                .Property(c => c.PricePerHour)
                .HasPrecision(18, 2);

            builder.Entity<Booking>()
                .Property(b => b.TotalPrice)
                .HasPrecision(18, 2);

            builder.Entity<Tournament>()
                .Property(t => t.EntryFee)
                .HasPrecision(18, 2);

            builder.Entity<Tournament>()
                .Property(t => t.PrizePool)
                .HasPrecision(18, 2);

            // Enum conversions
            builder.Entity<Member>()
                .Property(m => m.Tier)
                .HasConversion<string>();

            builder.Entity<WalletTransaction>()
                .Property(wt => wt.Type)
                .HasConversion<string>();

            builder.Entity<WalletTransaction>()
                .Property(wt => wt.Status)
                .HasConversion<string>();

            builder.Entity<Booking>()
                .Property(b => b.Status)
                .HasConversion<string>();

            builder.Entity<Tournament>()
                .Property(t => t.Format)
                .HasConversion<string>();

            builder.Entity<Tournament>()
                .Property(t => t.Status)
                .HasConversion<string>();

            builder.Entity<Match>()
                .Property(m => m.Status)
                .HasConversion<string>();

            builder.Entity<Match>()
                .Property(m => m.WinningSide)
                .HasConversion<string>();
        }
    }
}
