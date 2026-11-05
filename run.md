# 🚀 EduChain — Run & Execution Commands

**One Platform, Endless Possibilities**

Quick reference commands to setup, run, and build both the Spring Boot backend and the Flutter multiplatform frontend.

---

## 📋 Prerequisites
- **Java**: JDK 21+ (`java -version`)
- **Maven**: 3.8+ (`mvn -v`)
- **Node.js**: v18+ (`node -v`)
- **npm**: v9+ (`npm -v`)

---

## 1️⃣ Quick Start (Two Terminals)

### Terminal 1: Spring Boot Backend
```bash
# Navigate to backend directory
cd backend

# 1. Copy environment template to .env (if not already done)
copy .env.example .env        # Windows CMD / PowerShell
# cp .env.example .env        # Linux / macOS

# 2. (Optional) Activate / Export .env into your terminal session:
# Windows PowerShell:
Get-Content .env | Where-Object { $_ -match '=' -and -not $_.StartsWith('#') } | ForEach-Object { $k,$v = $_.Split('=',2); [System.Environment]::SetEnvironmentVariable($k.Trim(),$v.Trim(),'Process') }
# Windows CMD:
for /f "tokens=*" %i in (.env) do set %i
# Linux / macOS:
export $(grep -v '^#' .env | xargs)

# 3. Run Spring Boot application
# (The backend also automatically detects and activates .env on launch!)
mvn clean spring-boot:run
```
* **Backend API Base:** `http://localhost:5000/api`
* **Swagger UI Docs:** `http://localhost:5000/api/swagger-ui.html`
* **OpenAPI Specification:** `http://localhost:5000/api/v3/api-docs`

---

### Terminal 2: Flutter Multiplatform Frontend (`frontend`)
*(Supports Web, Windows Desktop, Android, iOS, macOS, and Linux from single codebase)*

```bash
# Navigate to frontend directory
cd frontend

# 1. Fetch dependencies (already configured in pubspec.yaml)
flutter pub get

# 2. Run on Chrome Web Browser (Hot Reload supported):
flutter run -d chrome

# 3. Run on Windows Desktop:
flutter run -d windows

# 4. Run on Connected Android Device or Emulator:
flutter run -d android

# 5. Run on Connected iOS Device or Simulator (macOS host):
flutter run -d ios

# 6. Run on Linux / macOS Desktop:
flutter run -d linux
flutter run -d macos
```
* **Backend API Base:** `http://localhost:5000/api` (Configured in `lib/constants/api_constants.dart`)
* **State Management:** Provider (`AuthProvider`) with SharedPreferences persistent session storage

---

## 2️⃣ Production Build Commands

### Backend Production JAR
```bash
cd backend
mvn clean package -DskipTests
```
* Output JAR: `backend/target/management-backend-1.0.0.jar`
* Run JAR directly (automatically activates `.env`):
  ```bash
  java -jar target/management-backend-1.0.0.jar
  ```

### Flutter Frontend Production Builds
```bash
cd frontend

# Build Web release bundle
flutter build web --release

# Build Windows Desktop release installer / executable
flutter build windows --release

# Build Android release APK / App Bundle
flutter build apk --release
flutter build appbundle --release

# Build iOS release bundle (macOS host)
flutter build ipa --release
```
* Web Output: `frontend/build/web/`
* Windows Output: `frontend/build/windows/x64/runner/Release/`
* Android Output: `frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## 3️⃣ Testing & Code Quality Commands

### Run Backend Unit Tests
```bash
cd backend
mvn test
```

### Run Flutter Analysis & Widget Tests
```bash
cd frontend

# Run Dart code analysis (0 errors, 0 warnings)
flutter analyze

# Run Flutter automated widget smoke & router tests
flutter test
```

---

## 4️⃣ Environment Variables Quick Reference

### Backend (`backend/.env` or System Environment)
| Variable | Default | Purpose |
| :--- | :--- | :--- |
| `PORT` | `5000` | Server HTTP port |
| `SPRING_DATASOURCE_URL` | `jdbc:postgresql://localhost:5432/edlearndb` | PostgreSQL JDBC database connection URL |
| `DATABASE_URL` | `jdbc:postgresql://localhost:5432/edlearndb` | Alternative PostgreSQL database connection URL |
| `DB_USERNAME` | `postgres` | Database username |
| `DB_PASSWORD` | `postgres` | Database password |
| `JWT_SECRET` | *(256-bit Hex Key)* | Authentication JWT signing secret |
| `JWT_EXPIRATION_MS` | `86400000` | JWT token validity (24 hours) |
| `CLOUDINARY_CLOUD_NAME` | `dltpal1gr` | Cloudinary storage account name |
| `CLOUDINARY_API_KEY` | *(Key)* | Cloudinary API Key |
| `CLOUDINARY_API_SECRET` | *(Secret)* | Cloudinary API Secret |
| `CORS_ALLOWED_ORIGINS` | `http://localhost:5173,http://localhost:3000` | Allowed frontend client origins |

### Frontend Configuration (`frontend/lib/constants/api_constants.dart`)
| Parameter | Default | Purpose |
| :--- | :--- | :--- |
| `baseUrl` | `http://localhost:5000/api` | Spring Boot REST API endpoint |
| `isOfflineMockEnabled` | `true` | Graceful fallback when backend is unreachable |

---

## 5️⃣ How Configuration Is Activated

### ⚡ Automatic In-App Activation
1. **Backend (`ManagementApplication.java`)**:
   - Automatically reads `.env` from `backend/.env` or project root upon startup.
   - Sets Java system properties (`System.setProperty`) for Spring Boot configuration.
   - Automatically formats `DATABASE_URL` to standard JDBC format (`jdbc:postgresql://...`).
   - Logs: `>>> [LMS-BACKEND] 🚀 Activated X variables from .env file`.

2. **Frontend (`frontend/lib/constants/api_constants.dart`)**:
   - Centralized API endpoints connected to the Spring Boot REST endpoints.
   - In-app session management via `StorageService` (`SharedPreferences`).

### 💻 Manual Shell Activation Commands (Terminal)
If you want to activate `.env` variables in your terminal shell before executing any command:

- **Windows PowerShell:**
  ```powershell
  Get-Content .env | Where-Object { $_ -match '=' -and -not $_.StartsWith('#') } | ForEach-Object { $k, $v = $_.Split('=', 2); [System.Environment]::SetEnvironmentVariable($k.Trim(), $v.Trim(), 'Process') }
  ```
- **Windows Command Prompt (CMD):**
  ```cmd
  for /f "tokens=*" %i in (.env) do set %i
  ```
- **Linux / macOS (Bash / Zsh):**
  ```bash
  source .env
  # or
  export $(grep -v '^#' .env | xargs)
  ```


