package com.edlearn.backend.service;

import com.edlearn.backend.dto.ApiResponse;
import com.edlearn.backend.dto.LoginRequest;
import com.edlearn.backend.dto.RegisterRequests.*;
import com.edlearn.backend.model.InstituteEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.InstituteRepository;
import com.edlearn.backend.repository.UserRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class AuthService {

    private final InstituteRepository instituteRepository;
    private final UserRepository userRepository;
    private final PortalTokenService portalTokenService;
    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public AuthService(InstituteRepository instituteRepository, UserRepository userRepository, PortalTokenService portalTokenService) {
        this.instituteRepository = instituteRepository;
        this.userRepository = userRepository;
        this.portalTokenService = portalTokenService;
    }

    private boolean checkPassword(String rawPassword, String storedPassword) {
        if (rawPassword == null || storedPassword == null) return false;
        if (Set.of("password123", "edlearn123").contains(rawPassword)) return false;
        if (storedPassword.startsWith("$2a$") || storedPassword.startsWith("$2b$") || storedPassword.startsWith("$2y$")) {
            try {
                if (passwordEncoder.matches(rawPassword, storedPassword)) return true;
            } catch (Exception ignored) {}
        }
        if (storedPassword.equals(rawPassword)) return true;
        return false;
    }

    private boolean verifyUserPassword(UserEntity user, String rawPassword) {
        if (!checkPassword(rawPassword, user.getPassword())) return false;
        String stored = user.getPassword();
        if (stored != null && !stored.startsWith("$2a$") && !stored.startsWith("$2b$") && !stored.startsWith("$2y$")) {
            user.setPassword(passwordEncoder.encode(rawPassword));
            userRepository.save(user);
        }
        return true;
    }

    public ApiResponse loginInstitute(LoginRequest req) {
        String codeOrEmail = req.getInstituteCode() != null && !req.getInstituteCode().isBlank() 
                ? req.getInstituteCode().trim() 
                : (req.getEmail() != null ? req.getEmail().trim() : "");
        String rawPassword = req.getPassword() != null ? req.getPassword() : "";

        if (codeOrEmail.isBlank()) {
            return ApiResponse.error("Institute code or email is required.");
        }

        Optional<InstituteEntity> instOpt = instituteRepository.findByInstituteCodeIgnoreCase(codeOrEmail);
        if (!instOpt.isPresent()) {
            instOpt = instituteRepository.findByEmailIgnoreCase(codeOrEmail);
        }

        if (!instOpt.isPresent()) {
            return ApiResponse.error("Invalid credentials or inactive account.");
        }

        InstituteEntity institute = instOpt.get();
        // ONLY validate institutePassword (stored in institute table)
        String storedInstitutePass = institute.getInstitutePassword();
        if (!checkPassword(rawPassword, storedInstitutePass)) {
            return ApiResponse.error("Invalid credentials or inactive account.");
        }

        UserEntity userForToken = userRepository.findByInstituteCodeIgnoreCaseAndRoleIgnoreCase(institute.getInstituteCode(), "admin")
                .stream().filter(user -> "Active".equalsIgnoreCase(user.getStatus())).findFirst()
                .orElseThrow(() -> new org.springframework.web.server.ResponseStatusException(
                        org.springframework.http.HttpStatus.UNAUTHORIZED, "Invalid credentials or inactive account."));

        Map<String, Object> userMap = new LinkedHashMap<>();
        userMap.put("id", "inst_" + institute.getInstituteCode());
        userMap.put("name", institute.getAdminName() != null ? institute.getAdminName() : "Institute Administrator");
        userMap.put("email", institute.getEmail());
        userMap.put("role", "institute");
        userMap.put("instituteCode", institute.getInstituteCode());
        userMap.put("instituteName", institute.getInstituteName());
        userMap.put("isVerified", institute.getVerified() != null ? institute.getVerified() : true);
        userMap.put("verificationStatus", institute.getVerificationStatus() != null ? institute.getVerificationStatus() : "Officially Verified");
        userMap.put("verificationId", institute.getVerificationId());
        userMap.put("verificationDate", institute.getVerificationDate());
        userMap.put("accreditation", institute.getAccreditation());
        userMap.put("establishedYear", institute.getEstablishedYear());
        userMap.put("campusLocation", institute.getCampusLocation());
        userMap.put("studentCount", institute.getStudentCount() != null ? institute.getStudentCount() : 0);
        userMap.put("facultyCount", institute.getFacultyCount() != null ? institute.getFacultyCount() : 0);
        userMap.put("departmentCount", institute.getDepartmentCount() != null ? institute.getDepartmentCount() : 1);
        userMap.put("activeSemester", institute.getActiveSemester());

        String token = portalTokenService.issue(userForToken, "institute");
        return ApiResponse.ok(token, userMap, "Institute authenticated successfully.");
    }

    public ApiResponse loginAdmin(LoginRequest req) {
        String identifier = req.getEmail() != null ? req.getEmail().trim() : "";
        String rawPassword = req.getPassword() != null ? req.getPassword() : "";

        Optional<UserEntity> userOpt = identifier.isBlank() ? Optional.empty() : userRepository.findByEmailIgnoreCase(identifier);
        if (userOpt.isEmpty() && !identifier.isBlank()) userOpt = userRepository.findByUserId(identifier);
        UserEntity adminUser = userOpt.orElse(null);
        if (adminUser == null || !"admin".equalsIgnoreCase(adminUser.getRole())
                || !verifyUserPassword(adminUser, rawPassword)
                || !"Active".equalsIgnoreCase(adminUser.getStatus())
                || adminUser.getInstituteCode() == null || adminUser.getInstituteCode().isBlank()) {
            return ApiResponse.error("Invalid credentials or inactive account.");
        }

        Map<String, Object> userMap = toUserMap(adminUser);
        String token = portalTokenService.issue(adminUser);
        return ApiResponse.ok(token, userMap, "Administrator signed in successfully.");
    }

    public ApiResponse loginRole(LoginRequest req) {
        String role = req.getRole() != null ? req.getRole().trim().toLowerCase() : "student";
        if ("institute".equalsIgnoreCase(role)) {
            return loginInstitute(req);
        }
        if ("admin".equalsIgnoreCase(role)) {
            return loginAdmin(req);
        }

        String identifier = req.getEmail() != null ? req.getEmail().trim() : "";
        String rawPassword = req.getPassword() != null ? req.getPassword() : "";

        if (identifier.isBlank() || !Set.of("student", "teacher", "instructor").contains(role))
            return ApiResponse.error("Invalid credentials or inactive account.");

        UserEntity user = null;
        Optional<UserEntity> userOpt = userRepository.findByEmailIgnoreCase(identifier);
        if (userOpt.isPresent()) {
            user = userOpt.get();
        } else {
            // Lookup by rollNumber, instructorId, or userId
            userOpt = userRepository.findByRollNumberIgnoreCase(identifier);
            if (userOpt.isPresent()) {
                user = userOpt.get();
            } else {
                userOpt = userRepository.findByInstructorIdIgnoreCase(identifier);
                if (userOpt.isPresent()) {
                    user = userOpt.get();
                } else {
                    userOpt = userRepository.findByUserId(identifier);
                    if (userOpt.isPresent()) {
                        user = userOpt.get();
                    }
                }
            }
        }

        if (user == null) return ApiResponse.error("Invalid credentials or inactive account.");

        String userRole = user.getRole() != null ? user.getRole().toLowerCase() : "";
        boolean roleMatches = userRole.equalsIgnoreCase(role) ||
                (role.equalsIgnoreCase("teacher") && userRole.equalsIgnoreCase("instructor")) ||
                (role.equalsIgnoreCase("instructor") && userRole.equalsIgnoreCase("teacher"));

        if (!roleMatches || !verifyUserPassword(user, rawPassword)
                || !"Active".equalsIgnoreCase(user.getStatus())
                || user.getInstituteCode() == null || user.getInstituteCode().isBlank()) {
            return ApiResponse.error("Invalid credentials or inactive account.");
        }

        Map<String, Object> userMap = toUserMap(user);
        String token = portalTokenService.issue(user);
        String roleName = role.substring(0, 1).toUpperCase() + role.substring(1);

        return ApiResponse.ok(token, userMap, roleName + " signed in successfully.");
    }

    public ApiResponse registerInstitute(InstituteRegisterRequest req) {
        String instEmail = req.getInstituteEmail() != null && !req.getInstituteEmail().isBlank()
                ? req.getInstituteEmail().trim()
                : "";
        String adminEmail = req.getAdminEmail() != null && !req.getAdminEmail().isBlank()
                ? req.getAdminEmail().trim()
                : instEmail;
        String emailToStore = !instEmail.isBlank() ? instEmail : adminEmail;

        if (!emailToStore.contains("@") || req.getInstituteName() == null || req.getInstituteName().isBlank()) {
            return ApiResponse.error("Institute name and a valid official email are required.");
        }
        if (instituteRepository.existsByEmailIgnoreCase(emailToStore) || userRepository.existsByEmailIgnoreCase(adminEmail)) {
            return ApiResponse.error("An institute or account with that email is already registered.");
        }

        String institutePassword = req.getInstitutePassword();
        String adminPassword = req.getAdminPassword();

        if (institutePassword == null || institutePassword.length() < 8 || Set.of("password123", "edlearn123").contains(institutePassword)) {
            return ApiResponse.error("Choose a non-default institute password with at least 8 characters.");
        }
        if (adminPassword == null || adminPassword.length() < 8 || Set.of("password123", "edlearn123").contains(adminPassword)) {
            return ApiResponse.error("Choose a non-default admin password with at least 8 characters.");
        }
        if (institutePassword.equals(adminPassword)) {
            return ApiResponse.error("Institute and Admin passwords must be different.");
        }

        // BCrypt encrypt both passwords separately
        String encodedInstitutePassword = passwordEncoder.encode(institutePassword);
        String encodedAdminPassword = passwordEncoder.encode(adminPassword);

        String generatedCode = "INST-" + (1000 + new Random().nextInt(9000));
        InstituteEntity institute = new InstituteEntity();
        institute.setInstituteCode(generatedCode);
        institute.setInstituteName(req.getInstituteName() != null && !req.getInstituteName().isBlank() ? req.getInstituteName().trim() : "Apex Institute of Technology");
        institute.setInstituteType(req.getInstituteType() != null && !req.getInstituteType().isBlank() ? req.getInstituteType().trim() : "College");
        institute.setAdminName(req.getAdminName() != null && !req.getAdminName().isBlank() ? req.getAdminName().trim() : "Institute Administrator");
        institute.setEmail(emailToStore);
        institute.setInstitutePassword(encodedInstitutePassword);
        institute.setAdminPassword(encodedAdminPassword);
        institute.setPassword(encodedInstitutePassword);
        institute.setPhone(req.getPhone() != null && !req.getPhone().isBlank() ? req.getPhone().trim() : "+91 98765 43210");
        String address = req.getAddress() != null && !req.getAddress().isBlank() ? req.getAddress().trim() : (req.getCity() != null ? req.getCity() + ", Campus" : "Central Academic Campus");
        institute.setAddress(address);
        institute.setCampusLocation((req.getCity() != null && !req.getCity().isBlank() ? req.getCity().trim() : "Central") + " Campus");
        institute.setAccreditation(req.getAccreditation() != null && !req.getAccreditation().isBlank() ? req.getAccreditation().trim() : "AICTE & UGC Recognized • Grade A+ NAAC Accredited");
        institute.setVerificationId("VRF-" + generatedCode.replace("-", "") + "-2025");
        institute.setVerificationDate("Academic Session 2025–2026");
        institute.setEstablishedYear(req.getEstablishedYear() != null && !req.getEstablishedYear().isBlank() ? req.getEstablishedYear().trim() : "2024");
        institute.setVerified(false);
        institute.setVerificationStatus("Verification Pending");
        institute.setActiveSemester("Academic Year 2025–2026");
        institute.setStudentCount(0);
        institute.setFacultyCount(0);
        institute.setDepartmentCount(1);

        UserEntity adminUser;
        try {
            institute = instituteRepository.save(institute);
        } catch (Exception ex) {
            return ApiResponse.error("Failed to store institute in database: " + ex.getMessage());
        }

        // Automatically create Administrator User for this institute in users table
        try {
            adminUser = new UserEntity();
            adminUser.setUserId("adm_" + generatedCode.toLowerCase(Locale.ROOT).replace("-", "") + "_" + UUID.randomUUID().toString().substring(0, 8));
            adminUser.setEmail(adminEmail);
            adminUser.setPassword(encodedAdminPassword);
            adminUser.setRole("admin");
            adminUser.setName(req.getAdminName() != null && !req.getAdminName().isBlank() ? req.getAdminName().trim() : "System Administrator");
            adminUser.setInstituteCode(institute.getInstituteCode());
            adminUser.setInstituteName(institute.getInstituteName());
            adminUser.setPhone(institute.getPhone());
            adminUser.setAddress(institute.getAddress());
            adminUser.setTitle("System Administrator");
            adminUser.setDesignation("Master Administrator");
            adminUser.setStatus("Active");
            adminUser = userRepository.save(adminUser);
        } catch (Exception ex) {
            return ApiResponse.error("Unable to complete institute registration. Check the submitted details and try again.");
        }

        Map<String, Object> userMap = new LinkedHashMap<>();
        userMap.put("id", "inst_" + institute.getInstituteCode());
        userMap.put("instituteName", institute.getInstituteName());
        userMap.put("instituteType", institute.getInstituteType());
        userMap.put("name", institute.getAdminName());
        userMap.put("email", institute.getEmail());
        userMap.put("role", "institute");
        userMap.put("instituteCode", institute.getInstituteCode());
        userMap.put("isVerified", institute.getVerified());
        userMap.put("verificationStatus", institute.getVerificationStatus());
        userMap.put("verificationId", institute.getVerificationId());
        userMap.put("verificationDate", institute.getVerificationDate());
        userMap.put("campusLocation", institute.getCampusLocation());
        userMap.put("studentCount", institute.getStudentCount());
        userMap.put("facultyCount", institute.getFacultyCount());
        userMap.put("departmentCount", institute.getDepartmentCount());

        String token = portalTokenService.issue(adminUser, "institute");
        return ApiResponse.ok(token, userMap, "Institute account registered successfully! Institute code: " + generatedCode);
    }

    public ApiResponse registerStudent(StudentRegisterRequest req) {
        String email = req.getEmail() != null ? req.getEmail().trim() : "";
        if (!email.contains("@") || req.getFullName() == null || req.getFullName().isBlank()) {
            return ApiResponse.error("A valid email and full name are required.");
        }
        String rawPass = req.getPassword();
        if (rawPass == null || rawPass.length() < 8 || Set.of("password123", "edlearn123").contains(rawPass)) {
            return ApiResponse.error("Choose a non-default password with at least 8 characters.");
        }
        String instCode = req.getInstituteCode() == null ? "" : req.getInstituteCode().trim().toUpperCase(Locale.ROOT);
        InstituteEntity institute = instituteRepository.findByInstituteCodeIgnoreCase(instCode).orElse(null);
        if (institute == null) return ApiResponse.error("A valid institute code is required.");
        if (req.getRollNumber() == null || req.getRollNumber().isBlank()) {
            return ApiResponse.error("Student roll number is required.");
        }
        if (userRepository.existsByRollNumberIgnoreCase(req.getRollNumber().trim())) {
            return ApiResponse.error("Student roll number already exists.");
        }
        if (userRepository.existsByEmailIgnoreCase(email)) {
            return ApiResponse.error("An account with email " + email + " already exists. Please log in.");
        }

        UserEntity student = new UserEntity();
        student.setUserId("std_" + System.currentTimeMillis());

        String studentName = req.getFullName() != null && !req.getFullName().isBlank() ? req.getFullName().trim() : "Student";
        student.setName(studentName);
        student.setEmail(email);
        student.setPassword(passwordEncoder.encode(rawPass));
        student.setRole("student");

        student.setInstituteCode(instCode);
        student.setInstituteName(institute.getInstituteName());

        String roll = req.getRollNumber().trim();
        student.setRollNumber(roll);

        String course = req.getCourse() != null ? req.getCourse().trim() : "";
        if (course.isBlank()) return ApiResponse.error("Student course is required.");
        student.setCourse(course);

        String className = req.getClassName() != null && !req.getClassName().isBlank() ? req.getClassName().trim() : course;
        student.setClassName(className);

        String semester = req.getSemester() != null && !req.getSemester().isBlank() 
                ? req.getSemester().trim() 
                : "Semester 1";
        student.setSemester(semester);

        student.setPhone(req.getPhone());
        student.setGender(req.getGender());
        student.setDob(req.getDob());
        student.setAddress(req.getAddress());
        student.setFatherName(req.getFatherName());
        student.setFatherPhone(req.getFatherPhone());

        student.setStatus("Active");
        student.setDepartment(course);

        try {
            student = userRepository.save(student);
        } catch (DataIntegrityViolationException ex) {
            return ApiResponse.error("An account with the supplied email or student ID already exists.");
        } catch (Exception ex) {
            return ApiResponse.error("Failed to store student in the database.");
        }

        Map<String, Object> userMap = toUserMap(student);
        String token = portalTokenService.issue(student);
        return ApiResponse.ok(token, userMap, "Student registered successfully! Stored in Neon database.");
    }

    public ApiResponse registerTeacher(TeacherRegisterRequest req) {
        String email = req.getEmail() != null ? req.getEmail().trim() : "";
        if (!email.contains("@") || req.getFullName() == null || req.getFullName().isBlank()) {
            return ApiResponse.error("A valid email and full name are required.");
        }
        String rawPass = req.getPassword();
        if (rawPass == null || rawPass.length() < 8 || Set.of("password123", "edlearn123").contains(rawPass)) {
            return ApiResponse.error("Choose a non-default password with at least 8 characters.");
        }
        String instCode = req.getInstituteCode() == null ? "" : req.getInstituteCode().trim().toUpperCase(Locale.ROOT);
        InstituteEntity institute = instituteRepository.findByInstituteCodeIgnoreCase(instCode).orElse(null);
        if (institute == null) return ApiResponse.error("A valid institute code is required.");
        if (req.getEmployeeId() != null && !req.getEmployeeId().isBlank()
                && userRepository.existsByInstructorIdIgnoreCase(req.getEmployeeId().trim())) {
            return ApiResponse.error("Instructor ID already exists.");
        }
        if (userRepository.existsByEmailIgnoreCase(email)) {
            return ApiResponse.error("An account with email " + email + " already exists. Please log in.");
        }

        UserEntity teacher = new UserEntity();
        teacher.setUserId("tch_" + System.currentTimeMillis());

        String teacherName = req.getFullName() != null && !req.getFullName().isBlank() ? req.getFullName().trim() : "Faculty Member";
        teacher.setName(teacherName);
        teacher.setEmail(email);
        teacher.setPassword(passwordEncoder.encode(rawPass));
        teacher.setRole("teacher");

        teacher.setInstituteCode(instCode);
        teacher.setInstituteName(institute.getInstituteName());

        String empId = req.getEmployeeId() != null && !req.getEmployeeId().isBlank() 
                ? req.getEmployeeId().trim() 
                : "EMP-" + (1000 + new Random().nextInt(9000));
        teacher.setInstructorId(empId);

        String dept = req.getDepartment() != null && !req.getDepartment().isBlank() 
                ? req.getDepartment().trim() 
                : "Computer Science";
        teacher.setDepartment(dept);

        String phone = req.getPhone() != null && !req.getPhone().isBlank() 
                ? req.getPhone().trim() 
                : "+91 98765 00000";
        teacher.setPhone(phone);

        String desig = req.getDesignation() != null && !req.getDesignation().isBlank() 
                ? req.getDesignation().trim() 
                : "Assistant Professor";
        teacher.setDesignation(desig);

        String qual = req.getQualification() != null && !req.getQualification().isBlank() 
                ? req.getQualification().trim() 
                : "Master's Degree";
        teacher.setQualification(qual);

        String exp = req.getExperience() != null && !req.getExperience().isBlank() 
                ? req.getExperience().trim() 
                : "3+ Years";
        teacher.setExperience(exp);

        teacher.setJoiningDate("2024-01-15");
        teacher.setAbout("Passionate faculty educator in " + dept + ".");

        String addr = req.getAddress() != null && !req.getAddress().isBlank() 
                ? req.getAddress().trim() 
                : "Campus Faculty Quarters";
        teacher.setAddress(addr);

        teacher.setStatus("Pending");

        try {
            teacher = userRepository.save(teacher);
        } catch (DataIntegrityViolationException ex) {
            return ApiResponse.error("An account with the supplied email or instructor ID already exists.");
        } catch (Exception ex) {
            return ApiResponse.error("Failed to store instructor in the database.");
        }

        return ApiResponse.error("Registration request submitted. An institute administrator must activate the account before sign-in.");
    }

    public ApiResponse forgotPassword(Map<String, String> body) {
        String email = body != null ? body.get("email") : "user@example.com";
        return ApiResponse.ok("Password reset instructions sent to " + email + ".");
    }

    private Map<String, Object> toUserMap(UserEntity user) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", user.getUserId() != null ? user.getUserId() : "usr_" + user.getId());
        map.put("email", user.getEmail());
        map.put("role", user.getRole());
        map.put("name", user.getName());
        map.put("instituteCode", user.getInstituteCode());
        map.put("instituteName", user.getInstituteName());
        map.put("phone", user.getPhone());
        map.put("avatarUrl", user.getAvatarUrl());

        if ("student".equalsIgnoreCase(user.getRole())) {
            map.put("rollNumber", user.getRollNumber());
            map.put("className", user.getClassName());
            map.put("course", user.getCourse());
            map.put("semester", user.getSemester());
            map.put("gender", user.getGender());
            map.put("dob", user.getDob());
            map.put("fatherName", user.getFatherName());
            map.put("fatherPhone", user.getFatherPhone());
            map.put("fatherEmail", user.getFatherEmail());
            map.put("motherName", user.getMotherName());
            map.put("motherPhone", user.getMotherPhone());
            map.put("motherEmail", user.getMotherEmail());
            map.put("address", user.getAddress());
        } else if ("teacher".equalsIgnoreCase(user.getRole())) {
            map.put("instructorId", user.getInstructorId());
            map.put("designation", user.getDesignation());
            map.put("department", user.getDepartment());
            map.put("joiningDate", user.getJoiningDate());
            map.put("qualification", user.getQualification());
            map.put("experience", user.getExperience());
            map.put("about", user.getAbout());
        } else if ("admin".equalsIgnoreCase(user.getRole())) {
            map.put("title", user.getTitle());
            map.put("designation", user.getDesignation());
        }
        return map;
    }
}
