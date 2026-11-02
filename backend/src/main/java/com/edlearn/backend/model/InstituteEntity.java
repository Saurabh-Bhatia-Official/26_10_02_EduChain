package com.edlearn.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "institutes")
public class InstituteEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(name = "institute_code", unique = true, nullable = false)
    private String instituteCode;

    @Column(name = "institute_name", nullable = false)
    private String instituteName;

    @Column(name = "institute_type")
    private String instituteType;

    @Column(name = "admin_name")
    private String adminName;

    @Column(nullable = false)
    private String email;

    @Column(name = "institute_password")
    private String institutePassword;

    @Column(name = "admin_password")
    private String adminPassword;

    @Column(name = "password")
    private String password;

    private String phone;
    private String address;

    @Column(name = "campus_location")
    private String campusLocation;

    private String accreditation;

    @Column(name = "established_year")
    private String establishedYear;

    @Column(name = "is_verified")
    private Boolean isVerified = true;

    @Column(name = "verification_status")
    private String verificationStatus = "Officially Verified";

    @Column(name = "verification_id")
    private String verificationId;

    @Column(name = "verification_date")
    private String verificationDate = "Academic Session 2025–2026";

    @Column(name = "student_count")
    private Integer studentCount = 0;

    @Column(name = "faculty_count")
    private Integer facultyCount = 0;

    @Column(name = "department_count")
    private Integer departmentCount = 1;

    @Column(name = "active_semester")
    private String activeSemester = "Academic Year 2025–2026";

    @Column(name = "logo_url")
    private String logoUrl;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public InstituteEntity() {}

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
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

    public String getInstituteType() {
        return instituteType;
    }

    public void setInstituteType(String instituteType) {
        this.instituteType = instituteType;
    }

    public String getAdminName() {
        return adminName;
    }

    public void setAdminName(String adminName) {
        this.adminName = adminName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getInstitutePassword() {
        return (institutePassword != null && !institutePassword.isBlank()) ? institutePassword : password;
    }

    public void setInstitutePassword(String institutePassword) {
        this.institutePassword = institutePassword;
        this.password = institutePassword;
    }

    public String getAdminPassword() {
        return adminPassword;
    }

    public void setAdminPassword(String adminPassword) {
        this.adminPassword = adminPassword;
    }

    public String getPassword() {
        return getInstitutePassword();
    }

    public void setPassword(String password) {
        this.password = password;
        if (this.institutePassword == null || this.institutePassword.isBlank()) {
            this.institutePassword = password;
        }
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCampusLocation() {
        return campusLocation;
    }

    public void setCampusLocation(String campusLocation) {
        this.campusLocation = campusLocation;
    }

    public String getAccreditation() {
        return accreditation;
    }

    public void setAccreditation(String accreditation) {
        this.accreditation = accreditation;
    }

    public String getEstablishedYear() {
        return establishedYear;
    }

    public void setEstablishedYear(String establishedYear) {
        this.establishedYear = establishedYear;
    }

    public Boolean getVerified() {
        return isVerified;
    }

    public void setVerified(Boolean verified) {
        isVerified = verified;
    }

    public String getVerificationStatus() {
        return verificationStatus;
    }

    public void setVerificationStatus(String verificationStatus) {
        this.verificationStatus = verificationStatus;
    }

    public String getVerificationId() {
        return verificationId;
    }

    public void setVerificationId(String verificationId) {
        this.verificationId = verificationId;
    }

    public String getVerificationDate() {
        return verificationDate;
    }

    public void setVerificationDate(String verificationDate) {
        this.verificationDate = verificationDate;
    }

    public Integer getStudentCount() {
        return studentCount;
    }

    public void setStudentCount(Integer studentCount) {
        this.studentCount = studentCount;
    }

    public Integer getFacultyCount() {
        return facultyCount;
    }

    public void setFacultyCount(Integer facultyCount) {
        this.facultyCount = facultyCount;
    }

    public Integer getDepartmentCount() {
        return departmentCount;
    }

    public void setDepartmentCount(Integer departmentCount) {
        this.departmentCount = departmentCount;
    }

    public String getActiveSemester() {
        return activeSemester;
    }

    public void setActiveSemester(String activeSemester) {
        this.activeSemester = activeSemester;
    }

    public String getLogoUrl() {
        return logoUrl;
    }

    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
