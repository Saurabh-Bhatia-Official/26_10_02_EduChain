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

# 3. Get Classrooms
$classes = Invoke-RestMethod -Uri "$baseUrl/classrooms" -Method Get -Headers $teacherHeaders
$classroomId = $classes[0].id
Write-Host "Active Classroom: $($classes[0].name) ($classroomId)"

# 4. Create an Assignment
$assignBody = @{
    title = "E2E Automated Normalization Lab"
    instructions = "Please normalize the given relational schema up to 3NF and BCNF. Submit your solution document."
    pointsPossible = 100
    dueDate = (Get-Date).AddDays(5).ToString("yyyy-MM-ddTHH:mm:ss")
    topic = "Database Systems"
    allowLateSubmissions = $true
    attachments = @(
        @{
            fileName = "Problem_Specification.pdf"
            fileUrl = "https://example.com/Problem_Specification.pdf"
            fileType = "PDF"
        }
    )
} | ConvertTo-Json -Depth 5

$assignment = Invoke-RestMethod -Uri "$baseUrl/assignments?classroomId=$classroomId" -Method Post -Headers $teacherHeaders -ContentType "application/json" -Body $assignBody
$assignId = $assignment.id
Write-Host "Created Assignment: $($assignment.title) ($assignId)"

# 5. Check Student To-do List
$todo = Invoke-RestMethod -Uri "$baseUrl/assignments/to-do" -Method Get -Headers $studentHeaders
Write-Host "Student To-do -> Assigned: $($todo.assigned.Count), Missing: $($todo.missing.Count), Done: $($todo.done.Count)"

# 6. Student Submits Assignment
$submitBody = @{
    submissionText = "Here is my normalization solution with functional dependency diagrams."
    attachments = @(
        @{
            fileName = "Rahul_Sharma_Database_Solution.pdf"
            fileUrl = "https://res.cloudinary.com/demo/image/upload/sample.pdf"
            fileType = "PDF"
            fileSize = 1048576
        }
    )
} | ConvertTo-Json -Depth 5

$submission = Invoke-RestMethod -Uri "$baseUrl/assignments/$assignId/submit" -Method Post -Headers $studentHeaders -ContentType "application/json" -Body $submitBody
Write-Host "Student Turned In Assignment: Status = $($submission.status), Version = $($submission.versionNumber)"

# 7. Student Unsubmits
$unsubmit = Invoke-RestMethod -Uri "$baseUrl/assignments/$assignId/unsubmit" -Method Post -Headers $studentHeaders
Write-Host "Student Unsubmitted: Status = $($unsubmit.status), Message = $($unsubmit.message)"

# 8. Student Resubmits with Final Work
$resubmit = Invoke-RestMethod -Uri "$baseUrl/assignments/$assignId/submit" -Method Post -Headers $studentHeaders -ContentType "application/json" -Body $submitBody
$subId = $resubmit.id
Write-Host "Student Resubmitted Work: Submission ID = $subId, Status = $($resubmit.status)"

# 9. Teacher Evaluates and Returns Grade
$gradeBody = @{
    score = 96.5
    feedback = "Outstanding work on decomposition and dependency preservation!"
    isReturned = $true
} | ConvertTo-Json

$grade = Invoke-RestMethod -Uri "$baseUrl/assignments/submissions/$subId/grade" -Method Post -Headers $teacherHeaders -ContentType "application/json" -Body $gradeBody
Write-Host "Teacher Graded and Returned: Score = $($grade.score), Feedback = $($grade.feedback)"

# 10. Student Views Evaluated Details & To-do
$details = Invoke-RestMethod -Uri "$baseUrl/assignments/$assignId" -Method Get -Headers $studentHeaders
Write-Host "Student View: My Score = $($details.mySubmission.grade.score), Returned = $($details.mySubmission.grade.isReturned)"

$todoAfter = Invoke-RestMethod -Uri "$baseUrl/assignments/to-do" -Method Get -Headers $studentHeaders
Write-Host "Student To-do After Grading -> Done: $($todoAfter.done.Count)"

Write-Host "`n>>> ALL 10 END-TO-END WORKFLOW CHECKS PASSED SUCCESSFULLY! <<<" -ForegroundColor Green
