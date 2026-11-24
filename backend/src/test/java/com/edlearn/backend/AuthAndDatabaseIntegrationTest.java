package com.edlearn.backend;

import com.edlearn.backend.controller.InstructorController;
import com.edlearn.backend.controller.StudentController;
import com.edlearn.backend.dto.ApiResponse;
import com.edlearn.backend.dto.LoginRequest;
import com.edlearn.backend.dto.RegisterRequests.InstituteRegisterRequest;
import com.edlearn.backend.dto.RegisterRequests.StudentRegisterRequest;
import com.edlearn.backend.model.InstituteEntity;
import com.edlearn.backend.model.UserEntity;
import com.edlearn.backend.repository.InstituteRepository;
import com.edlearn.backend.repository.UserRepository;
import com.edlearn.backend.service.AuthService;
import com.edlearn.backend.service.PortalTokenService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockHttpServletRequest;

import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@EnabledIfEnvironmentVariable(named = "TEST_DATABASE_URL", matches = "jdbc:postgresql://(localhost|127[.]0[.]0[.]1)(:[0-9]+)?/[^?]*test[^?]*.*")
public class AuthAndDatabaseIntegrationTest {

    @Autowired
    private AuthService authService;

    @Autowired
    private InstituteRepository instituteRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PortalTokenService portalTokenService;

    @Autowired
    private StudentController studentController;

    @Autowired
    private InstructorController instructorController;

    @Test
    @DisplayName("Test 1: Institute Registration with 2 separate passwords and isolated logins")
    public void testInstituteTwoPasswordsAndLogins() {
        long idSuffix = System.currentTimeMillis() % 100000;
        String instEmail = "inst_" + idSuffix + "@testuniv.edu";
        String adminEmail = "admin_" + idSuffix + "@testuniv.edu";
        String institutePass = "InstPass#2025";
        String adminPass = "AdminPass#2025";

        InstituteRegisterRequest req = new InstituteRegisterRequest();
        req.setInstituteName("Test University " + idSuffix);
        req.setInstituteType("University");
        req.setInstituteEmail(instEmail);
        req.setAdminEmail(adminEmail);
        req.setAdminName("Dr. Dean " + idSuffix);
        req.setInstitutePassword(institutePass);
        req.setAdminPassword(adminPass);
        req.setPhone("+91 98765 12345");
        req.setAddress("Academic Campus Road");
        req.setCity("Mumbai");
        req.setEstablishedYear("2010");

        ApiResponse regResp = authService.registerInstitute(req);
        assertTrue(regResp.isSuccess(), "Institute registration should succeed: " + regResp.getMessage());

        // Verify institute saved in database
        Optional<InstituteEntity> instOpt = instituteRepository.findByEmailIgnoreCase(instEmail);
        assertTrue(instOpt.isPresent(), "Institute should be found in database");
        InstituteEntity inst = instOpt.get();
        assertEquals("Test University " + idSuffix, inst.getInstituteName());
        assertNotNull(inst.getInstitutePassword(), "Institute password must not be null");
        assertNotNull(inst.getAdminPassword(), "Admin password must not be null");
        assertNotEquals(inst.getInstitutePassword(), inst.getAdminPassword(), "Stored hashes must be different");
        assertNotNull(inst.getInstituteCode(), "Institute code must not be null");
        assertNotNull(inst.getCampusLocation(), "Campus location must not be null");

        // Verify auto-created Admin user in users table
        Optional<UserEntity> adminOpt = userRepository.findByEmailIgnoreCase(adminEmail);
        assertTrue(adminOpt.isPresent(), "Admin user should be automatically created in database");
        UserEntity admin = adminOpt.get();
        assertEquals("admin", admin.getRole());
        assertEquals("Dr. Dean " + idSuffix, admin.getName());
        assertEquals(inst.getInstituteCode(), admin.getInstituteCode());
        assertNotNull(admin.getPassword(), "Admin password must not be null");
        assertNotNull(admin.getStatus(), "Status must not be null");

        // 1. Institute Login with Institute Password -> MUST SUCCEED
        LoginRequest instLoginReq = new LoginRequest();
        instLoginReq.setInstituteCode(inst.getInstituteCode());
        instLoginReq.setPassword(institutePass);
        ApiResponse instLoginOk = authService.loginInstitute(instLoginReq);
        assertTrue(instLoginOk.isSuccess(), "Institute login with institute password should succeed");

        // 2. Institute Login with Admin Password -> MUST FAIL
        LoginRequest instLoginBadReq = new LoginRequest();
        instLoginBadReq.setInstituteCode(inst.getInstituteCode());
        instLoginBadReq.setPassword(adminPass);
        ApiResponse instLoginFail = authService.loginInstitute(instLoginBadReq);
        assertFalse(instLoginFail.isSuccess(), "Institute login with admin password must fail");

        // 3. Admin Login with Admin Password -> MUST SUCCEED
        LoginRequest adminLoginReq = new LoginRequest();
        adminLoginReq.setEmail(adminEmail);
        adminLoginReq.setPassword(adminPass);
        ApiResponse adminLoginOk = authService.loginAdmin(adminLoginReq);
        assertTrue(adminLoginOk.isSuccess(), "Admin login with admin password should succeed");

        // 4. Admin Login with Institute Password -> MUST FAIL
        LoginRequest adminLoginBadReq = new LoginRequest();
        adminLoginBadReq.setEmail(adminEmail);
        adminLoginBadReq.setPassword(institutePass);
        ApiResponse adminLoginFail = authService.loginAdmin(adminLoginBadReq);
        assertFalse(adminLoginFail.isSuccess(), "Admin login with institute password must fail");
    }

