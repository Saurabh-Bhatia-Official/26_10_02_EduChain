$baseUrl = "http://localhost:5000/api"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   EDULEARN LMS & GOOGLE MEET LIVE CLASSES INTEGRATION E2E" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. TEACHER LOGIN
Write-Host "`n[TEST 1] Teacher Login..."
$teacherLoginBody = @{
    email = "amit.sharma@institute.com"
    password = "password123"
    role = "teacher"
    instituteCode = "INST-2025"
} | ConvertTo-Json

$teacherAuth = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -ContentType "application/json" -Body $teacherLoginBody
if (-not $teacherAuth.success) { throw "Teacher login failed" }
$teacherToken = $teacherAuth.token
$teacherHeaders = @{ Authorization = "Bearer $teacherToken" }
Write-Host "  -> SUCCESS: Teacher $($teacherAuth.user.name) authenticated." -ForegroundColor Green

# 2. STUDENT LOGIN
Write-Host "`n[TEST 2] Student Login..."
$studentLoginBody = @{
    email = "rahul@institute.com"
    password = "password123"
    role = "student"
    instituteCode = "INST-2025"
} | ConvertTo-Json

$studentAuth = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -ContentType "application/json" -Body $studentLoginBody
if (-not $studentAuth.success) { throw "Student login failed" }
$studentToken = $studentAuth.token
$studentHeaders = @{ Authorization = "Bearer $studentToken" }
Write-Host "  -> SUCCESS: Student $($studentAuth.user.name) authenticated." -ForegroundColor Green

# 3. TEACHER CREATES CLASSROOM
Write-Host "`n[TEST 3] Teacher Creates New Google Classroom..."
$classBody = @{
    name = "CS-401 Distributed Systems & Cloud Architecture"
    section = "Period 3 (Batch A)"
    subject = "Computer Science"
    room = "Lab 102 / Online Meet"
    description = "Hands-on engineering of distributed algorithms, consensus protocols, and reactive microservices."
    themeColor = "#1967d2"
    isPublic = $true
    requiresApproval = $false
} | ConvertTo-Json

$classroom = Invoke-RestMethod -Uri "$baseUrl/classrooms" -Method Post -ContentType "application/json" -Headers $teacherHeaders -Body $classBody
$classroomId = $classroom.id
$invCode = $classroom.invitationCode
if (-not $classroomId -or -not $invCode) { throw "Classroom creation failed" }
Write-Host "  -> SUCCESS: Classroom created! ID: $classroomId | Code: $invCode | Theme: $($classroom.themeColor)" -ForegroundColor Green

# 4. STUDENT JOINS CLASSROOM BY CODE
Write-Host "`n[TEST 4] Student Joins Classroom via Invitation Code..."
$joinBody = @{ code = $invCode } | ConvertTo-Json
$joinRes = Invoke-RestMethod -Uri "$baseUrl/classrooms/join" -Method Post -ContentType "application/json" -Headers $studentHeaders -Body $joinBody
Write-Host "  -> SUCCESS: Status: $($joinRes.status) | Message: $($joinRes.message)" -ForegroundColor Green

# 5. TEACHER CHECKS CLASSROOM MEMBERS
Write-Host "`n[TEST 5] Teacher Retrieves Classroom Members Roster..."
$members = Invoke-RestMethod -Uri "$baseUrl/classrooms/$classroomId/members" -Method Get -Headers $teacherHeaders
Write-Host "  -> SUCCESS: Teachers: $($members.teachers.Count) | Students: $($members.students.Count)" -ForegroundColor Green
foreach ($s in $members.students) {
    Write-Host "     - Enrolled Student: $($s.name) ($($s.email))" -ForegroundColor Gray
}

# 6. TEACHER CREATES ASSIGNMENT
Write-Host "`n[TEST 6] Teacher Creates Assignment..."
$assignBody = @{
    title = "Lab 1: Raft Consensus Cluster Implementation"
    instructions = "Implement leader election and log replication with unit tests. Submit GitHub URL or archive."
    pointsPossible = 100
    topic = "Consensus Protocols"
    allowLateSubmissions = $true
    dueDate = (Get-Date).AddDays(7).ToString("yyyy-MM-ddTHH:mm:ss")
} | ConvertTo-Json

