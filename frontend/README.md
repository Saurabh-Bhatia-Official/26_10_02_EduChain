# 🎓 Institute Portal - Flutter Multiplatform Frontend (`frontend`)

A production-ready Flutter frontend replicating the full functionality, UI/UX design, workflows, and Spring Boot backend API integrations of the React.js frontend.

---

## 📱 Features & Page Mapping (100% React Parity)

| Page / Screen | React Route | Flutter Screen | Key Features |
| :--- | :--- | :--- | :--- |
| **Public Home** | `home` | `HomeScreen` | Hero section, Our Features cards, Why Choose pills, About Us benefits, Onboarding CTA, Contact section, dynamic Navbar & Footer. |
| **Institute Home** | `institute-home` | `InstituteHomeScreen` | Top institute bar with verified badge, accreditation info, 1-click Institute Code copy pill, campus announcement broadcaster, quick stats, role gateway button. |
| **Institute Login** | `institute-login` | `InstituteLoginScreen` | Split layout with campus showcase, Institute Code, Admin Email, Password, Demo Auto-fill (`INST-2025`), direct backend auth (`/auth/institute/login`). |
| **Institute Registration** | `institute-register` | `InstituteRegistrationScreen` | Institution classification, email, phone, address, Dean/Admin account setup, password strength meters, instant Institute Code generation dialog. |
| **Select Role Gateway** | `select-role` | `SelectRoleScreen` | Campus banner with avatar, metric strip, ticker, mode toggle between **Login as Role** (Admin, Teacher, Student) and **Register New User** (Student, Teacher). |
| **Student Login** | `student-login` | `StudentLoginScreen` | Purple-themed split card with student illustration, email/password fields, Demo Fill, role switcher pills, direct auth (`/auth/login`). |
| **Teacher Login** | `teacher-login` | `TeacherLoginScreen` | Teal-themed split card with teacher illustration, email/password fields, Demo Fill, role switcher, direct auth (`/auth/login`). |
| **Admin Login** | `admin-login` | `AdminLoginScreen` | Indigo-themed split card with admin badge, email/password fields, Demo Fill, direct auth (`/auth/admin/login`). |
| **Student Registration** | `student-register` | `StudentRegistrationScreen` | Full Name, Email, Institute Code, Roll Number, Course dropdown, Password, direct backend enrollment (`/auth/register/student`). |
| **Teacher Registration** | `teacher-register` | `TeacherRegistrationScreen` | Full Name, Email, Institute Code, Employee ID, Department dropdown, Phone, Password, direct backend registration (`/auth/register/teacher`). |
| **Forgot Password** | `forgot-password` | `ForgotPasswordScreen` | Role selector tabs (Student, Teacher, Admin, Institute), Email input, backend reset link trigger (`/auth/forgot-password`). |
| **Student Portal** (13 Modules) | `student-dashboard`, `student-*` | `StudentPortalScreen` | Sidebar navigation, mini profile, Attendance tracker, Marksheets & GPA, Class schedule, Downloadable materials, Timetable grid, Parent portal, Online Exam hall with live countdown, question palette & scoring. |
| **Teacher Portal** (12 Modules) | `teacher-dashboard`, `teacher-*` | `TeacherPortalScreen` | Class rosters, Student records with live backend CRUD (`/api/students`), Enroll student, Student detail, Courses manager, Add/remove courses, Lecture timetable, Faculty profile. |
| **Admin Portal** (15 Modules) | `admin-dashboard`, `admin-*` | `AdminPortalScreen` | Live stats from `/api/dashboard/admin`, Student directory CRUD, Faculty directory CRUD (`/api/instructors`), Faculty workload tracking, Class management, Academic planning, Master exam timetable, Global explorer, Analytics CSV reports, Settings. |
| **Students CRUD** | `students` | `StudentsCrudScreen` | Dedicated testing page replicating `students.jsx` with real-time add, edit, delete, and search operations. |

