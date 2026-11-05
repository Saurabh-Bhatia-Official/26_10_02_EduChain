# 🚀 EduChain CI/CD Pipeline Guide

This repository includes a production-grade, automated CI/CD pipeline built with **GitHub Actions** that separates frontend multi-platform builds and backend deployment into independent, modular workflows.

---

## 📁 Workflow Overview

```
.github/
└── workflows/
    ├── frontend-build.yml   # Builds, tests, packages, and releases frontend for 6 platforms
    └── backend-deploy.yml   # Tests, builds, deploys to Render, and verifies health status
```

---

## 🎨 1. Frontend Multi-Platform CI/CD (`frontend-build.yml`)

The frontend workflow automatically tests and builds the Flutter application across **all 6 supported platforms**:

### 🖥️ Platform Matrix & Runners

| Platform | Target Artifacts | GitHub Actions Runner | Dependencies / Tooling |
| :--- | :--- | :--- | :--- |
| 🌐 **Web** | `web-<tag>.zip` (HTML5, WASM, CanvasKit) | `ubuntu-latest` | Flutter Web, Zip |
| 🤖 **Android** | `android-<tag>.apk`, `android-<tag>.aab` | `ubuntu-latest` | Java 17 Temurin, Gradle cache, JKS Keystore |
| 🍎 **iOS** | `ios-<tag>.ipa` / `Runner.app` | `macos-latest` | Xcode, CocoaPods, Apple Provisioning Profile |
| 🖥️ **macOS** | `macos-<tag>.zip` (`.app` bundle) | `macos-latest` | Flutter macOS desktop, Apple codesign |
| 🐧 **Linux** | `linux-<tag>.tar.gz`, `linux-<tag>.deb` | `ubuntu-latest` | `clang`, `cmake`, `ninja-build`, `libgtk-3-dev`, `dpkg-deb` |
| 🪟 **Windows** | `windows-<tag>.zip` (Win32 x64 runner) | `windows-latest` | Visual Studio C++ toolchain, PowerShell |

### ⚡ Workflow Stages & Quality Gates
1. **Quality Check Gate**:
   - Executes `flutter doctor -v`, `flutter pub get`, `flutter analyze` (linting), and `flutter test`.
   - Fails fast before running high-cost multi-OS runners.
2. **Version Resolution**:
   - Parses the version string from `frontend/pubspec.yaml` and appends `${{ github.run_number }}`.
   - Generates a semantic release tag (e.g. `v1.0.0+42`).
3. **Parallel Platform Builds**:
   - All 6 platforms build simultaneously across independent runner pools (`ubuntu-latest`, `macos-latest`, `windows-latest`).
   - Graceful fallback: If signing secrets are not yet added to the repository, Android and iOS jobs build unsigned release bundles instead of breaking the pipeline.
4. **Artifact Archival**:
   - Each platform's production assets are archived with `actions/upload-artifact@v4` for 14 days.
5. **Automated GitHub Release**:
   - On pushes to `main` (not PRs), consolidates all 6 platform packages and publishes a formal GitHub Release via GitHub CLI (`gh release`).

---

## ⚙️ 2. Backend Render Deployment CI/CD (`backend-deploy.yml`)

The backend workflow builds, tests, and deploys the Spring Boot application directly to **Render** and actively verifies health status.

### ⚡ Workflow Stages
1. **Build & Test**:
   - Sets up Java 17 (Eclipse Temurin) with Maven caching.
   - Runs `mvn clean test` across the full test suite.
   - Compiles and packages production executable JAR (`mvn package -DskipTests`).
   - Uploads `backend-production.jar` as a verified build artifact.
2. **Render Automated Deployment**:
   - Triggers deployment using either:
     - **Render REST API** (`RENDER_API_KEY` + `RENDER_SERVICE_ID`): Tracks deployment progress until status is `live`.
     - **Render Deploy Hook** (`RENDER_DEPLOY_HOOK_URL`): Instant webhook-triggered deployment.
3. **Health Endpoint Verification**:
   - Polls `${BACKEND_URL}/api/db/health` and `${BACKEND_URL}/` with a 30-attempt retry loop (10-second intervals) to allow Render containers to start up.
   - Validates HTTP 200 status code and database connection before marking the deployment as successful.
4. **Deployment Summary**:
   - Publishes status report to the GitHub Step Summary.

---

## 🔐 3. GitHub Secrets Configuration Reference

Navigate to your GitHub repository: **Settings → Secrets and variables → Actions → New repository secret**.

### 🌐 Backend & Render Secrets

| Secret Name | Required? | Description | Example |
| :--- | :--- | :--- | :--- |
| `RENDER_API_KEY` | Recommended | Render API Key from **Account Settings → API Keys** | `rnd_abc123...` |
| `RENDER_SERVICE_ID` | Recommended | Web Service ID from Render dashboard URL | `srv-d4e5f6g7h8...` |
| `RENDER_DEPLOY_HOOK_URL` | Alternative | Render Webhook Deploy Hook URL | `https://api.render.com/deploy/srv-xxx?key=yyy` |
| `BACKEND_URL` | Recommended | Deployed Render Web Service public URL | `https://edlearn-backend.onrender.com` |

> *Tip: You only need **either** `RENDER_API_KEY` + `RENDER_SERVICE_ID` **or** `RENDER_DEPLOY_HOOK_URL`. If all are provided, the workflow uses the authenticated API with live status tracking.*

### 📱 Frontend Signing Secrets (Optional for Signed Release Binaries)

| Secret Name | Platform | Description |
| :--- | :--- | :--- |
| `ANDROID_KEYSTORE_BASE64` | Android | Base64-encoded keystore file (`.jks` or `.keystore`) |
| `ANDROID_KEY_ALIAS` | Android | Keystore key alias name |
| `ANDROID_KEY_PASSWORD` | Android | Password for the keystore key |
| `ANDROID_STORE_PASSWORD` | Android | Password for the keystore store |
| `APPLE_CERTIFICATE_BASE64` | iOS / macOS | Base64-encoded Apple Distribution certificate (`.p12`) |
| `APPLE_CERTIFICATE_PASSWORD` | iOS / macOS | Password for the Apple `.p12` certificate |
| `APPLE_PROVISIONING_PROFILE_BASE64` | iOS | Base64-encoded mobile provisioning profile (`.mobileprovision`) |
| `APPLE_SIGNING_KEYCHAIN_PASSWORD` | iOS / macOS | Temporary password for the ephemeral build keychain |

---

## 🛠️ 4. Render Web Service Setup Instructions

To deploy the backend to Render:

### Method A: Using Render Blueprints (`render.yaml`)
1. In your [Render Dashboard](https://dashboard.render.com), click **New + → Blueprint**.
2. Connect your repository.
3. Render will read `render.yaml` automatically, set up the Docker container runtime pointing to `backend/Dockerfile`, and configure health checks at `/api/db/health`.
4. Supply your secret environment variables (Neon PostgreSQL credentials, Cloudinary keys) in the Render web console.

### Method B: Manual Web Service Setup
1. In Render Dashboard, click **New + → Web Service**.
2. Connect your Git repository.
3. Configure the following settings:
   - **Name:** `edlearn-backend`
   - **Runtime:** `Docker` (or `Java`)
   - **Dockerfile Path:** `backend/Dockerfile`
   - **Docker Context:** `backend`
   - **Health Check Path:** `/api/db/health`
4. Copy the Service ID (from the URL `https://dashboard.render.com/web/srv-xxxxxx`) or the Deploy Hook URL into your GitHub Secrets!

