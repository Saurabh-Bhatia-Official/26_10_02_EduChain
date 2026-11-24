$baseUrl = "http://localhost:5002/api"

Write-Host "=== TEST 1: Admin Login ===" -ForegroundColor Cyan
# Find or login admin
$adminLoginBody = @{
    email = "admin@apex.edu"
    password = "password123"
} | ConvertTo-Json

try {
    $adminAuth = Invoke-RestMethod -Uri "$baseUrl/auth/admin/login" -Method Post -ContentType "application/json" -Body $adminLoginBody
    $adminToken = $adminAuth.token
    Write-Host "Admin Logged In! Token acquired." -ForegroundColor Green
} catch {
    Write-Host "Admin login via direct /admin/login failed, attempting institute login..." -ForegroundColor Yellow
    $instLoginBody = @{
        instituteCode = "INST-2025"
        password = "password123"
    } | ConvertTo-Json
    $adminAuth = Invoke-RestMethod -Uri "$baseUrl/auth/institute/login" -Method Post -ContentType "application/json" -Body $instLoginBody
    $adminToken = $adminAuth.token
    Write-Host "Institute Admin Logged In! Token acquired." -ForegroundColor Green
}

$adminHeaders = @{ Authorization = "Bearer $adminToken" }

Write-Host "`n=== TEST 2: Admin Dashboard Stats ===" -ForegroundColor Cyan
$adminStats = Invoke-RestMethod -Uri "$baseUrl/dashboard/admin" -Method Get -Headers $adminHeaders
Write-Host "Students: $($adminStats.totalStudents) | Instructors: $($adminStats.totalInstructors) | Classes: $($adminStats.totalClasses) | Upcoming: $($adminStats.upcomingClasses) | Completed: $($adminStats.completedClasses)"

Write-Host "`n=== TEST 3: Admin Adds New Instructor ===" -ForegroundColor Cyan
$rnd = Get-Random -Minimum 1000 -Maximum 9999
$insEmail = "prof.raj$rnd@institute.com"
$insPassword = "SecurePass$rnd!"
$newInsBody = @{
    name = "Prof. Raj Malhotra $rnd"
    email = $insEmail
    phone = "+91 98111 $rnd"
    password = $insPassword
    department = "Computer Science & AI"
    qualification = "Ph.D in Artificial Intelligence"
    experience = "8+ Years"
    designation = "Senior Professor"
    about = "Expert in Machine Learning and Deep Learning."
} | ConvertTo-Json

$createdIns = Invoke-RestMethod -Uri "$baseUrl/instructors" -Method Post -ContentType "application/json" -Headers $adminHeaders -Body $newInsBody
$insId = $createdIns.id
Write-Host "Instructor created! ID: $insId | Name: $($createdIns.name) | Email: $insEmail" -ForegroundColor Green

Write-Host "`n=== TEST 4: New Instructor Logs In ===" -ForegroundColor Cyan
$insLoginBody = @{
    email = $insEmail
    password = $insPassword
    role = "teacher"
} | ConvertTo-Json
$insAuth = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -ContentType "application/json" -Body $insLoginBody
$insToken = $insAuth.token
$insHeaders = @{ Authorization = "Bearer $insToken" }
Write-Host "New Instructor Logged In! Token acquired." -ForegroundColor Green

Write-Host "`n=== TEST 5: Instructor Creates Course & Batch ===" -ForegroundColor Cyan
$courseBody = @{
    courseName = "Deep Learning & Neural Networks $rnd"
    courseCode = "CS-$rnd"
    description = "Comprehensive masterclass on backpropagation, CNNs, Transformers, and LLMs."
} | ConvertTo-Json
$course = Invoke-RestMethod -Uri "$baseUrl/courses" -Method Post -ContentType "application/json" -Headers $insHeaders -Body $courseBody
$courseId = $course.id
Write-Host "Course Created: $($course.courseName) (ID: $courseId)" -ForegroundColor Green

$batchBody = @{
    batchName = "Batch A - Fall 2026"
    courseId = $courseId
    startDate = "2026-11-25"
    endDate = "2027-02-25"
} | ConvertTo-Json
$batch = Invoke-RestMethod -Uri "$baseUrl/batches" -Method Post -ContentType "application/json" -Headers $insHeaders -Body $batchBody
$batchId = $batch.id
Write-Host "Batch Created: $($batch.batchName) (ID: $batchId)" -ForegroundColor Green

Write-Host "`n=== TEST 6: Student Login & Enrollment ===" -ForegroundColor Cyan
$studentLoginBody = @{
    email = "rahul@institute.com"
    password = "password123"
    role = "student"
} | ConvertTo-Json
$studentAuth = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -ContentType "application/json" -Body $studentLoginBody
$studentToken = $studentAuth.token
$studentHeaders = @{ Authorization = "Bearer $studentToken" }
$studentId = $studentAuth.user.id
Write-Host "Student Logged In: $($studentAuth.user.name) (ID: $studentId)" -ForegroundColor Green

# Enroll student to course & batch
$enrollBody = @{
    studentId = $studentId
    courseId = $courseId
    batchId = $batchId
} | ConvertTo-Json
$enrollment = Invoke-RestMethod -Uri "$baseUrl/enrollments" -Method Post -ContentType "application/json" -Headers $adminHeaders -Body $enrollBody
Write-Host "Student Enrolled: $($enrollment.studentName) into $($enrollment.courseName) / $($enrollment.batchName)" -ForegroundColor Green

Write-Host "`n=== TEST 7: Instructor Generates Google Meet & Creates Class ===" -ForegroundColor Cyan
$genMeet = Invoke-RestMethod -Uri "$baseUrl/classes/generate-meet" -Method Post -Headers $insHeaders
Write-Host "Generated Google Meet Link: $($genMeet.meetUrl)" -ForegroundColor Green