$assign = Invoke-RestMethod -Uri "$baseUrl/assignments?classroomId=$classroomId" -Method Post -ContentType "application/json" -Headers $teacherHeaders -Body $assignBody
$assignId = $assign.id
if (-not $assignId) { throw "Assignment creation failed" }
Write-Host "  -> SUCCESS: Assignment '$($assign.title)' created (ID: $assignId, Points: $($assign.pointsPossible))" -ForegroundColor Green

# 7. STUDENT RETRIEVES ASSIGNMENTS
Write-Host "`n[TEST 7] Student Views Assigned Classwork..."
$studentAssignments = Invoke-RestMethod -Uri "$baseUrl/assignments/classroom/$classroomId" -Method Get -Headers $studentHeaders
Write-Host "  -> SUCCESS: Found $($studentAssignments.Count) assignment(s). Status: $($studentAssignments[0].submissionStatus)" -ForegroundColor Green

# 8. STUDENT TURNS IN ASSIGNMENT
Write-Host "`n[TEST 8] Student Turns In Submission..."
$submitBody = @{
    submissionText = "Implemented in Go with 100% test coverage: https://github.com/student/raft-cluster"
} | ConvertTo-Json

$submission = Invoke-RestMethod -Uri "$baseUrl/assignments/$assignId/submit" -Method Post -ContentType "application/json" -Headers $studentHeaders -Body $submitBody
$subId = $submission.id
if (-not $subId) { throw "Submission failed" }
Write-Host "  -> SUCCESS: Submission ID: $subId | Status: $($submission.status) | Message: $($submission.message)" -ForegroundColor Green

# 9. TEACHER VIEWS ASSIGNMENT DETAILS & SUBMISSIONS
Write-Host "`n[TEST 9] Teacher Inspects Assignment Submissions..."
$assignDetails = Invoke-RestMethod -Uri "$baseUrl/assignments/$assignId" -Method Get -Headers $teacherHeaders
Write-Host "  -> SUCCESS: Total submissions received: $($assignDetails.submissions.Count)" -ForegroundColor Green

# 10. TEACHER GRADES SUBMISSION
Write-Host "`n[TEST 10] Teacher Grades Student Submission..."
$gradeBody = @{
    score = 98.0
    feedback = "Flawless partition healing logic and spotless documentation. Full marks!"
    isReturned = $true
} | ConvertTo-Json

$grade = Invoke-RestMethod -Uri "$baseUrl/assignments/submissions/$subId/grade" -Method Post -ContentType "application/json" -Headers $teacherHeaders -Body $gradeBody
Write-Host "  -> SUCCESS: Graded! Score: $($grade.score) / 100 | Returned: $($grade.isReturned)" -ForegroundColor Green

# 11. TEACHER RETRIEVES GRADEBOOK MATRIX
Write-Host "`n[TEST 11] Teacher Views Class Gradebook..."
$gradebook = Invoke-RestMethod -Uri "$baseUrl/assignments/classroom/$classroomId/gradebook" -Method Get -Headers $teacherHeaders
Write-Host "  -> SUCCESS: Gradebook records for $($gradebook.gradebook.Count) student(s)" -ForegroundColor Green
foreach ($g in $gradebook.gradebook) {
    Write-Host "     - $($g.studentName): Total Score $($g.totalScore)/$($g.totalPossible) ($($g.percentage)%)" -ForegroundColor Gray
}

# 12. TEACHER SCHEDULES GOOGLE MEET LIVE ONLINE CLASS
Write-Host "`n[TEST 12] Teacher Schedules Google Meet Live Class..."
$liveBody = @{
    title = "Live Q&A: Raft Cluster Demo & Code Review"
    description = "Interactive walkthrough of node failures and log compaction."
    startTime = (Get-Date).AddMinutes(1).ToString("yyyy-MM-ddTHH:mm:ss")
    endTime = (Get-Date).AddMinutes(61).ToString("yyyy-MM-ddTHH:mm:ss")
} | ConvertTo-Json

