using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Identity;
using PCM.API.Data;
using PCM.API.Models;

namespace PCM.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DebugController : ControllerBase
    {
        private readonly UserManager<IdentityUser> _userManager;
        private readonly ApplicationDbContext _dbContext;

        public DebugController(UserManager<IdentityUser> userManager, ApplicationDbContext dbContext)
        {
            _userManager = userManager;
            _dbContext = dbContext;
        }

        [HttpGet("users")]
        public async Task<IActionResult> GetUsers()
        {
            var users = _userManager.Users.Select(u => new { u.Id, u.UserName, u.Email }).ToList();
            return Ok(new { Success = true, Data = users });
        }

        [HttpGet("user/{username}")]
        public async Task<IActionResult> GetUser(string username)
        {
            var user = await _userManager.FindByNameAsync(username);
            if (user == null) return NotFound(new { Success = false, Message = "User not found" });

            var member = _dbContext.Members.FirstOrDefault(m => m.UserId == user.Id);
            return Ok(new { Success = true, Data = new { user.Id, user.UserName, user.Email, Member = member } });
        }
    }
}