    @Test
    @DisplayName("Test 2: Student Registration persists 'ram' in name column without NULLs")
    public void testStudentRegistrationPersistsRam() {
        long idSuffix = System.currentTimeMillis() % 100000;
        String email = "ram." + idSuffix + "@student.edu";

        StudentRegisterRequest req = new StudentRegisterRequest();
        req.setFullName("ram");
        req.setEmail(email);
        req.setInstituteCode("INST-2025");
        req.setRollNumber("ROLL-" + idSuffix);
        req.setCourse("Computer Science & Engineering");
        req.setPassword("pass12345");
        req.setPhone("+91 98111 22233");

        ApiResponse res = authService.registerStudent(req);
        assertTrue(res.isSuccess(), "Student registration should succeed: " + res.getMessage());

        // Verify database entry
        Optional<UserEntity> studentOpt = userRepository.findByEmailIgnoreCase(email);
        assertTrue(studentOpt.isPresent(), "Student must be found in database");
        UserEntity student = studentOpt.get();

        // Check columns to ensure NO NULLs and actual 'ram'
        assertEquals("ram", student.getName(), "Name column must be 'ram' and NOT NULL");
        assertEquals("ram", student.getFullName(), "getFullName() must return 'ram'");
        assertEquals("student", student.getRole());
        assertEquals("ROLL-" + idSuffix, student.getRollNumber());
        assertEquals("Computer Science & Engineering", student.getCourse());
        assertEquals("Computer Science & Engineering", student.getClassName());
        assertEquals("Semester 1", student.getSemester());
        assertEquals("+91 98111 22233", student.getPhone());
        assertNotNull(student.getInstituteCode(), "Institute code must not be null");
        assertNotNull(student.getInstituteName(), "Institute name must not be null");
        assertNotNull(student.getGender(), "Gender must not be null");
        assertNotNull(student.getDob(), "DOB must not be null");
        assertNotNull(student.getAddress(), "Address must not be null");
        assertNotNull(student.getFatherName(), "Father/Guardian name must not be null");
        assertNotNull(student.getFatherPhone(), "Father/Guardian phone must not be null");
        assertEquals("Active", student.getStatus(), "Status must be Active");
    }

