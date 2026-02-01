using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using PCM.API.Data;
using PCM.API.DTOs;
using PCM.API.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace PCM.API.Services
{
    public interface IAuthService
    {
        Task<LoginResponse?> LoginAsync(LoginRequest request);
        Task<IdentityResult> RegisterAsync(RegisterRequest request);
        string GenerateJwtToken(IdentityUser user, Member? member = null, IList<string>? roles = null);
    }

    public class AuthService : IAuthService
    {
        private readonly UserManager<IdentityUser> _userManager;
        private readonly IConfiguration _configuration;
        private readonly ApplicationDbContext _dbContext;

        public AuthService(UserManager<IdentityUser> userManager, IConfiguration configuration, ApplicationDbContext dbContext)
        {
            _userManager = userManager;
            _configuration = configuration;
            _dbContext = dbContext;
        }

        public async Task<LoginResponse?> LoginAsync(LoginRequest request)
        {
            // Hardcoded admin for testing/demo purposes
            if (request.Username == "admin" && request.Password == "Admin123!")
            {
                var adminToken = GenerateJwtToken(
                    new IdentityUser { Id = "admin-id", UserName = "admin", Email = "admin@pcm.com" }, 
                    null, 
                    new[] { "Admin" }
                );
                
                return new LoginResponse
                {
                    Token = adminToken,
                    User = new UserInfoDto
                    {
                        Id = "admin-id",
                        Username = "admin",
                        Email = "admin@pcm.com",
                        Member = null,
                        Roles = new List<string> { "Admin" }
                    }
                };
            }

            // Try to find user in database
            var user = await _userManager.FindByNameAsync(request.Username);
            if (user == null)
            {
                return null;
            }

            // Verify password
            var passwordValid = await _userManager.CheckPasswordAsync(user, request.Password);
            if (!passwordValid)
            {
                return null;
            }

            // Get user roles
            var roles = await _userManager.GetRolesAsync(user);

            // Get member info if exists
            Member? member = null;
            try
            {
                member = await _dbContext.Members.FirstOrDefaultAsync(m => m.UserId == user.Id);
            }
            catch
            {
                // Members table might not exist or be configured yet
            }

            // Generate JWT token
            var token = GenerateJwtToken(user, member, roles);

            return new LoginResponse
            {
                Token = token,
                User = new UserInfoDto
                {
                    Id = user.Id,
                    Username = user.UserName ?? string.Empty,
                    Email = user.Email ?? string.Empty,
                    Member = member != null ? new MemberDto
                    {
                        Id = member.Id,
                        FullName = member.FullName,
                        JoinDate = member.JoinDate,
                        WalletBalance = member.WalletBalance
                    } : null,
                    Roles = roles.ToList()
                }
            };
        }

        public async Task<IdentityResult> RegisterAsync(RegisterRequest request)
        {
            var user = new IdentityUser { UserName = request.Username, Email = request.Email };
            var result = await _userManager.CreateAsync(user, request.Password);

            if (result.Succeeded)
            {
                var member = new Member
                {
                    UserId = user.Id,
                    FullName = request.FullName,
                    JoinDate = DateTime.UtcNow,
                    IsActive = true,
                    Tier = MemberTier.Standard,
                    WalletBalance = 0
                };

                _dbContext.Members.Add(member);
                await _dbContext.SaveChangesAsync();
            }

            return result;
        }

        public string GenerateJwtToken(IdentityUser user, Member? member = null, IList<string>? roles = null)
        {
            var secretKey = _configuration["Jwt:Secret"] ?? throw new InvalidOperationException("JWT Secret not configured");
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Name, user.UserName ?? ""),
                new Claim(ClaimTypes.Email, user.Email ?? ""),
            };

            // Add MemberId if member exists
            if (member != null)
            {
                claims.Add(new Claim("MemberId", member.Id.ToString()));
            }

            if (roles != null)
            {
                foreach (var role in roles)
                {
                    claims.Add(new Claim(ClaimTypes.Role, role));
                }
            }

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(double.Parse(_configuration["Jwt:ExpirationMinutes"] ?? "1440")),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
