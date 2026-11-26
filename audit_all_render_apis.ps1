param(
    [string]$BaseUrl = "https://two6-10-02-educhain.onrender.com"
)

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "   FULL END-TO-END RENDER PRODUCTION API AUDIT & TEST SUITE" -ForegroundColor Cyan
Write-Host "   Target: $BaseUrl" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$results = [System.Collections.Generic.List[PSCustomObject]]::new()

function Test-Api {
    param(
        [string]$Category,
        [string]$Name,
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [string]$ContentType = "application/json"
    )

    $fullUrl = "$BaseUrl$Endpoint"
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $status = 0
    $errMsg = ""
    $respBody = ""

    try {
        $params = @{
            Uri = $fullUrl
            Method = $Method
            TimeoutSec = 20
            UseBasicParsing = $true
            ErrorAction = "Stop"
        }
        if ($Headers.Count -gt 0) { $params.Headers = $Headers }
        if ($Body) {
            $params.Body = $Body
            $params.ContentType = $ContentType
        }

        $res = Invoke-WebRequest @params
        $sw.Stop()
        $status = [int]$res.StatusCode
        $respBody = $res.Content
        $passed = ($status -ge 200 -and $status -lt 300)
    } catch [System.Net.WebException] {
        $sw.Stop()
        if ($_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = [System.IO.StreamReader]::new($stream)
            $respBody = $reader.ReadToEnd()
        }
        $errMsg = $_.Exception.Message
        $passed = $false
    } catch {
        $sw.Stop()
        $errMsg = $_.Exception.Message
        $passed = $false
    }

    $preview = if ($respBody.Length -gt 80) { $respBody.Substring(0, 80) + "..." } else { $respBody }
    $preview = $preview -replace "[\r\n]", " "

    $color = if ($passed) { "Green" } else { "Red" }
    Write-Host "[$Category] $Method $Endpoint -> HTTP $status ($($sw.ElapsedMilliseconds)ms)" -ForegroundColor $color
    if (-not $passed -and $errMsg) {
        Write-Host "   Details: $errMsg | Body: $preview" -ForegroundColor Yellow
    }

    $results.Add([PSCustomObject]@{
        Category = $Category
        Name = $Name
        Method = $Method
        Endpoint = $Endpoint
        Status = $status
        Passed = $passed
        DurationMs = $sw.ElapsedMilliseconds
        Message = if ($errMsg) { $errMsg } else { "OK" }
        Preview = $preview
    })

    return $respBody
}

# --- 1. SYSTEM & HEALTH ---
Test-Api -Category "System" -Name "Home Web Page" -Method "GET" -Endpoint "/"
Test-Api -Category "System" -Name "Database Health Probe" -Method "GET" -Endpoint "/api/db/health"

# --- 2. AUTHENTICATION & TOKENS ---
$adminLoginJson = @{ email = "admin@apex.edu"; password = "password123" } | ConvertTo-Json
$adminAuthRaw = Test-Api -Category "Auth" -Name "Admin Login" -Method "POST" -Endpoint "/api/auth/admin/login" -Body $adminLoginJson
$adminToken = ""
if ($adminAuthRaw) {
    try { $adminToken = ($adminAuthRaw | ConvertFrom-Json).token } catch {}
}

# Direct Admin Login (/api/admin/login)
Test-Api -Category "Auth" -Name "Direct Admin Login" -Method "POST" -Endpoint "/api/admin/login" -Body $adminLoginJson

# Institute Login (/api/auth/institute/login & /api/institutes/login)
$instLoginJson = @{ instituteCode = "INST-2025"; password = "edlearn123" } | ConvertTo-Json
$instAuthRaw = Test-Api -Category "Auth" -Name "Institute Login" -Method "POST" -Endpoint "/api/auth/institute/login" -Body $instLoginJson
Test-Api -Category "Auth" -Name "Direct Institute Login" -Method "POST" -Endpoint "/api/institutes/login" -Body $instLoginJson

# Role Login: Teacher & Student
$teacherLoginJson = @{ email = "amit.sharma@institute.com"; password = "password123"; role = "teacher" } | ConvertTo-Json
$teacherAuthRaw = Test-Api -Category "Auth" -Name "Teacher Login" -Method "POST" -Endpoint "/api/auth/login" -Body $teacherLoginJson
$teacherToken = ""
if ($teacherAuthRaw) {
    try { $teacherToken = ($teacherAuthRaw | ConvertFrom-Json).token } catch {}
}