    @Test
    @DisplayName("Test 3: StudentController createStudent persists real inputs without NULLs")
    public void testStudentControllerCreateStudent() {
        long idSuffix = System.currentTimeMillis() % 100000;
        String email = "stdcontroller." + idSuffix + "@edlearn.edu";
        String instituteCode = "INST-CTRL-" + idSuffix;

        UserEntity admin = new UserEntity();
        admin.setEmail("admin.controller." + idSuffix + "@edlearn.edu");
        admin.setPassword("test-password");
        admin.setRole("admin");
        admin.setName("Controller Test Admin");
        admin.setInstituteCode(instituteCode);
        admin.setInstituteName("Controller Test Institute");
        admin.setStatus("Active");
        admin = userRepository.save(admin);

        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader("Authorization", "Bearer " + portalTokenService.issue(admin));

        UserEntity newStudent = new UserEntity();
        newStudent.setName("ram");
        newStudent.setEmail(email.toUpperCase());
        newStudent.setRollNumber("ROLL-CTRL-" + idSuffix);
        newStudent.setClassName("Information Technology");
        newStudent.setPhone("+91 98222 33344");
        newStudent.setPassword("student-password");

        UserEntity created = studentController.createStudent(request, newStudent);
        assertNotNull(created.getId(), "Created student must have an ID");
        assertEquals("ram", created.getName(), "Controller created student name must be 'ram'");
        assertEquals("student", created.getRole());
        assertEquals("Active", created.getStatus());
        assertNotNull(created.getCourse(), "Course must not be null");
        assertNotNull(created.getSemester(), "Semester must not be null");
        assertNotNull(created.getGender(), "Gender must not be null");
        assertNotNull(created.getDob(), "DOB must not be null");
        assertNotNull(created.getAddress(), "Address must not be null");
        assertNotNull(created.getFatherName(), "Father name must not be null");

        // Verify retrieval from database
        UserEntity retrieved = studentController.getStudent(request, created.getRollNumber());
        assertEquals("ram", retrieved.getName(), "Retrieved student name from database must be 'ram'");
        assertEquals(created.getId(), retrieved.getId(), "Controller retrieval must return the same user record");
        assertNotEquals("student-password", created.getPassword(), "Student password must be hashed before storage");

        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setEmail(email.toUpperCase());
        loginRequest.setPassword("student-password");
        loginRequest.setRole("student");
        ApiResponse login = authService.loginRole(loginRequest);
        assertTrue(login.isSuccess(), "Admin-created student must be able to log in");
        assertEquals(created.getUserId(), ((Map<?, ?>) login.getUser()).get("id"),
                "Student login must resolve to the admin-created user record");
        assertEquals(email, created.getEmail(), "Stored email must be canonicalized");

        UserEntity duplicateStudent = new UserEntity();
        duplicateStudent.setName("Duplicate Student");
        duplicateStudent.setEmail(email.toUpperCase());
        duplicateStudent.setRollNumber("ROLL-DUP-" + idSuffix);
        duplicateStudent.setClassName("Information Technology");
        duplicateStudent.setPassword("student-password");
        assertEquals(409, assertThrows(org.springframework.web.server.ResponseStatusException.class,
                () -> studentController.createStudent(request, duplicateStudent))
                .getStatusCode().value(), "A duplicate email must not create another user record");
    }

    @Test
    @DisplayName("Test 4: Admin-created instructor can log in through the teacher role")
    public void testAdminCreatedInstructorCanLogIn() {
        long idSuffix = System.currentTimeMillis() % 100000;
        String email = "instructor.admin." + idSuffix + "@edlearn.edu";
        String instituteCode = "INST-TEACH-" + idSuffix;
        UserEntity admin = new UserEntity();
        admin.setEmail("admin.instructor." + idSuffix + "@edlearn.edu");
        admin.setPassword("test-password");
        admin.setRole("admin");
        admin.setName("Instructor Test Admin");
        admin.setInstituteCode(instituteCode);
        admin.setInstituteName("Instructor Test Institute");
        admin.setStatus("Active");
        admin = userRepository.save(admin);

        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader("Authorization", "Bearer " + portalTokenService.issue(admin));

        UserEntity newInstructor = new UserEntity();
        newInstructor.setName("Dr. Robert Sharma");
        newInstructor.setEmail(email.toUpperCase());
        newInstructor.setInstructorId("EMP-" + idSuffix);
        newInstructor.setDepartment("Computer Science");
        newInstructor.setDesignation("Associate Professor");
        newInstructor.setPhone("+91 98333 44455");
        newInstructor.setPassword("FacultyPass#2026");

        UserEntity created = instructorController.createInstructor(request, newInstructor);
        assertNotNull(created.getId(), "Created instructor must have a database ID");
        assertEquals("Dr. Robert Sharma", created.getName());
        assertEquals("teacher", created.getRole());
        assertEquals("EMP-" + idSuffix, created.getInstructorId());
        assertEquals("Computer Science", created.getDepartment());
        assertEquals("+91 98333 44455", created.getPhone());
        assertEquals("Active", created.getStatus());
        assertEquals(instituteCode, created.getInstituteCode());
        assertNotEquals("FacultyPass#2026", created.getPassword(), "Instructor password must be hashed before storage");

        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setEmail(email);
        loginRequest.setPassword("FacultyPass#2026");
        loginRequest.setRole("teacher");
        ApiResponse login = authService.loginRole(loginRequest);
        assertTrue(login.isSuccess(), "Admin-created instructor must be able to log in");
        assertEquals(created.getUserId(), ((Map<?, ?>) login.getUser()).get("id"),
                "Instructor login must resolve to the admin-created user record");
        assertEquals(email, created.getEmail(), "Stored email must be canonicalized");
    }
}
