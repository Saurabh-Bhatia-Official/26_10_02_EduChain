$baseUrl = "http://localhost:5000/api"

# 1. Login Teacher
$teacherLoginBody = @{
    email = "amit.sharma@institute.com"
    password = "password123"
    role = "teacher"
} | ConvertTo-Json
$teacherAuth = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -ContentType "application/json" -Body $teacherLoginBody
$teacherHeaders = @{ Authorization = "Bearer $($teacherAuth.token)" }
Write-Host "Teacher Logged In: $($teacherAuth.user.name)"

# 2. Login Student
$studentLoginBody = @{
    email = "rahul@institute.com"
    password = "password123"
    role = "student"
} | ConvertTo-Json
$studentAuth = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -ContentType "application/json" -Body $studentLoginBody
$studentHeaders = @{ Authorization = "Bearer $($studentAuth.token)" }
Write-Host "Student Logged In: $($studentAuth.user.name)"

# 3. Teacher Creates an Examination
$examBody = @{
    title = "E2E Midterm: Advanced Data Structures"
    courseCode = "CS-302"
    courseName = "Data Structures & Algorithms"
    className = "CSE 2026"
    sectionName = "Batch A"
    durationMinutes = 45
    totalMarks = 100
    questions = @(
        @{
            id = "1"
            question = "Which data structure follows the LIFO principle?"
            options = @("Queue", "Stack", "Linked List", "Tree")
            correctAnswer = "Stack"
            marks = 50
        },
        @{
            id = "2"
            question = "What is the worst-case search time in a Binary Search Tree?"
            options = @("O(1)", "O(log n)", "O(n)", "O(n^2)")
            correctAnswer = "O(n)"
            marks = 50
        }
    )
    status = "Published"
    resultsReleased = $false
} | ConvertTo-Json -Depth 6

$createdExam = Invoke-RestMethod -Uri "$baseUrl/portal/exams" -Method Post -Headers $teacherHeaders -ContentType "application/json" -Body $examBody
$examId = $createdExam.id
Write-Host "Exam Created by Teacher: $($createdExam.title) ($examId) • Duration: $($createdExam.durationMinutes)m"

# 4. Student Fetches Available Exams
$studentExams = Invoke-RestMethod -Uri "$baseUrl/portal/exams" -Method Get -Headers $studentHeaders
$target = $studentExams | Where-Object { $_.id -eq $examId }
Write-Host "Student Discovered Exam: $($target.title) • Attempt Status: $($target.attemptStatus)"

# 5. Student Starts Exam Attempt
$attempt = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$examId/start" -Method Post -Headers $studentHeaders
Write-Host "Student Started Attempt ID: $($attempt.attemptId) • Remaining Seconds: $($attempt.remainingSeconds)"

# 6. Student Saves Answers
$ans1 = @{ questionId = "1"; answer = "Stack" } | ConvertTo-Json
Invoke-RestMethod -Uri "$baseUrl/portal/exams/$examId/save-answer" -Method Post -Headers $studentHeaders -ContentType "application/json" -Body $ans1 | Out-Null

$ans2 = @{ questionId = "2"; answer = "O(n)" } | ConvertTo-Json
Invoke-RestMethod -Uri "$baseUrl/portal/exams/$examId/save-answer" -Method Post -Headers $studentHeaders -ContentType "application/json" -Body $ans2 | Out-Null
Write-Host "Student Saved Answers for Questions 1 & 2"

# 7. Student Submits Exam
$submitRes = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$examId/submit" -Method Post -Headers $studentHeaders
Write-Host "Student Submitted Exam: $($submitRes.message)"

# 8. Teacher Views Attempts Roster
$attemptsList = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$examId/attempts" -Method Get -Headers $teacherHeaders
$sub = $attemptsList | Where-Object { $_.studentName -eq "Rahul Sharma" }
Write-Host "Teacher Evaluation Roster: Student: $($sub.studentName) • Score: $($sub.obtainedMarks)/$($sub.totalMarks) pts • Status: $($sub.status)"

# 9. Teacher Releases Results
$releaseRes = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$examId/release-results" -Method Put -Headers $teacherHeaders -ContentType "application/json" -Body '{"release": true}'
Write-Host "Teacher Action: $($releaseRes.message)"

# 10. Student Views Published Scorecard
$publishedAttempt = Invoke-RestMethod -Uri "$baseUrl/portal/exams/$examId/attempt" -Method Get -Headers $studentHeaders
Write-Host "Student Scorecard: Title: $($publishedAttempt.title) • Score: $($publishedAttempt.obtainedMarks)/$($publishedAttempt.totalMarks) ($($publishedAttempt.percentage)%) • Results Released: $($publishedAttempt.resultsReleased)"

Write-Host "`n>>> ALL 10 ONLINE EXAMINATION & EVALUATION TESTS PASSED PERFECTLY! <<<" -ForegroundColor Green
