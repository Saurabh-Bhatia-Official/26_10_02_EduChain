# EduChain Spring Boot Backend

The backend uses PostgreSQL for application data and Cloudinary for uploaded media. It defaults to a local PostgreSQL database for development and accepts production database settings from environment variables.

## Configure PostgreSQL and Cloudinary

For local development, create a PostgreSQL database named `edlearndb` and the existing `edlearn` schema, then run the backend without setting deployment variables. The defaults are `jdbc:postgresql://localhost:5432/edlearndb`, username `postgres`, and an empty password. If your local server requires a password or uses a different database/user, set `DATABASE_URL`, `DATABASE_USERNAME`, and `DATABASE_PASSWORD` in `backend/.env` or the process environment. Never commit populated `.env` files.

If needed, create the database once and ensure the schema exists:

```powershell
createdb -U postgres edlearndb
psql -U postgres -d edlearndb -c "CREATE SCHEMA IF NOT EXISTS edlearn;"
```

Skip `createdb` if the database already exists. The schema command is non-destructive.

Production can use `DATABASE_URL` / `DATABASE_USERNAME` / `DATABASE_PASSWORD`, `SPRING_DATASOURCE_URL` / `SPRING_DATASOURCE_USERNAME` / `SPRING_DATASOURCE_PASSWORD`, or the legacy `DB_USERNAME` / `DB_PASSWORD` aliases. Use a JDBC URL such as `jdbc:postgresql://db-host:5432/database`; remote database URLs are configured to require SSL and use the `edlearn` schema. Localhost URLs do not have SSL or a custom socket factory forced on them. The PostgreSQL driver is included in `pom.xml`.

Cloudinary is optional for local startup. Configure `CLOUDINARY_URL` or `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, and `CLOUDINARY_API_SECRET` to enable file uploads.

At startup Hibernate applies the existing `ddl-auto=update` schema updates to the configured PostgreSQL database. This creates/updates tables; it does not copy data from an older local database or transfer existing S3 objects to Cloudinary. New uploads use Cloudinary only. Back up existing data and transfer old media separately before deleting their source accounts.

Integration tests use `TEST_DATABASE_URL`, `TEST_DATABASE_USERNAME`, and `TEST_DATABASE_PASSWORD` for a dedicated disposable PostgreSQL database. They create and drop mapped tables in the `edlearn` schema, so never point these variables at production.

## Run the application

```powershell
Set-Location backend
mvn spring-boot:run
```

The backend listens on port `5002` by default (or the configured `PORT` / `SERVER_PORT`). The Flutter frontend is in `../frontend`.
To run the frontend locally, use `Set-Location ..\frontend; flutter run -d web-server --web-port 8080`. The backend landing page links to this URL by default; set `EDLEARN_FRONTEND_URL` to the deployed frontend URL outside local development.

---

## 4. Swagger / OpenAPI 3.0 Documentation

Interactive API documentation with JWT Bearer token authorization:
- **Swagger UI**: [http://localhost:5002/api/swagger-ui.html](http://localhost:5002/api/swagger-ui.html)
- **OpenAPI JSON Spec**: [http://localhost:5002/api/v3/api-docs](http://localhost:5002/api/v3/api-docs)

---

## 5. Implemented REST API Endpoints

### Portal announcements, leave management, and notifications (`/api/portal`)
All endpoints below require the signed Bearer token returned by Admin, Teacher, or Student login. Tokens expire after 12 hours. Configure `EDLEARN_AUTH_SECRET` (or the existing `JWT_SECRET`) to the same strong secret of at least 32 bytes on every backend replica; when omitted, a random process-local signing key is generated, so sessions expire on restart and do not work across replicas.

- `GET /api/portal/announcements` - List announcements for the current role; Admins see institute announcements including drafts
- `POST /api/portal/announcements` - Create an Admin announcement
- `PUT /api/portal/announcements/{id}` - Edit or publish/unpublish an announcement
- `DELETE /api/portal/announcements/{id}` - Delete an Admin announcement
- `POST /api/portal/announcements/{id}/read` - Mark an announcement as read
- `GET /api/portal/leaves` - List the caller's applications and role-appropriate review queue; supports `status`, `applicantRole`, `from`, `to`, and `search`
- `POST /api/portal/leaves` - Submit a Student or Teacher leave application
- `POST /api/portal/leaves/{id}/decision` - Teacher review of assigned Student requests or Admin review of Teacher requests and second-stage Student requests
- `POST /api/portal/leave-attachments` - Upload an optional PDF/JPEG/PNG attachment (maximum 10 MB)
- `GET /api/portal/notifications` and `GET /api/portal/notifications/unread-count` - List user-specific notifications and unread count
- `POST /api/portal/notifications/{id}/read` - Mark a notification as read
- `GET /api/portal/admin/assignment-options` - List same-institute Students and Teachers, including current assignments
- `PUT /api/portal/admin/students/{studentId}/teacher` - Assign a Student's Teacher

Portal entities are created/updated by the existing Hibernate `ddl-auto=update` schema management. Student leave requests require an Admin-managed Teacher assignment. Student requests require Teacher approval first; the additional Admin approval stage is controlled by `EDLEARN_LEAVE_SECOND_APPROVAL` (default `true`).

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
