using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using PCM.API.Data;
using PCM.API.Services;
using PCM.API.Models;
using System.Text;

Console.WriteLine("[Startup] Starting application build...");
var builder = WebApplication.CreateBuilder(args);

// Force development environment
if (!builder.Environment.IsDevelopment())
{
    builder.Environment.EnvironmentName = "Development";
}
Console.WriteLine($"[Startup] Environment: {builder.Environment.EnvironmentName}");

Console.WriteLine("[Startup] Configuring DbContext...");
try
{
    builder.Services.AddDbContext<ApplicationDbContext>(options =>
        options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")), 
        ServiceLifetime.Transient);
    Console.WriteLine("[Startup] DbContext configured successfully");
}
catch (Exception ex)
{
    Console.WriteLine($"[Startup] ERROR configuring DbContext: {ex.Message}");
    throw;
}

Console.WriteLine("[Startup] Configuring Identity...");
builder.Services.AddIdentity<IdentityUser, IdentityRole>()
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddDefaultTokenProviders();
Console.WriteLine("[Startup] Identity configured successfully");

// Add Services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IWalletService, WalletService>();
builder.Services.AddScoped<IBookingService, BookingService>();
builder.Services.AddScoped<ITournamentService, TournamentService>();

// Add Authentication with JWT
var jwtSecret = builder.Configuration["Jwt:Secret"] ?? throw new InvalidOperationException("JWT Secret not configured");
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret)),
        ValidateIssuer = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidateAudience = true,
        ValidAudience = builder.Configuration["Jwt:Audience"],
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
    };
});

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

// Add Controllers
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add SignalR
builder.Services.AddSignalR();

// Bind Kestrel to explicit localhost port 5001 to avoid conflicts with other processes
builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenLocalhost(5001);
});
var app = builder.Build();
Console.WriteLine("[Startup] WebApplication built successfully");

// Exception handling middleware - FIRST
app.Use(async (context, next) =>
{
    try
    {
        Console.WriteLine($"[Middleware] {context.Request.Method} {context.Request.Path}");
        await next();
        Console.WriteLine($"[Middleware] Response status: {context.Response.StatusCode}");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[Middleware] Exception caught: {ex.GetType().Name}: {ex.Message}");
        Console.WriteLine($"[Middleware] Stack: {ex.StackTrace}");
        context.Response.StatusCode = 500;
        await context.Response.WriteAsJsonAsync(new { error = ex.Message });
    }
});

// Middleware
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Disable HTTPS redirect for local testing
// app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Add a simple health check endpoint
app.MapGet("/health", () => Results.Ok(new { status = "ok", timestamp = DateTime.UtcNow }));

// Configure SignalR Hubs
app.MapHub<PcmHub>("/hubs/pcm");

Console.WriteLine("[Startup] Configuration complete!");
Console.WriteLine("[Startup] Server will listen on http://localhost:5001");
Console.WriteLine("[Startup] Calling app.Run()...");

app.Run();

Console.WriteLine("[Startup] app.Run() exited");

// SignalR Hub
public class PcmHub : Microsoft.AspNetCore.SignalR.Hub
{
    public async Task ReceiveNotification(string userId, string message)
    {
        await Clients.User(userId).SendAsync("ReceiveNotification", message);
    }

    public async Task UpdateCalendar(string message)
    {
        await Clients.All.SendAsync("UpdateCalendar", message);
    }

    public async Task UpdateMatchScore(string matchId, int score1, int score2)
    {
        await Clients.Group($"match-{matchId}").SendAsync("UpdateMatchScore", score1, score2);
    }

    public async Task JoinMatchGroup(string matchId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"match-{matchId}");
    }
}
