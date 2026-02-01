using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Identity;
using PCM.API.DTOs;

namespace PCM.API.Controllers
{
    [ApiController]
    [Route("debug")]
    public class DebugAuthController : ControllerBase
    {
        private readonly UserManager<IdentityUser> _userManager;

        public DebugAuthController(UserManager<IdentityUser> userManager)
        {
            _userManager = userManager;
        }

        [HttpPost("check-login")]
        public async Task<IActionResult> CheckLogin([FromBody] LoginRequest request)
        {
            if (request == null || string.IsNullOrEmpty(request.Username))
                return BadRequest(new { message = "Missing username" });

            var user = await _userManager.FindByNameAsync(request.Username);
            if (user == null)
            {
                return Ok(new { found = false });
            }

            var passwordValid = await _userManager.CheckPasswordAsync(user, request.Password);

            return Ok(new
            {
                found = true,
                userId = user.Id,
                userName = user.UserName,
                normalizedUserName = user.NormalizedUserName,
                email = user.Email,
                passwordValid = passwordValid,
                passwordHash = user.PasswordHash
            });
        }

        [HttpPost("generate-hash")]
        public IActionResult GenerateHash([FromBody] PasswordRequest request)
        {
            if (string.IsNullOrEmpty(request.Password))
                return BadRequest(new { message = "Missing password" });

            var hasher = new PasswordHasher<IdentityUser>();
            var hash = hasher.HashPassword(new IdentityUser(), request.Password);

            return Ok(new
            {
                password = request.Password,
                hash = hash
            });
        }

        [HttpPost("set-password")]
        public async Task<IActionResult> SetPassword([FromBody] SetPasswordRequest request)
        {
            var user = await _userManager.FindByNameAsync(request.Username);
            if (user == null)
                return BadRequest(new { message = "User not found" });

            // Reset password using UserManager
            var token = await _userManager.GeneratePasswordResetTokenAsync(user);
            var result = await _userManager.ResetPasswordAsync(user, token, request.NewPassword);

            if (result.Succeeded)
            {
                return Ok(new { message = "Password reset successfully", user = user.UserName });
            }
            else
            {
                return BadRequest(new { message = string.Join(", ", result.Errors.Select(e => e.Description)) });
            }
        }

        public class PasswordRequest
        {
            public string Password { get; set; }
        }

        public class SetPasswordRequest
        {
            public string Username { get; set; }
            public string NewPassword { get; set; }
        }
    }
}
