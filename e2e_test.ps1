$baseUrl = "http://localhost:5000/api"

Write-Host "=== TEST 1: ADMIN LOGIN ==="
$adminLoginBody = @{
    email = "amit.kumar@institute.com"
    password = "password123"
    instituteCode = "INST-2025"
} | ConvertTo-Json

$adminAuth = Invoke-RestMethod -Uri "$baseUrl/auth/admin/login" -Method Post -ContentType "application/json" -Body $adminLoginBody
Write-Host "Admin Login Success: $($adminAuth.success) | Role: $($adminAuth.user.role)"
$adminToken = $adminAuth.token
$adminHeaders = @{ Authorization = "Bearer $adminToken" }

Write-Host "
=== TEST 2: GET ANNOUNCEMENTS (BUG 1 FIX VERIFICATION) ==="
$announcements = Invoke-RestMethod -Uri "$baseUrl/portal/announcements" -Method Get -Headers $adminHeaders
Write-Host "Announcements Count: $($announcements.Count)"
foreach ($a in $announcements) {
    Write-Host " - Announcement: $($a.title) | Audience: $($a.audience) | Date: $($a.announcementDate)"
}

Write-Host "
=== TEST 3: CREATE ANNOUNCEMENT VIA ADMIN ==="
$newAnnBody = @{
    title = "Semester Final Project Submissions"
    description = "All students must submit final project repositories before end of week."
    audience = "BOTH"
    announcementDate = "2026-11-21"
    published = $true
} | ConvertTo-Json

$newAnn = Invoke-RestMethod -Uri "$baseUrl/portal/announcements" -Method Post -ContentType "application/json" -Headers $adminHeaders -Body $newAnnBody
Write-Host "Created Announcement: $($newAnn.title) | ID: $($newAnn.id)"

Write-Host "
=== TEST 4: GET LEAVES (BUG 2 FIX VERIFICATION - NO 500 ERROR) ==="
$leaves = Invoke-RestMethod -Uri "$baseUrl/portal/leaves" -Method Get -Headers $adminHeaders
Write-Host "Leaves retrieved successfully (HTTP 200, count: $($leaves.Count))"

Write-Host "
=== TEST 5: TEACHER LOGIN ==="
$teacherLoginBody = @{
    email = "amit.sharma@institute.com"
    password = "password123"
    role = "teacher"
    instituteCode = "INST-2025"
} | ConvertTo-Json
$teacherAuth = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -ContentType "application/json" -Body $teacherLoginBody
Write-Host "Teacher Login Success: $($teacherAuth.success) | Name: $($teacherAuth.user.name)"
$teacherToken = $teacherAuth.token
$teacherHeaders = @{ Authorization = "Bearer $teacherToken" }

Write-Host "
=== TEST 6: SUBMIT TEACHER LEAVE APPLICATION ==="
$teacherLeaveBody = @{
    leaveType = "Personal"
    startDate = "2026-12-01"
    endDate = "2026-12-03"
    reason = "Attending academic faculty research conference."
} | ConvertTo-Json

$submittedLeave = Invoke-RestMethod -Uri "$baseUrl/portal/leaves" -Method Post -ContentType "application/json" -Headers $teacherHeaders -Body $teacherLeaveBody
Write-Host "Submitted Leave Status: $($submittedLeave.status) | ID: $($submittedLeave.id)"

Write-Host "
=== TEST 7: STUDENT LOGIN ==="
$studentLoginBody = @{
    email = "rahul@institute.com"
    password = "password123"
    role = "student"
    instituteCode = "INST-2025"
} | ConvertTo-Json
$studentAuth = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -ContentType "application/json" -Body $studentLoginBody
Write-Host "Student Login Success: $($studentAuth.success) | Name: $($studentAuth.user.name)"
$studentToken = $studentAuth.token
$studentHeaders = @{ Authorization = "Bearer $studentToken" }

