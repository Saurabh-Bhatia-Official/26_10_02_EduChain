package com.edlearn.backend.model;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "users")
public class UserEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(name = "user_id", unique = true)
    private String userId;

    @Column(nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String role; // student, teacher, admin, institute

    @JsonAlias({"fullName", "full_name", "userName", "studentName", "adminName", "teacherName"})
    @Column(nullable = false)
    private String name;

    @Column(name = "institute_code")
    private String instituteCode;

    @Column(name = "institute_name")
    private String instituteName;

    @JsonAlias({"phoneNumber", "phone_number", "contactNumber", "mobile"})
    private String phone;

    @Column(name = "avatar_url")
    private String avatarUrl;

    private String status = "Active";

    // Student fields
    @JsonAlias({"roll_number", "rollNo", "roll"})
    @Column(name = "roll_number")
    private String rollNumber;

    @JsonAlias({"class_name", "studentClass", "class"})
    @Column(name = "class_name")
    private String className;

    private String course;
    private String semester;
    private String gender;
    private String dob;

    @JsonAlias({"parentName", "parent_name", "guardianName"})
    @Column(name = "father_name")
    private String fatherName;

    @JsonAlias({"parentPhone", "parent_phone", "guardianPhone"})
    @Column(name = "father_phone")
    private String fatherPhone;

    @Column(name = "father_email")
    private String fatherEmail;

    @Column(name = "mother_name")
    private String motherName;

    @Column(name = "mother_phone")
    private String motherPhone;

    @Column(name = "mother_email")
    private String motherEmail;

    private String address;

    // Teacher fields
    @JsonAlias({"employeeId", "employee_id", "empId", "teacherId"})
    @Column(name = "instructor_id")
    private String instructorId;

    private String designation;
    private String department;

    @Column(name = "joining_date")
    private String joiningDate;

    private String qualification;
    private String experience;

    @Column(length = 2000)
    private String about;

    // Admin fields
    private String title;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public UserEntity() {}

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    // Full name alias methods
    public String getFullName() {
        return name;
    }

    public void setFullName(String fullName) {
        if (fullName != null && !fullName.isBlank()) {
            this.name = fullName.trim();
        }
    }

    public void setUserName(String userName) {
        if (userName != null && !userName.isBlank()) {
            this.name = userName.trim();
        }
    }

    public String getInstituteCode() {
        return instituteCode;
    }

    public void setInstituteCode(String instituteCode) {
        this.instituteCode = instituteCode;
    }

    public String getInstituteName() {
        return instituteName;
    }

    public void setInstituteName(String instituteName) {
        this.instituteName = instituteName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setPhoneNumber(String phoneNumber) {
        if (phoneNumber != null && !phoneNumber.isBlank()) {
            this.phone = phoneNumber.trim();
        }
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getStatus() {
        return status != null && !status.isBlank() ? status : "Active";
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRollNumber() {
        return rollNumber;
    }

    public void setRollNumber(String rollNumber) {
        this.rollNumber = rollNumber;
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public void setStudentClass(String studentClass) {
        if (studentClass != null && !studentClass.isBlank()) {
            this.className = studentClass.trim();
        }
    }

    public String getCourse() {
        return course;
    }

    public void setCourse(String course) {
        this.course = course;
    }

    public String getSemester() {
        return semester;
    }

    public void setSemester(String semester) {
        this.semester = semester;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getDob() {
        return dob;
    }

    public void setDob(String dob) {
        this.dob = dob;
    }

    public String getFatherName() {
        return fatherName;
    }

    public void setFatherName(String fatherName) {
        this.fatherName = fatherName;
    }

    public void setParentName(String parentName) {
        if (parentName != null && !parentName.isBlank()) {
            this.fatherName = parentName.trim();
        }
    }

    public String getFatherPhone() {
        return fatherPhone;
    }

    public void setFatherPhone(String fatherPhone) {
        this.fatherPhone = fatherPhone;
    }

    public void setParentPhone(String parentPhone) {
        if (parentPhone != null && !parentPhone.isBlank()) {
            this.fatherPhone = parentPhone.trim();
        }
    }

    public String getFatherEmail() {
        return fatherEmail;
    }

    public void setFatherEmail(String fatherEmail) {
        this.fatherEmail = fatherEmail;
    }

    public String getMotherName() {
        return motherName;
    }

    public void setMotherName(String motherName) {
        this.motherName = motherName;
    }

    public String getMotherPhone() {
        return motherPhone;
    }

    public void setMotherPhone(String motherPhone) {
        this.motherPhone = motherPhone;
    }

    public String getMotherEmail() {
        return motherEmail;
    }

    public void setMotherEmail(String motherEmail) {
        this.motherEmail = motherEmail;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getInstructorId() {
        return instructorId;
    }

    public void setInstructorId(String instructorId) {
        this.instructorId = instructorId;
    }

    public void setEmployeeId(String employeeId) {
        if (employeeId != null && !employeeId.isBlank()) {
            this.instructorId = employeeId.trim();
        }
    }

    public String getDesignation() {
        return designation;
    }

    public void setDesignation(String designation) {
        this.designation = designation;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getJoiningDate() {
        return joiningDate;
    }

    public void setJoiningDate(String joiningDate) {
        this.joiningDate = joiningDate;
    }

    public String getQualification() {
        return qualification;
    }

    public void setQualification(String qualification) {
        this.qualification = qualification;
    }

    public String getExperience() {
        return experience;
    }

    public void setExperience(String experience) {
        this.experience = experience;
    }

    public String getAbout() {
        return about;
    }

    public void setAbout(String about) {
        this.about = about;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