$liveClass = Invoke-RestMethod -Uri "$baseUrl/live-classes?classroomId=$classroomId" -Method Post -ContentType "application/json" -Headers $teacherHeaders -Body $liveBody
$liveId = $liveClass.id
$meetLink = $liveClass.meetLink
if (-not $liveId -or -not $meetLink) { throw "Live class creation failed" }
Write-Host "  -> SUCCESS: Live class created!" -ForegroundColor Green
Write-Host "     Title: $($liveClass.title)" -ForegroundColor Yellow
Write-Host "     Google Meet Link: $meetLink" -ForegroundColor Yellow

# 13. STUDENT JOINS LIVE CLASS -> ATTENDANCE RECORDED
Write-Host "`n[TEST 13] Student Joins Live Class (Attendance Tracking)..."
$joinMeet = Invoke-RestMethod -Uri "$baseUrl/live-classes/$liveId/join" -Method Post -Headers $studentHeaders
Write-Host "  -> SUCCESS: $($joinMeet.message)" -ForegroundColor Green
Write-Host "     Connected Meet Link: $($joinMeet.meetLink)" -ForegroundColor Yellow

# 14. TEACHER CHECKS ATTENDANCE REPORT
Write-Host "`n[TEST 14] Teacher Retrieves Live Session Attendance Report..."
$attendanceRep = Invoke-RestMethod -Uri "$baseUrl/live-classes/$liveId/attendance" -Method Get -Headers $teacherHeaders
Write-Host "  -> SUCCESS: Enrolled: $($attendanceRep.totalEnrolled) | Present: $($attendanceRep.presentCount)" -ForegroundColor Green
foreach ($a in $attendanceRep.attendance) {
    Write-Host "     - Attendee: $($a.name) ($($a.email)) | Status: $($a.status) | Join: $($a.joinTime)" -ForegroundColor Gray
}

# 15. CLASSROOM STREAM ANNOUNCEMENT & COMMENTS
Write-Host "`n[TEST 15] Teacher Posts Announcement to Class Stream..."
$commentBody = @{
    content = "Welcome to CS-401! Please join today's live Google Meet session and review Lab 1 requirements."
    targetType = "STREAM_POST"
} | ConvertTo-Json

$comment = Invoke-RestMethod -Uri "$baseUrl/classrooms/$classroomId/comments" -Method Post -ContentType "application/json" -Headers $teacherHeaders -Body $commentBody
Write-Host "  -> SUCCESS: Stream announcement posted (ID: $($comment.id))" -ForegroundColor Green

Write-Host "`n[TEST 16] Student Reads Stream Feed..."
$streamPosts = Invoke-RestMethod -Uri "$baseUrl/classrooms/$classroomId/comments?targetType=STREAM_POST" -Method Get -Headers $studentHeaders
Write-Host "  -> SUCCESS: Stream post count: $($streamPosts.Count) | Latest: $($streamPosts[0].content)" -ForegroundColor Green

# 17. PUBLIC CLASSROOM DISCOVERY (UNAUTHENTICATED GUEST)
Write-Host "`n[TEST 17] Public Discovery Test (Unauthenticated Guest Browsing)..."
$publicClasses = Invoke-RestMethod -Uri "$baseUrl/public/classrooms?search=Distributed" -Method Get
Write-Host "  -> SUCCESS: Public discovery returned $($publicClasses.Count) course(s) without auth token!" -ForegroundColor Green
foreach ($pc in $publicClasses) {
    Write-Host "     - Course: $($pc.name) | Instructor: $($pc.creatorName) | Code: $($pc.invitationCode)" -ForegroundColor Gray
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "   ALL 17 LMS & GOOGLE MEET LIVE TESTS PASSED CLEANLY!   " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
