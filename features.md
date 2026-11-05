# 🎓 EduChain — Comprehensive Features Documentation

EduChain is a modern, full-stack Learning Management & Academic Administration System (LMS) built with a **Spring Boot** backend and a **Flutter multi-platform** frontend supporting Web, Windows, Android, iOS, macOS, and Linux.

---

## 📑 Table of Contents
1. [Role-Based Access & Authentication](#1-role-based-access--authentication)
2. [Institute & Administrator Portal](#2-institute--administrator-portal)
3. [Teacher / Faculty Portal](#3-teacher--faculty-portal)
4. [Student Portal & Examination Engine](#4-student-portal--examination-engine)
5. [Cloud Storage & File Management](#5-cloud-storage--file-management)
6. [Backend Architecture & API Services](#6-backend-architecture--api-services)
7. [Multi-Platform Flutter Frontend](#7-multi-platform-flutter-frontend)
8. [DevOps, Docker & CI/CD Automation](#8-devops-docker--cicd-automation)

---

## 1. 🔐 Role-Based Access & Authentication

EduChain provides secure, role-segregated entry points and authentication workflows:

- **Institute Registration & Login**:
  - Direct institute onboarding with institute name, code, contact details, and administrative credentials.
  - Dedicated Institute Home screen and institutional dashboard.
- **Admin Authentication**:
  - Secure portal login with administrative permissions.
- **Teacher / Faculty Authentication**:
  - Specialized registration and login supporting departmental credentials and instructor IDs.
- **Student Authentication**:
  - Self-service student registration and sign-in linked to roll numbers, classes, and departments.
- **Universal Role Gateway (`SelectRoleScreen`)**:
  - Interactive portal selector allowing users to quickly navigate to their respective login/registration screen.
- **Forgot Password Workflow**:
  - Dedicated password reset request flow across user roles (`/api/auth/forgot-password`).
- **Session Persistence**:
  - Token-based persistent sessions using `SharedPreferences` in Flutter and secure JWT authentication.

---

## 2. 🏛️ Institute & Administrator Portal

Designed for academic directors, campus administrators, and registrars to coordinate institutional operations:

- **Centralized Admin Dashboard**:
  - Live metric cards: Total Students, Total Instructors, Enrolled Institutes, Active Classes, System Attendance Rate.
  - System health indicator and recent user registration feeds.
- **Student Records Management**:
  - View searchable, sortable list of all enrolled students.
  - Add new student records directly with roll number, class, semester, and contact information.
  - Student detail inspection cards.
- **Instructor / Faculty Records**:
  - Faculty directory with real-time search across name, email, department, and instructor ID.
  - Add new faculty profiles with designation and contact details.
  - Faculty tracking and departmental assignment views.
- **Academic Planning & Class Management**:
  - Semester curriculum coordination, course allocations, and section definitions.
- **Lecture Scheduling**:
  - Master timetable planning with lecture times, assigned classrooms/halls, and instructor allocations.
- **Examination Management**:
  - Create and publish examination timetables (date, time window, hall/room allocation, exam code, invigilator).
- **Cross-Module Analytics & Reports**:
  - High-level institutional reporting, attendance rates, and platform configuration settings.

---

## 3. 👨‍🏫 Teacher / Faculty Portal

Equips educators with essential tools to manage teaching schedules, curriculum, and students:

- **Faculty Dashboard**:
  - Overview of assigned courses, total enrolled students, upcoming lectures, pending evaluations, and class ratings.
- **Course Administration**:
  - View assigned active courses with student enrollment counts.
  - Add new course offerings and curriculum modules.
  - Course details management and archiving/removal.
- **Class & Student Rostering**:
  - Access class-specific student lists.
  - View individual student performance and academic history.
  - Direct student creation/enrollment into instructor-led classes.
- **Lecture Management**:
  - View upcoming and conducted lecture schedules.
  - Update lecture metadata (topic, classroom, date, time slot, syllabus coverage).
- **Grading & Academic Feedback**:
  - Review student submissions, monitor exam marks, and track attendance trends.
- **Faculty Profile Management**:
  - Update teacher bio, designations, departmental affiliations, and contact information.

---

## 4. 🎒 Student Portal & Examination Engine

A student-centric learning environment with comprehensive academic tracking and interactive testing:

- **Personalized Student Dashboard**:
  - Real-time attendance percentage indicator.
  - Enrolled subjects and today's upcoming lectures schedule.
  - Announcements, academic notices, and quick-access navigation.
- **Timetable & Daily Schedule**:
  - Weekly lecture calendar displaying subject titles, timings, room numbers, and faculty names.
- **Course Learning Materials**:
  - Centralized repository to view and download study guides, lecture slides, and notes uploaded by teachers.
- **Interactive Examination Engine**:
  - **Exams Hub**: View upcoming, active, and completed examinations.
  - **Pre-Exam Instructions**: Strict assessment rules, time limit guidelines, and honor code review.
  - **Live Exam Environment**: Interactive computer-based testing interface with countdown timer and question navigator.
  - **Exam Submission**: Automatic/manual submission confirmation screen.
  - **Results & Scorecards**: Instant grade calculation, subject breakdowns, and downloadable performance reports.
- **Attendance & Grades Viewer**:
  - Subject-by-subject attendance percentages with alert thresholds.
  - Semester GPA/grading records.
- **Parent & Emergency Contact Info**:
  - Linked parental and emergency contact details for administrative safety.
- **Student Profile**:
  - Manage personal details, verify roll number, course, and semester enrollment.

---

## 5. ☁️ Cloud Storage & File Management

Production-grade media and file upload infrastructure:

- **Dual-Cloud Architecture**:
  - Primary storage provider: **Cloudinary Media Cloud** for optimized document, image, and asset delivery.
  - Failover / secondary storage: **Amazon AWS S3** storage service integration.
- **File Upload API (`/api/files/upload`)**:
  - Multipart file upload supporting folders, categorizations, and uploader attribution.
  - Returns persistent secure URLs, MIME types, and file keys.
- **Stored File Database Registry**:
  - `StoredFileEntity` persists metadata (file name, file key, URL, MIME type, size, upload timestamp, uploader) in PostgreSQL.

---

## 6. ⚙️ Backend Architecture & API Services

Robust, high-throughput microservice backend built with **Spring Boot 3+** and **Java 21**:

- **Database Layer**:
  - PostgreSQL / Neon Serverless Postgres integration.
  - Custom `NeonSocketFactory` for secure cloud database connections.
  - JPA / Hibernate ORM with schema management.
- **RESTful API Controllers**:
  - `AuthController`: Role-based authentication, logins, registrations, and password recovery.
  - `DashboardController`: Aggregate metrics for Admin and Instructor portals.
  - `StudentController`: CRUD operations, search filters, and profile queries.
  - `InstructorController`: Faculty CRUD operations and search indexing.
  - `FileController`: Multi-cloud file handling.
  - `DatabaseController` & `TestConnection`: Database connectivity monitoring.
- **Interactive API Documentation**:
  - **Swagger UI**: Interactive API exploration at `http://localhost:5000/api/swagger-ui.html`.
  - **OpenAPI 3 Docs**: Raw JSON specification at `http://localhost:5000/api/v3/api-docs`.
- **CORS & Security**:
  - Cross-Origin Resource Sharing (CORS) configured for multi-device clients.
  - Environment variable configuration via `.env` and `System.getenv()`.

---

## 7. 📱 Multi-Platform Flutter Frontend

A single Dart/Flutter codebase engineered for seamless cross-platform performance:

- **6 Supported Operating Systems & Platforms**:
  1. 🌐 **Web**: HTML5, CanvasKit, WASM responsive web application.
  2. 🪟 **Windows Desktop**: Native Win32 standalone binary and Inno Setup installer.
  3. 🤖 **Android**: Native APK and Google Play App Bundle (AAB).
  4. 🍎 **iOS**: Optimized iPhone & iPad release bundle (IPA).
  5. 🖥️ **macOS**: Native desktop `.app` bundle.
  6. 🐧 **Linux**: Native desktop ELF binary and `.deb` distribution package.
- **Design & User Experience**:
  - Cohesive design system (`AppColors`, `AppTheme`) with modern typography, card elevations, and color-coded status badges.
  - Responsive layout adapters (`isDesktop`, `isTablet`, `isMobile`) with collapsible drawers and sidebar navigations.
  - Custom SVG/vector illustrations and metric counters.
- **State Architecture**:
  - Scalable Provider pattern: `AuthProvider`, `StudentProvider`, `InstructorProvider`, `NavigationProvider`.
  - Centralized API service layer (`ApiService`) with graceful offline/error handling.

---

## 8. 🚀 DevOps, Docker & CI/CD Automation

Automated delivery pipelines ensuring zero-downtime deployment and multi-platform packaging:

- **GitHub Actions Frontend Workflow (`frontend-build.yml`)**:
  - Linting & static analysis with `flutter analyze` and widget tests with `flutter test`.
  - Parallel matrix builds across `ubuntu-latest`, `macos-latest`, and `windows-latest`.
  - Automated Windows Inno Setup installer packaging (`EduChain-Setup-*.exe`).
  - Automated semantic version generation and unified GitHub Releases with attached platform bundles.
- **GitHub Actions Backend Workflow (`backend-deploy.yml`)**:
  - Maven automated test verification and JAR compilation.
  - Render deployment webhook integration with secret sanitation.
  - Post-deployment automated health check probe verification.
- **Docker Containerization**:
  - Multi-stage root `Dockerfile` using Eclipse Temurin JDK 21 Alpine for lightweight, secure production deployment.
  - Configured with `.dockerignore` for minimal image footprints.