$studentLoginJson = @{ email = "rahul@institute.com"; password = "password123"; role = "student" } | ConvertTo-Json
$studentAuthRaw = Test-Api -Category "Auth" -Name "Student Login" -Method "POST" -Endpoint "/api/auth/login" -Body $studentLoginJson
$studentToken = ""
if ($studentAuthRaw) {
    try { $studentToken = ($studentAuthRaw | ConvertFrom-Json).token } catch {}
}

$adminHeaders = @{ Authorization = "Bearer $adminToken" }
$teacherHeaders = @{ Authorization = "Bearer $teacherToken" }
$studentHeaders = @{ Authorization = "Bearer $studentToken" }

# Forgot password
$forgotJson = @{ email = "rahul@institute.com"; role = "student" } | ConvertTo-Json
Test-Api -Category "Auth" -Name "Forgot Password" -Method "POST" -Endpoint "/api/auth/forgot-password" -Body $forgotJson

# --- 3. DATABASE ADMIN & DIAGNOSTICS ---
Test-Api -Category "Database" -Name "Database Console" -Method "GET" -Endpoint "/api/db/console" -Headers $adminHeaders
Test-Api -Category "Database" -Name "Database Institutes" -Method "GET" -Endpoint "/api/db/institutes" -Headers $adminHeaders
Test-Api -Category "Database" -Name "Database Users" -Method "GET" -Endpoint "/api/db/users" -Headers $adminHeaders

# --- 4. DASHBOARD APIS ---
Test-Api -Category "Dashboard" -Name "Admin Dashboard" -Method "GET" -Endpoint "/api/dashboard/admin" -Headers $adminHeaders
Test-Api -Category "Dashboard" -Name "Instructor Dashboard" -Method "GET" -Endpoint "/api/dashboard/instructor" -Headers $teacherHeaders
Test-Api -Category "Dashboard" -Name "Student Dashboard" -Method "GET" -Endpoint "/api/dashboard/student" -Headers $studentHeaders

# --- 5. STUDENTS APIS ---
$studentsRaw = Test-Api -Category "Students" -Name "List Students (Admin)" -Method "GET" -Endpoint "/api/students" -Headers $adminHeaders
Test-Api -Category "Students" -Name "List Students (Teacher)" -Method "GET" -Endpoint "/api/students" -Headers $teacherHeaders
Test-Api -Category "Students" -Name "Search Students" -Method "GET" -Endpoint "/api/students?search=rahul" -Headers $adminHeaders

# --- 6. INSTRUCTORS APIS ---
$instructorsRaw = Test-Api -Category "Instructors" -Name "List Instructors" -Method "GET" -Endpoint "/api/instructors" -Headers $adminHeaders
Test-Api -Category "Instructors" -Name "Search Instructors" -Method "GET" -Endpoint "/api/instructors?search=amit" -Headers $adminHeaders

# --- 7. COURSES & BATCHES APIS ---
Test-Api -Category "Courses" -Name "List Courses" -Method "GET" -Endpoint "/api/courses" -Headers $adminHeaders
Test-Api -Category "Courses" -Name "List Batches" -Method "GET" -Endpoint "/api/batches" -Headers $adminHeaders
Test-Api -Category "Courses" -Name "List My Enrollments (Student)" -Method "GET" -Endpoint "/api/enrollments/my" -Headers $studentHeaders

# --- 8. CLASSROOMS APIS ---
$classroomsRaw = Test-Api -Category "Classrooms" -Name "List Classrooms" -Method "GET" -Endpoint "/api/classrooms" -Headers $teacherHeaders
Test-Api -Category "Classrooms" -Name "List Public Classrooms" -Method "GET" -Endpoint "/api/public/classrooms"

$targetClassroomId = ""
if ($classroomsRaw) {
    try {
        $parsedClassrooms = $classroomsRaw | ConvertFrom-Json
        if ($parsedClassrooms.Count -gt 0) { $targetClassroomId = $parsedClassrooms[0].id }
    } catch {}
}
if ($targetClassroomId) {
    Test-Api -Category "Classrooms" -Name "Classroom Comments" -Method "GET" -Endpoint "/api/classrooms/$targetClassroomId/comments" -Headers $teacherHeaders
}

