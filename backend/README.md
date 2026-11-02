# Enterprise Management System - Spring Boot Backend & PostgreSQL Database

This backend powers the Management System frontend, replacing static demo records with full Spring Boot 3.3.4 REST APIs connected to a relational PostgreSQL database.

---

## 1. PostgreSQL Database Credentials

| Parameter | Default Value | Environment Variable |
|---|---|---|
| **Host** | `localhost` / `127.0.0.1` | `DB_HOST` |
| **Port** | `5433` | `DB_PORT` |
| **Database Name** | `lms_db` | `DB_NAME` |
| **Username** | `postgres` | `DB_USERNAME` |
| **Password** | `tiger` | `DB_PASSWORD` |
| **JDBC Connection URL** | `jdbc:postgresql://localhost:5433/lms_db` | `SPRING_DATASOURCE_URL` |
| **Data Directory** | `C:\Users\NTCI\pgdata_lms` | - |

> **Note:** If your PostgreSQL setup requires a password, set `DB_PASSWORD=your_password` in your terminal or in `application.yml`.

---

## 2. Default Seed Logins (All User Roles)

All accounts are pre-seeded in PostgreSQL via Flyway (`V2__seed_initial_data.sql`):

| Role | Email | Password | Identifier / Code |
|---|---|---|---|
| **Institute Portal** | `inst.admin@apex.edu` | `Password123!` | Code: `INST-2025` |
| **System Admin** | `amit.kumar@institute.com` | `Password123!` | Admin ID: `ADM-001` |
| **Teacher / Instructor** | `amit.sharma@institute.com` | `Password123!` | Instructor ID: `INS-001` |
| **Student** | `rahul@institute.com` | `Password123!` | Roll #: `1023` / `BCA-301` |

---

## 3. How to Run the Application

### A. Start the PostgreSQL Server (if not running)
```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_ctl.exe" -D "C:\Users\NTCI\pgdata_lms" start
```

### B. Run the Spring Boot Backend (Port 5000)
```powershell
cd "c:\Users\NTCI\Downloads\Management-System1-main (1)\Management-System1-main\backend"
mvn spring-boot:run
```
Once started, the backend is available at `http://localhost:5000/api`.

### C. Run the React Frontend (Port 5173)
```powershell
cd "c:\Users\NTCI\Downloads\Management-System1-main (1)\Management-System1-main\frontend"
npm run dev
```
Open `http://localhost:5173` in your browser.

---

## 4. Swagger / OpenAPI 3.0 Documentation

Interactive API documentation with JWT Bearer token authorization:
- **Swagger UI**: [http://localhost:5000/api/swagger-ui.html](http://localhost:5000/api/swagger-ui.html)
- **OpenAPI JSON Spec**: [http://localhost:5000/api/v3/api-docs](http://localhost:5000/api/v3/api-docs)

---

## 5. Implemented REST API Endpoints

### Authentication (`/api/auth`)
- `POST /api/auth/login` - Role-based login (Admin, Teacher, Student)
- `POST /api/auth/institute/login` - Dedicated Institute login with instituteCode
- `POST /api/auth/register/institute` - Register new Institute & Admin
- `POST /api/auth/register/student` - Register new Student
- `POST /api/auth/register/teacher` - Register new Teacher
- `POST /api/auth/forgot-password` - Password recovery flow
- `GET /api/auth/me` - Authenticated user profile

### Students (`/api/students`)
- `GET /api/students` - List all students
- `GET /api/students/{id}` - Get student by ID
- `GET /api/students/me` - Current student profile
- `POST /api/students` - Create student record
- `PUT /api/students/{id}` - Update student record
- `DELETE /api/students/{id}` - Delete student
- `POST /api/students/{id}/leave` - Submit leave application
- `GET /api/students/{id}/leave` - Get leave history
- `POST /api/students/{id}/ptm` - Request Parent-Teacher meeting

### Teachers (`/api/teachers`)
- `GET /api/teachers` - List all instructors
- `GET /api/teachers/{id}` - Get teacher by ID
- `GET /api/teachers/me` - Current teacher profile
- `POST /api/teachers` - Create teacher record
- `PUT /api/teachers/{id}` - Update teacher record
- `DELETE /api/teachers/{id}` - Remove teacher

### Classes (`/api/classes`)
- `GET /api/classes` - List all classes
- `GET /api/classes/{id}` - Get class by ID
- `POST /api/classes` - Create class
- `PUT /api/classes/{id}` - Update class
- `DELETE /api/classes/{id}` - Delete class

### Courses (`/api/courses`)
- `GET /api/courses` - List all courses
- `GET /api/courses/{id}` - Get course details
- `POST /api/courses` - Create course
- `PUT /api/courses/{id}` - Update course
- `DELETE /api/courses/{id}` - Delete course
- `POST /api/courses/bulk-delete` - Remove multiple courses

### Lectures & Timetables (`/api/lectures`)
- `GET /api/lectures` - Weekly lecture timetable slots
- `GET /api/lectures/{id}` - Slot details
- `POST /api/lectures` - Schedule lecture slot
- `PUT /api/lectures/{id}` - Update schedule slot
- `DELETE /api/lectures/{id}` - Delete slot

### Attendance (`/api/attendance`)
- `GET /api/attendance/student/{studentId}` - Student attendance history
- `POST /api/attendance` - Record individual student attendance
- `POST /api/attendance/quick-roster` - Save batch class roster attendance

### Examinations (`/api/examinations`)
- `GET /api/examinations` - List all exams
- `GET /api/examinations/{id}` - Get exam details & questions
- `POST /api/examinations` - Schedule exam
- `PUT /api/examinations/{id}` - Update exam details
- `PATCH /api/examinations/{id}/toggle-status` - Toggle Published / Draft status
- `DELETE /api/examinations/{id}` - Remove exam
- `POST /api/examinations/{id}/submit` - Submit live exam answers and calculate score
- `GET /api/examinations/{id}/results/{studentId}` - Get exam results breakdown

### Grades (`/api/grades`)
- `GET /api/grades/student/{studentId}` - Get student marks and scorecards
- `POST /api/grades` - Record grade and update CGPA

### Lecture Materials (`/api/materials`)
- `GET /api/materials` - List study materials and notes
- `POST /api/materials` - Upload new study material
- `DELETE /api/materials/{id}` - Delete material

### Announcements & Notifications (`/api/notifications`)
- `GET /api/notifications/announcements` - List broadcast announcements
- `POST /api/notifications/announcements` - Publish announcement
- `GET /api/notifications/student` - Get student notifications
- `PATCH /api/notifications/student/mark-read` - Mark all notifications as read

### Dynamic Dashboards (`/api/dashboard`)
- `GET /api/dashboard/admin` - Admin overview statistics
- `GET /api/dashboard/teacher` - Teacher courses, students, and today's schedule
- `GET /api/dashboard/student` - Student GPA, attendance %, exams, and recent grades
- `GET /api/dashboard/institute` - Institute verification and department counts

### Admin System Settings (`/api/admin/settings`)
- `GET /api/admin/settings` - Administrator system preferences
- `PUT /api/admin/settings` - Update alerts, dark mode, default semester
- `POST /api/admin/settings/change-password` - Secure BCrypt password change