---

## 🛠️ Architecture

```
frontend/
├── lib/
│   ├── config/
│   │   └── api_config.dart          # Base URL, timeouts, offline fallback toggle
│   ├── constants/
│   │   ├── app_colors.dart          # Theme color palette matching React CSS
│   │   └── app_theme.dart           # Plus Jakarta Sans typography, input/button styles
│   ├── models/
│   │   ├── user_model.dart          # User & Institute authentication model
│   │   ├── student_model.dart       # Student entity serialization
│   │   ├── instructor_model.dart    # Instructor entity serialization
│   │   ├── course_model.dart        # Academic course model
│   │   ├── lecture_model.dart       # Lecture schedule model
│   │   ├── exam_model.dart          # Assessment model
│   │   └── dashboard_stats_model.dart # Admin & Instructor statistics
│   ├── services/
│   │   ├── api_service.dart         # Reusable HTTP client + offline fallback
│   │   └── storage_service.dart     # SharedPreferences session persistence
│   ├── providers/
│   │   ├── auth_provider.dart       # Current user, login, register, logout
│   │   ├── navigation_provider.dart # Router, page parameters, portal tabs
│   │   ├── student_provider.dart    # Reactive student CRUD operations
│   │   └── instructor_provider.dart # Reactive instructor CRUD operations
│   ├── widgets/
│   │   ├── navbar.dart              # Responsive header navigation
│   │   ├── footer.dart              # Responsive footer with sitemap
│   │   ├── portal_header.dart       # Auth header with back & logout
│   │   ├── illustrations.dart       # Institute, student, and teacher visuals
│   │   ├── status_badge.dart        # Active, pending, verified badges
│   │   └── metric_card.dart         # KPI metrics cards
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── institute_home_screen.dart
│   │   ├── auth/
│   │   │   ├── institute_login_screen.dart
│   │   │   ├── institute_registration_screen.dart
│   │   │   ├── select_role_screen.dart
│   │   │   ├── student_login_screen.dart
│   │   │   ├── teacher_login_screen.dart
│   │   │   ├── admin_login_screen.dart
│   │   │   ├── student_registration_screen.dart
│   │   │   ├── teacher_registration_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── student/
│   │   │   └── student_portal_screen.dart
│   │   ├── teacher/
│   │   │   └── teacher_portal_screen.dart
│   │   ├── admin/
│   │   │   └── admin_portal_screen.dart
│   │   └── crud/
│   │       └── students_crud_screen.dart
│   └── main.dart                    # App bootstrap & MultiProvider
└── test/
    ├── models_test.dart             # JSON serialization tests
    ├── navigation_provider_test.dart# Routing resolution tests
    └── widget_test.dart             # Smoke test
```

---

## 🚀 Running the Flutter Frontend

### 1. Fetch Dependencies
```bash
cd frontend
flutter pub get
```

### 2. Run on Chrome Web Browser (Hot Reload Supported)
```bash
flutter run -d chrome
```

### 3. Run on Windows Desktop
```bash
flutter run -d windows
```

### 4. Run on Mobile (Android / iOS)
```bash
# Android Device / Emulator
flutter run -d android

# iOS Simulator (macOS host)
flutter run -d ios
```

---

## 🧪 Testing & Code Quality

```bash
cd frontend

# Run Dart code analysis (0 errors, 0 warnings)
flutter analyze

# Run Automated unit & widget tests
flutter test
```

---

## 🔗 Backend Connectivity

The Flutter application connects to the Spring Boot backend REST API at:
* Base URL: `http://localhost:5000/api` (or `http://10.0.2.2:5000/api` on Android emulator)
* Supports full CRUD mutations (`GET`, `POST`, `PUT`, `DELETE`).
* When running without the backend server active, the app automatically activates the exact same offline fallback data as React's `api.js`, guaranteeing 100% of all UI screens, forms, tabs, and user workflows can be fully demonstrated.