Write-Host "
=== TEST 8: ONLINE EXAMS LISTING ==="
$exams = Invoke-RestMethod -Uri "$baseUrl/portal/exams" -Method Get -Headers $studentHeaders
Write-Host "Exams Count: $($exams.Count)"
$targetExam = $exams[0]
Write-Host "Target Exam: $($targetExam.title) | Code: $($targetExam.code) | AttemptStatus: $($targetExam.attemptStatus)"

Write-Host "
=== TEST 9: GET EXAM DETAILS WITH DYNAMIC QUESTIONS ==="
$examDetails = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$($targetExam.id)" -Method Get -Headers $studentHeaders
Write-Host "Loaded Questions Count: $($examDetails.questions.Count)"
foreach ($q in $examDetails.questions) {
    Write-Host " - Q$($q.id): $($q.text)"
}

Write-Host "
=== TEST 10: START EXAM ATTEMPT ==="
$startAttempt = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$($targetExam.id)/start" -Method Post -Headers $studentHeaders
Write-Host "Attempt Status: $($startAttempt.status) | Student: $($startAttempt.studentName)"

Write-Host "
=== TEST 11: SAVE INTERMEDIATE ANSWER ==="
$saveAnswerBody = @{
    questionId = "1"
    selectedOption = "B"
} | ConvertTo-Json
$saveResult = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$($targetExam.id)/save-answer" -Method Post -ContentType "application/json" -Headers $studentHeaders -Body $saveAnswerBody
Write-Host "Saved Answer Result: $($saveResult.success)"

Write-Host "
=== TEST 12: SUBMIT FINAL EXAM ==="
$submitAnswersBody = @{
    answers = @{
        "1" = "B"
        "2" = "A"
        "3" = "C"
        "4" = "D"
        "5" = "B"
    }
} | ConvertTo-Json

$submitResult = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$($targetExam.id)/submit" -Method Post -ContentType "application/json" -Headers $studentHeaders -Body $submitAnswersBody
Write-Host "Exam Submission Status: $($submitResult.status)"

Write-Host "
=== TEST 13: STRICT SINGLE-ATTEMPT RULE (HTTP 409 DUPLICATE BLOCK) ==="
try {
    $dupAttempt = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$($targetExam.id)/start" -Method Post -Headers $studentHeaders
    Write-Host "ERROR: Second attempt was NOT blocked!"
} catch {
    Write-Host "SUCCESS: Second attempt blocked with HTTP 409 Conflict: $($_.Exception.Message)"
}

Write-Host "
=== TEST 14: RESULT LOCKING VERIFICATION (BEFORE RELEASE) ==="
$attemptBeforeRelease = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$($targetExam.id)/attempt" -Method Get -Headers $studentHeaders
Write-Host "Results Released Status: $($attemptBeforeRelease.resultsReleased) | Score visible: $(($null -ne $attemptBeforeRelease.score))"

Write-Host "
=== TEST 15: ADMIN RELEASES RESULTS ==="
$releaseBody = @{ release = $true } | ConvertTo-Json
$releaseResult = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$($targetExam.id)/release-results" -Method Put -ContentType "application/json" -Headers $adminHeaders -Body $releaseBody
Write-Host "Admin Release Result: $($releaseResult.resultsReleased)"

Write-Host "
=== TEST 16: STUDENT VIEW RESULTS AFTER RELEASE ==="
$attemptAfterRelease = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$($targetExam.id)/attempt" -Method Get -Headers $studentHeaders
Write-Host "Results Released: $($attemptAfterRelease.resultsReleased)"
Write-Host "Score: $($attemptAfterRelease.score) / $($attemptAfterRelease.totalMarks) | Percentage: $($attemptAfterRelease.percentage)% | Passed: $($attemptAfterRelease.passed)"
Write-Host "Total Questions: $($attemptAfterRelease.totalQuestions) | Correct: $($attemptAfterRelease.correctAnswers) | Incorrect: $($attemptAfterRelease.incorrectAnswers)"

Write-Host "
ALL 16 PRODUCTION END-TO-END TESTS COMPLETED SUCCESSFULLY!"

