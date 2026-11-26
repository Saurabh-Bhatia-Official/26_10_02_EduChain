param(
    [string]$LocalUrl = "http://localhost:5002",
    [string]$ProdUrl  = "https://two6-10-02-educhain.onrender.com",
    [int]$TimeoutSec  = 15
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " EduChain API Connectivity & Environment Verification" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Testing both Localhost and Production endpoints...`n"

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [int]$Timeout
    )

    Write-Host "[$Name] Testing: $Url" -ForegroundColor Yellow
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Get -TimeoutSec $Timeout -UseBasicParsing -ErrorAction Stop
        $stopwatch.Stop()
        $status = [int]$response.StatusCode
        Write-Host "  -> HTTP $status OK ($($stopwatch.ElapsedMilliseconds) ms)" -ForegroundColor Green
        return @{ Success = $true; Status = $status; Duration = $stopwatch.ElapsedMilliseconds; Body = $response.Content }
    } catch [System.Net.WebException] {
        $stopwatch.Stop()
        $res = $_.Exception.Response
        if ($res) {
            $status = [int]$res.StatusCode
            Write-Host "  -> HTTP $status ($($stopwatch.ElapsedMilliseconds) ms)" -ForegroundColor Yellow
            return @{ Success = $false; Status = $status; Duration = $stopwatch.ElapsedMilliseconds; Error = $_.Exception.Message }
        } else {
            Write-Host "  -> Connection Failed: $($_.Exception.Message)" -ForegroundColor Red
            return @{ Success = $false; Status = 0; Duration = $stopwatch.ElapsedMilliseconds; Error = $_.Exception.Message }
        }
    } catch {
        $stopwatch.Stop()
        Write-Host "  -> Error: $($_.Exception.Message)" -ForegroundColor Red
        return @{ Success = $false; Status = 0; Duration = $stopwatch.ElapsedMilliseconds; Error = $_.Exception.Message }
    }
}

Write-Host "--- 1. Production API Connectivity (Render) ---" -ForegroundColor Cyan
$prodRootRes   = Test-Endpoint -Name "Prod Root URL"   -Url "$ProdUrl/" -Timeout $TimeoutSec
$prodHealthRes = Test-Endpoint -Name "Prod DB Health"  -Url "$ProdUrl/api/db/health" -Timeout $TimeoutSec

Write-Host "`n--- 2. Localhost API Connectivity ---" -ForegroundColor Cyan
$localRootRes   = Test-Endpoint -Name "Local Root URL"  -Url "$LocalUrl/" -Timeout 3
$localHealthRes = Test-Endpoint -Name "Local DB Health" -Url "$LocalUrl/api/db/health" -Timeout 3

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " Connectivity Summary" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Production Root:   $($prodRootRes.Status) ($($prodRootRes.Duration) ms)"
Write-Host "Production Health: $($prodHealthRes.Status) ($($prodHealthRes.Duration) ms)"
if ($localRootRes.Success) {
    Write-Host "Localhost Root:    $($localRootRes.Status) ($($localRootRes.Duration) ms)" -ForegroundColor Green
    Write-Host "Localhost Health:  $($localHealthRes.Status) ($($localHealthRes.Duration) ms)" -ForegroundColor Green
} else {
    Write-Host "Localhost Service: Offline / Not currently running locally (expected when dev server is stopped)" -ForegroundColor Gray
}
Write-Host "==========================================================" -ForegroundColor Cyan
