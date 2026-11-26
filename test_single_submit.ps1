param(
    [string]$Env = "local",
    [string]$BaseUrl = ""
)

$LocalApiUrl = "http://localhost:5000/api"
$ProdApiUrl  = "https://two6-10-02-educhain.onrender.com/api"

if (-not $BaseUrl) {
    if ($env:EDLEARN_API_URL) {
        $BaseUrl = $env:EDLEARN_API_URL
    } elseif ($Env -eq "prod" -or $Env -eq "production" -or $env:USE_PROD_API -eq "true") {
        $BaseUrl = $ProdApiUrl
    } else {
        $BaseUrl = $LocalApiUrl
    }
}
$baseUrl = $BaseUrl.TrimEnd('/')

# 1. Login Student
$studentLoginBody = @{ email = "rahul@institute.com"; password = "password123"; role = "student" } | ConvertTo-Json
$studentAuth = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -ContentType "application/json" -Body $studentLoginBody
$studentHeaders = @{ Authorization = "Bearer $($studentAuth.token)" }

# 2. Get latest exam
$studentExams = Invoke-RestMethod -Uri "$baseUrl/portal/exams" -Method Get -Headers $studentHeaders
$exam = $studentExams[0]
$examId = $exam.id
Write-Host "Testing Submit on Exam: $($exam.title) ($examId)"

# 3. Submit Exam with Answers Body (Same as Flutter frontend)
$submitBody = @{
    answers = @{
        "1" = "Stack"
        "2" = "O(n)"
    }
} | ConvertTo-Json

$submitRes = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$examId/submit" -Method Post -Headers $studentHeaders -ContentType "application/json" -Body $submitBody
Write-Host "SUCCESS: Exam Submitted!"
Write-Host "Status: $($submitRes.status)"
Write-Host "Obtained Marks: $($submitRes.obtainedMarks) / $($submitRes.totalMarks)"
Write-Host "Percentage: $($submitRes.percentage)%"
