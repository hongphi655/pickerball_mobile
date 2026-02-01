$ErrorActionPreference='Stop'
try {
    $login = Invoke-RestMethod -Uri 'http://localhost:5001/api/auth/login' -Method Post -Body (@{Username='admin';Password='Admin123!'} | ConvertTo-Json) -ContentType 'application/json'
    Write-Output "LOGIN_SUCCESS"
    Write-Output ($login | ConvertTo-Json -Depth 5)
    $token = $login.data.token

    $body = @{
        Name = 'Auto Test Tournament'
        StartDate = (Get-Date).AddDays(7).ToString('o')
        EndDate = (Get-Date).AddDays(8).ToString('o')
        Format = 'Knockout'
        EntryFee = 100000
        PrizePool = 500000
    }
    $json = $body | ConvertTo-Json -Depth 5
    Write-Output "BODY:$json"

    $headers = @{ Authorization = 'Bearer ' + $token }
    $resp = Invoke-RestMethod -Uri 'http://localhost:5001/api/tournaments' -Method Post -Body $json -ContentType 'application/json' -Headers $headers
    Write-Output "CREATE_SUCCESS"
    Write-Output ($resp | ConvertTo-Json -Depth 5)
} catch {
    Write-Output "ERROR"
    if ($_.Exception.Response -ne $null) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd()
        Write-Output $body
    } else {
        Write-Output $_.Exception.Message
    }
    exit 1
}
