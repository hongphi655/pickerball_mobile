$ErrorActionPreference = 'Stop'
# Login as admin
$loginBody = @{ Username = 'admin'; Password = 'Admin123!' } | ConvertTo-Json
$loginResp = Invoke-RestMethod -Uri 'http://localhost:5001/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'
Write-Output "LOGIN_RESPONSE:"; $loginResp | ConvertTo-Json -Depth 5

# Extract token
$token = $loginResp.Data.Token
Write-Output "TOKEN: $token"

# Create tournament payload
$tournament = @{
    Name = 'Giai Thu Nghiem'
    StartDate = (Get-Date).AddDays(7).ToString('o')
    EndDate = (Get-Date).AddDays(8).ToString('o')
    Format = 'SingleElimination'
    EntryFee = 100000
    PrizePool = 500000
}
// Convert to JSON and ensure UTF-8 bytes are sent to avoid encoding issues
$tournBody = $tournament | ConvertTo-Json -Depth 5
Write-Output "TOURN_BODY:"; Write-Output $tournBody

 $headers = @{ Authorization = "Bearer $token" }
try {
    $utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($tournBody)
    $createResp = Invoke-RestMethod -Uri 'http://localhost:5001/api/tournaments' -Method Post -Body $utf8Bytes -ContentType 'application/json; charset=utf-8' -Headers $headers
    Write-Output "CREATE_RESPONSE:"; $createResp | ConvertTo-Json -Depth 5
} catch {
    Write-Output "CREATE_FAILED:";
    if ($_.Exception.Response -ne $null) {
        $stream = $_.Exception.Response.GetResponseStream();
        $reader = New-Object System.IO.StreamReader($stream);
        $responseBody = $reader.ReadToEnd();
        Write-Output $responseBody;
    } else {
        Write-Output $_.Exception.Message;
    }
}

# Verify in DB: query using sqlcmd
$sql = "SET NOCOUNT ON; SELECT TOP 5 Id, Name, StartDate, EndDate, EntryFee, PrizePool FROM dbo.[001_Tournaments] ORDER BY Id DESC;"
Write-Output "DB_ROWS:"; 
$sqlCmdOut = & sqlcmd -S .\SQLEXPRESS -d PCM_Database -Q $sql -s"," -W
Write-Output $sqlCmdOut
