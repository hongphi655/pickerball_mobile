using Microsoft.AspNetCore.Mvc;
using PCM.API.DTOs;
using PCM.API.Services;

namespace PCM.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            try
            {
                Console.WriteLine($"[AuthController] Login request received for user: {request.Username}");
                Console.WriteLine($"[AuthController] Password provided: {(!string.IsNullOrEmpty(request.Password) ? "Yes" : "No")}");
                
                var result = await _authService.LoginAsync(request);
                
                if (result == null)
                {
                    Console.WriteLine($"[AuthController] LoginAsync returned null for user: {request.Username}");
                    return Unauthorized(new ApiResponse<object>
                    {
                        Success = false,
                        Message = "Invalid credentials"
                    });
                }

                Console.WriteLine($"[AuthController] Login successful for user: {request.Username}");
                return Ok(new ApiResponse<LoginResponse>
                {
                    Success = true,
                    Message = "Login successful",
                    Data = result
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AuthController] Exception in Login: {ex.Message}");
                Console.WriteLine($"[AuthController] Stack trace: {ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    Console.WriteLine($"[AuthController] Inner exception: {ex.InnerException.Message}");
                }
                return StatusCode(500, new ApiResponse<object>
                {
                    Success = false,
                    Message = $"Server error: {ex.Message}"
                });
            }
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            var result = await _authService.RegisterAsync(request);
            if (!result.Succeeded)
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = string.Join(", ", result.Errors.Select(e => e.Description))
                });

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Registration successful"
            });
        }
    }
}

