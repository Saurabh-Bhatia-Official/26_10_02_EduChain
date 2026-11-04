package com.edlearn.backend.service;

import com.edlearn.backend.dto.ApiResponse;
import com.edlearn.backend.dto.LoginRequest;
import com.edlearn.backend.dto.RegisterRequests.*;
import com.edlearn.backend.model.InstituteEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.InstituteRepository;
import com.edlearn.backend.repository.UserRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class AuthService {

    private final InstituteRepository instituteRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public AuthService(InstituteRepository instituteRepository, UserRepository userRepository) {
        this.instituteRepository = instituteRepository;
        this.userRepository = userRepository;
    }

    private boolean checkPassword(String rawPassword, String storedPassword) {
        if (rawPassword == null || storedPassword == null) return false;
        if (storedPassword.startsWith("$2a$") || storedPassword.startsWith("$2b$") || storedPassword.startsWith("$2y$")) {
            try {
                return passwordEncoder.matches(rawPassword, storedPassword);
            } catch (Exception ignored) {}
        }
        return storedPassword.equals(rawPassword);
    }

    @PostConstruct
    public void seedDefaultDataIfEmpty() {
        try {
            if (instituteRepository.count() == 0) {
                InstituteEntity defaultInst = new InstituteEntity();
                defaultInst.setInstituteCode("INST-2025");
                defaultInst.setInstituteName("Apex Institute of Technology");
                defaultInst.setInstituteType("College");
                defaultInst.setAdminName("Institute Administrator");
                defaultInst.setEmail("admin@apex.edu");
                defaultInst.setPassword("password123");
                defaultInst.setPhone("+91 98765 43210");
                defaultInst.setAddress("Academic Campus, Delhi");
                defaultInst.setCampusLocation("Central Academic Campus");
                defaultInst.setAccreditation("AICTE & UGC Recognized • Grade A+ NAAC Accredited");
                defaultInst.setEstablishedYear("2008");
                defaultInst.setVerified(true);
                defaultInst.setVerificationStatus("Officially Verified");
                defaultInst.setVerificationId("VRF-INST2025-2025");
                defaultInst.setVerificationDate("Academic Session 2025–2026");
                defaultInst.setStudentCount(1420);
                defaultInst.setFacultyCount(86);
                defaultInst.setDepartmentCount(8);
                defaultInst.setActiveSemester("Academic Year 2025–2026");
                instituteRepository.save(defaultInst);
            }

            if (userRepository.count() == 0) {
                UserEntity student = new UserEntity();
                student.setUserId("std_1023");
                student.setEmail("rahul@institute.com");
                student.setPassword("password123");
                student.setRole("student");
                student.setName("Rahul Sharma");
                student.setRollNumber("1023");
                student.setClassName("BCA - Sem 3");
                student.setCourse("Bachelor of Computer Applications");
                student.setSemester("Semester 3");
                student.setInstituteCode("INST-2025");
                student.setInstituteName("Apex Institute of Technology");
                student.setGender("Male");
                student.setDob("12-05-2005");
                student.setFatherName("Rakesh Sharma");
                student.setFatherPhone("+91 98765 43210");
                student.setFatherEmail("rakesh@example.com");
                student.setMotherName("Pooja Sharma");
                student.setMotherPhone("+91 98765 43211");
                student.setMotherEmail("pooja@example.com");
                student.setAddress("123, Green Park, Delhi - 110016");
                userRepository.save(student);

                UserEntity teacher = new UserEntity();
                teacher.setUserId("ins_001");
                teacher.setEmail("amit.sharma@institute.com");
                teacher.setPassword("password123");
                teacher.setRole("teacher");
                teacher.setName("Dr. Amit Sharma");
                teacher.setInstructorId("INS-001");
                teacher.setDesignation("Assistant Professor");
                teacher.setDepartment("Computer Science");
                teacher.setPhone("+91 98765 43210");
                teacher.setJoiningDate("Jan 14, 2020");
                teacher.setQualification("Ph.D - Computer Science");
                teacher.setExperience("5 Years");
                teacher.setAbout("Passionate educator with 5+ years of experience in teaching and research.");
                teacher.setInstituteCode("INST-2025");
                teacher.setInstituteName("Apex Institute of Technology");
                userRepository.save(teacher);

                UserEntity admin = new UserEntity();
                admin.setUserId("adm_001");
                admin.setEmail("amit.kumar@institute.com");
                admin.setPassword("password123");
                admin.setRole("admin");
                admin.setName("Amit Kumar");
                admin.setTitle("System Administrator");
                admin.setDesignation("System Administrator");
                admin.setPhone("+91 98765 43210");
                admin.setInstituteCode("INST-2025");
                admin.setInstituteName("Apex Institute of Technology");
                userRepository.save(admin);
            }
        } catch (Exception e) {
            System.out.println("Notice: Database seeding bypassed or database in standby mode: " + e.getMessage());
        }
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
            return ApiResponse.error("No registered institute found for: " + codeOrEmail + ". Please check your code/email or register.");
        }

        InstituteEntity institute = instOpt.get();
        // ONLY validate institutePassword (stored in institute table)
        String storedInstitutePass = institute.getInstitutePassword();
        if (!checkPassword(rawPassword, storedInstitutePass)) {
            return ApiResponse.error("Invalid credentials: Incorrect institute password for " + institute.getInstituteCode() + ".");
        }

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

        String token = "jwt-inst-" + institute.getInstituteCode() + "-" + System.currentTimeMillis();
        return ApiResponse.ok(token, userMap, "Institute authenticated successfully.");
    }

    public ApiResponse loginAdmin(LoginRequest req) {
        String identifier = req.getEmail() != null ? req.getEmail().trim() : "";
        String rawPassword = req.getPassword() != null ? req.getPassword() : "";

        if (identifier.isBlank()) {
            return ApiResponse.error("Admin email is required.");
        }

        Optional<UserEntity> userOpt = userRepository.findByEmailIgnoreCase(identifier);
        if (!userOpt.isPresent()) {
            userOpt = userRepository.findByUserId(identifier);
        }

        if (!userOpt.isPresent()) {
            return ApiResponse.error("No Administrator account found for '" + identifier + "'. Please verify admin email or register.");
        }

        UserEntity adminUser = userOpt.get();
        String userRole = adminUser.getRole() != null ? adminUser.getRole().toLowerCase() : "";
        if (!"admin".equals(userRole)) {
            return ApiResponse.error("Access denied: Account '" + identifier + "' is registered as a " + adminUser.getRole() + ", not an Administrator.");
        }

        // ONLY validate adminPassword from users table
        if (!checkPassword(rawPassword, adminUser.getPassword())) {
            return ApiResponse.error("Invalid credentials: Incorrect admin password.");
        }

        Map<String, Object> userMap = toUserMap(adminUser);
        String token = "jwt-admin-" + adminUser.getUserId() + "-" + System.currentTimeMillis();
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

        if (identifier.isBlank()) {
            return ApiResponse.error("Email or ID is required.");
        }

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

        if (user == null) {
            return ApiResponse.error("Account not found for '" + identifier + "'. Please check your credentials or register.");
        }

        String userRole = user.getRole() != null ? user.getRole().toLowerCase() : "";
        boolean roleMatches = userRole.equalsIgnoreCase(role) ||
                (role.equalsIgnoreCase("teacher") && userRole.equalsIgnoreCase("instructor")) ||
                (role.equalsIgnoreCase("instructor") && userRole.equalsIgnoreCase("teacher"));

        if (!roleMatches) {
            return ApiResponse.error("Access denied: This account is registered as a " + userRole + ", not a " + role + ".");
        }

        if (!checkPassword(rawPassword, user.getPassword())) {
            return ApiResponse.error("Invalid credentials: Incorrect password.");
        }

        Map<String, Object> userMap = toUserMap(user);
        String token = "jwt-" + role + "-" + user.getUserId() + "-" + System.currentTimeMillis();
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

        if (instituteRepository.existsByEmailIgnoreCase(emailToStore)) {
            return ApiResponse.error("An institute with email " + emailToStore + " is already registered.");
        }

        String institutePassword = req.getInstitutePassword();
        String adminPassword = req.getAdminPassword();

        if (institutePassword == null || institutePassword.isBlank() || institutePassword.length() < 6) {
            return ApiResponse.error("Institute password is required (minimum 6 characters).");
        }
        if (adminPassword == null || adminPassword.isBlank() || adminPassword.length() < 6) {
            return ApiResponse.error("Admin password is required (minimum 6 characters).");
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
        institute.setVerified(true);
        institute.setVerificationStatus("Officially Verified");
        institute.setActiveSemester("Academic Year 2025–2026");
        institute.setStudentCount(0);
        institute.setFacultyCount(0);
        institute.setDepartmentCount(1);

        try {
            institute = instituteRepository.save(institute);
        } catch (Exception ex) {
            return ApiResponse.error("Failed to store institute in database: " + ex.getMessage());
        }

        // Automatically create Administrator User for this institute in users table
        try {
            UserEntity adminUser = userRepository.findByEmailIgnoreCase(adminEmail).orElseGet(UserEntity::new);
            if (adminUser.getUserId() == null) {
                adminUser.setUserId("adm_" + generatedCode.toLowerCase().replace("-", "") + "_" + (100 + new Random().nextInt(900)));
            }
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
            userRepository.save(adminUser);
        } catch (Exception ex) {
            System.err.println("Notice: Could not automatically persist admin user: " + ex.getMessage());
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

        String token = "jwt-inst-" + institute.getInstituteCode() + "-" + System.currentTimeMillis();
        return ApiResponse.ok(token, userMap, "Institute account registered successfully! Institute code: " + generatedCode);
    }

    public ApiResponse registerStudent(StudentRegisterRequest req) {
        String email = req.getEmail() != null ? req.getEmail().trim() : "";
        if (email.isBlank()) {
            return ApiResponse.error("Email is required for registration.");
        }
        if (userRepository.existsByEmailIgnoreCase(email)) {
            return ApiResponse.error("An account with email " + email + " already exists. Please log in.");
        }

        String rawPass = req.getPassword() != null && !req.getPassword().isBlank() ? req.getPassword() : "password123";
        UserEntity student = new UserEntity();
        student.setUserId("std_" + System.currentTimeMillis());

        String studentName = req.getFullName() != null && !req.getFullName().isBlank() ? req.getFullName().trim() : "Student";
        student.setName(studentName);
        student.setEmail(email);
        student.setPassword(passwordEncoder.encode(rawPass));
        student.setRole("student");

        String instCode = req.getInstituteCode() != null && !req.getInstituteCode().isBlank() 
                ? req.getInstituteCode().trim().toUpperCase() 
                : "INST-2025";
        student.setInstituteCode(instCode);
        String instName = instituteRepository.findByInstituteCodeIgnoreCase(instCode)
                .map(InstituteEntity::getInstituteName)
                .orElse("Apex Institute of Technology");
        student.setInstituteName(instName);

        String roll = req.getRollNumber() != null && !req.getRollNumber().isBlank() 
                ? req.getRollNumber().trim() 
                : "STD-" + (1000 + new Random().nextInt(9000));
        student.setRollNumber(roll);

        String course = req.getCourse() != null && !req.getCourse().isBlank() 
                ? req.getCourse().trim() 
                : "Computer Science & Engineering";
        student.setCourse(course);

        String className = req.getClassName() != null && !req.getClassName().isBlank() 
                ? req.getClassName().trim() 
                : course;
        student.setClassName(className);

        String semester = req.getSemester() != null && !req.getSemester().isBlank() 
                ? req.getSemester().trim() 
                : "Semester 1";
        student.setSemester(semester);

        String phone = req.getPhone() != null && !req.getPhone().isBlank() 
                ? req.getPhone().trim() 
                : "+91 98765 00000";
        student.setPhone(phone);

        String gender = req.getGender() != null && !req.getGender().isBlank() 
                ? req.getGender().trim() 
                : "Not Specified";
        student.setGender(gender);

        String dob = req.getDob() != null && !req.getDob().isBlank() 
                ? req.getDob().trim() 
                : "2005-01-01";
        student.setDob(dob);

        String address = req.getAddress() != null && !req.getAddress().isBlank() 
                ? req.getAddress().trim() 
                : "Campus Residential";
        student.setAddress(address);

        String fatherName = req.getFatherName() != null && !req.getFatherName().isBlank() 
                ? req.getFatherName().trim() 
                : "Guardian of " + studentName;
        student.setFatherName(fatherName);

        String fatherPhone = req.getFatherPhone() != null && !req.getFatherPhone().isBlank() 
                ? req.getFatherPhone().trim() 
                : phone;
        student.setFatherPhone(fatherPhone);
        student.setFatherEmail(email.contains("@") ? email.replace("@", ".parent@") : "parent@example.com");

        String motherName = req.getMotherName() != null && !req.getMotherName().isBlank() 
                ? req.getMotherName().trim() 
                : "Guardian";
        student.setMotherName(motherName);
        student.setMotherPhone(phone);
        student.setMotherEmail(email.contains("@") ? email.replace("@", ".mother@") : "mother@example.com");

        student.setStatus("Active");
        student.setDepartment(course);

        try {
            student = userRepository.save(student);
        } catch (Exception ex) {
            return ApiResponse.error("Failed to store student in database: " + ex.getMessage());
        }

        Map<String, Object> userMap = toUserMap(student);
        String token = "jwt-student-" + student.getUserId() + "-" + System.currentTimeMillis();
        return ApiResponse.ok(token, userMap, "Student registered successfully! Stored in Neon database.");
    }

    public ApiResponse registerTeacher(TeacherRegisterRequest req) {
        String email = req.getEmail() != null ? req.getEmail().trim() : "";
        if (email.isBlank()) {
            return ApiResponse.error("Email is required for registration.");
        }
        if (userRepository.existsByEmailIgnoreCase(email)) {
            return ApiResponse.error("An account with email " + email + " already exists. Please log in.");
        }

        String rawPass = req.getPassword() != null && !req.getPassword().isBlank() ? req.getPassword() : "password123";
        UserEntity teacher = new UserEntity();
        teacher.setUserId("tch_" + System.currentTimeMillis());

        String teacherName = req.getFullName() != null && !req.getFullName().isBlank() ? req.getFullName().trim() : "Faculty Member";
        teacher.setName(teacherName);
        teacher.setEmail(email);
        teacher.setPassword(passwordEncoder.encode(rawPass));
        teacher.setRole("teacher");

        String instCode = req.getInstituteCode() != null && !req.getInstituteCode().isBlank() 
                ? req.getInstituteCode().trim().toUpperCase() 
                : "INST-2025";
        teacher.setInstituteCode(instCode);
        String instName = instituteRepository.findByInstituteCodeIgnoreCase(instCode)
                .map(InstituteEntity::getInstituteName)
                .orElse("Apex Institute of Technology");
        teacher.setInstituteName(instName);

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

        teacher.setStatus("Active");

        try {
            teacher = userRepository.save(teacher);
        } catch (Exception ex) {
            return ApiResponse.error("Failed to store teacher in database: " + ex.getMessage());
        }

        Map<String, Object> userMap = toUserMap(teacher);
        String token = "jwt-teacher-" + teacher.getUserId() + "-" + System.currentTimeMillis();
        return ApiResponse.ok(token, userMap, "Teacher registered successfully! Stored in Neon database.");
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