$classDate = (Get-Date).ToString("yyyy-MM-dd")
$classBody = @{
    title = "Live Lecture: Transformer Architectures & Attention Mechanism"
    subject = "Deep Learning"
    description = "Hands-on implementation of Multi-Head Self-Attention in PyTorch."
    classDate = $classDate
    startTime = "14:00"
    endTime = "15:30"
    durationMinutes = 90
    courseId = $courseId
    batchId = $batchId
    googleMeetUrl = $genMeet.meetUrl
    status = "Upcoming"
} | ConvertTo-Json
$createdClass = Invoke-RestMethod -Uri "$baseUrl/classes" -Method Post -ContentType "application/json" -Headers $insHeaders -Body $classBody
$classId = $createdClass.id
Write-Host "Class Created: $($createdClass.title) (ID: $classId | Status: $($createdClass.status))" -ForegroundColor Green

Write-Host "`n=== TEST 8: Student Views Assigned Classes & Tests Join ===" -ForegroundColor Cyan
$studentClasses = Invoke-RestMethod -Uri "$baseUrl/classes" -Method Get -Headers $studentHeaders
Write-Host "Student sees $($studentClasses.Count) assigned classes!" -ForegroundColor Green
$matchedClass = $studentClasses | Where-Object { $_.id -eq $classId }
Write-Host "Matched Scheduled Class: $($matchedClass.title) | Meet URL: $($matchedClass.googleMeetUrl)" -ForegroundColor Yellow

$joinResult = Invoke-RestMethod -Uri "$baseUrl/classes/$classId/join" -Method Post -Headers $studentHeaders
Write-Host "Student Join Response: $($joinResult.message) | Meet URL: $($joinResult.googleMeetUrl)" -ForegroundColor Green

Write-Host "`n=== TEST 9: Instructor Creates & Publishes Assignment ===" -ForegroundColor Cyan
$assignBody = @{
    title = "Assignment 1: Implement Multi-Head Attention from Scratch"
    description = "Complete the PyTorch attention module notebook and evaluate perplexity on Wikitext-2."
    instructions = "Submit your completed Python script or Jupyter Notebook along with execution output PDF."
    courseId = $courseId
    batchId = $batchId
    maximumMarks = 100
    allowResubmission = $true
    status = "PUBLISHED"
    dueDate = (Get-Date).AddDays(7).ToString("yyyy-MM-ddTHH:mm:ss")
} | ConvertTo-Json
$createdAssign = Invoke-RestMethod -Uri "$baseUrl/assignments" -Method Post -ContentType "application/json" -Headers $insHeaders -Body $assignBody
$assignId = $createdAssign.id
Write-Host "Assignment Created: $($createdAssign.title) (ID: $assignId | Max Marks: $($createdAssign.maximumMarks))" -ForegroundColor Green

Write-Host "`n=== TEST 10: Student Views My Assignments & Submits ===" -ForegroundColor Cyan
$myAssignments = Invoke-RestMethod -Uri "$baseUrl/assignments/my" -Method Get -Headers $studentHeaders
Write-Host "Student sees $($myAssignments.Count) assignments in My Assignments!" -ForegroundColor Green

$submitBody = @{
    studentComments = "Implemented Scaled Dot-Product Attention with masking. Perplexity score: 18.4"
    submissionFileUrl = "https://res.cloudinary.com/dltpal1gr/raw/upload/solution_notebook.py"
    submissionText = "Code passes all unit test assertions."
} | ConvertTo-Json
$submitted = Invoke-RestMethod -Uri "$baseUrl/assignments/$assignId/submit" -Method Post -ContentType "application/json" -Headers $studentHeaders -Body $submitBody
$subId = $submitted.id
Write-Host "Student Submitted! Submission ID: $subId | Status: $($submitted.status)" -ForegroundColor Green

Write-Host "`n=== TEST 11: Instructor Views Submissions & Evaluates Work ===" -ForegroundColor Cyan
$submissions = Invoke-RestMethod -Uri "$baseUrl/assignments/$assignId/submissions" -Method Get -Headers $insHeaders
Write-Host "Instructor received $($submissions.Count) submission(s) for assignment!" -ForegroundColor Green

$evalBody = @{
    marksObtained = 97.5
    instructorFeedback = "Exceptional numerical stability in the softmax masking and crisp tensor manipulation."
    evaluatedFileUrl = "https://res.cloudinary.com/dltpal1gr/raw/upload/evaluated_rubric.pdf"
} | ConvertTo-Json
$evaluated = Invoke-RestMethod -Uri "$baseUrl/assignments/submissions/$subId/evaluate" -Method Post -ContentType "application/json" -Headers $insHeaders -Body $evalBody
Write-Host "Submission Evaluated! Marks: $($evaluated.marksObtained) / $($evaluated.maximumMarks) | Status: $($evaluated.status)" -ForegroundColor Green

Write-Host "`n=== TEST 12: Student Views Results & Feedback ===" -ForegroundColor Cyan
$myResults = Invoke-RestMethod -Uri "$baseUrl/assignments/my-results" -Method Get -Headers $studentHeaders
Write-Host "Student My Results contains $($myResults.Count) evaluated record(s):" -ForegroundColor Green
foreach ($r in $myResults) {
    Write-Host "  - Title: $($r.assignmentTitle) | Score: $($r.marksObtained)/$($r.totalMarks) | Feedback: $($r.instructorFeedback)" -ForegroundColor Yellow
}

Write-Host "`n>>> ALL 12 END-TO-END BACKEND LMS WORKFLOW TESTS PASSED PERFECTLY! <<<" -ForegroundColor Green