# --- 9. ASSIGNMENTS APIS ---
Test-Api -Category "Assignments" -Name "List Assignments (Admin)" -Method "GET" -Endpoint "/api/assignments" -Headers $adminHeaders

# --- 10. EXAMINATIONS & QUESTION BANK APIS ---
Test-Api -Category "Exams" -Name "List Exams (Student)" -Method "GET" -Endpoint "/api/portal/exams" -Headers $studentHeaders
Test-Api -Category "Exams" -Name "List Exams (Teacher)" -Method "GET" -Endpoint "/api/portal/exams" -Headers $teacherHeaders
$questionsRaw = Test-Api -Category "Exams" -Name "Exam Questions Bank" -Method "GET" -Endpoint "/api/exam-questions" -Headers $teacherHeaders

$targetQId = ""
if ($questionsRaw) {
    try {
        $parsedQ = $questionsRaw | ConvertFrom-Json
        if ($parsedQ.Count -gt 0) { $targetQId = $parsedQ[0].id }
    } catch {}
}
if ($targetQId) {
    Test-Api -Category "Exams" -Name "Question Versions" -Method "GET" -Endpoint "/api/exam-questions/$targetQId/versions" -Headers $teacherHeaders
}

# --- 11. CLASSES & SCHEDULE ---
Test-Api -Category "Classes" -Name "List Classes" -Method "GET" -Endpoint "/api/classes" -Headers $studentHeaders
Test-Api -Category "Classes" -Name "Upcoming Classes" -Method "GET" -Endpoint "/api/classes/upcoming" -Headers $studentHeaders
Test-Api -Category "Classes" -Name "Class History" -Method "GET" -Endpoint "/api/classes/history" -Headers $studentHeaders

# --- 12. LIVE CLASSES (GOOGLE MEET) ---
Test-Api -Category "LiveClasses" -Name "Upcoming Live Classes" -Method "GET" -Endpoint "/api/live-classes/upcoming" -Headers $studentHeaders

# --- 13. PORTAL MODULES (ANNOUNCEMENTS, LEAVES, NOTIFICATIONS, ADMIN) ---
Test-Api -Category "Portal" -Name "Announcements List" -Method "GET" -Endpoint "/api/portal/announcements" -Headers $studentHeaders
Test-Api -Category "Portal" -Name "Leaves List (Admin)" -Method "GET" -Endpoint "/api/portal/leaves" -Headers $adminHeaders
Test-Api -Category "Portal" -Name "Leaves List (Teacher)" -Method "GET" -Endpoint "/api/portal/leaves" -Headers $teacherHeaders
Test-Api -Category "Portal" -Name "Notifications List" -Method "GET" -Endpoint "/api/portal/notifications" -Headers $studentHeaders
Test-Api -Category "Portal" -Name "Unread Notifications Count" -Method "GET" -Endpoint "/api/portal/notifications/unread-count" -Headers $studentHeaders
Test-Api -Category "Portal" -Name "Admin Assignment Options" -Method "GET" -Endpoint "/api/portal/admin/assignment-options" -Headers $adminHeaders

# --- 14. FILE STORAGE APIS ---
Test-Api -Category "Files" -Name "Storage Info (Cloudinary Status)" -Method "GET" -Endpoint "/api/files/info" -Headers $adminHeaders
Test-Api -Category "Files" -Name "List Stored Files" -Method "GET" -Endpoint "/api/files/list" -Headers $adminHeaders

Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "                      AUDIT SUMMARY RESULTS                      " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$passedCount = ($results | Where-Object { $_.Passed }).Count
$failedCount = ($results | Where-Object { -not $_.Passed }).Count
$totalCount  = $results.Count

Write-Host "Total APIs Tested:    $totalCount"
Write-Host "Passed (HTTP 2xx):   $passedCount" -ForegroundColor Green
Write-Host "Failed (Non-2xx):    $failedCount" -ForegroundColor $(if ($failedCount -eq 0) { "Green" } else { "Red" })

if ($failedCount -gt 0) {
    Write-Host "`nFailed Endpoints Breakdown:" -ForegroundColor Red
    $results | Where-Object { -not $_.Passed } | Format-Table -Property Category, Name, Method, Endpoint, Status, Message
}

Write-Host "=================================================================" -ForegroundColor Cyan
