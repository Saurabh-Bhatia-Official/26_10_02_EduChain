package com.edlearn.backend.dto;

import java.util.Map;

public class RegisterRequests {

    public static class InstituteRegisterRequest {
        private String instituteName;
        private String instituteType;
        private String adminName;
        private String adminEmail;
        private String instituteEmail;
        private String institutePassword;
        private String adminPassword;
        private String password; // Fallback
        private String phone;
        private String address;
        private String city;
        private String state;
        private String establishedYear;

        public String getInstituteName() { return instituteName; }
        public void setInstituteName(String instituteName) { this.instituteName = instituteName; }

        public String getInstituteType() { return instituteType; }
        public void setInstituteType(String instituteType) { this.instituteType = instituteType; }

        public String getAdminName() { return adminName; }
        public void setAdminName(String adminName) { this.adminName = adminName; }

        public String getAdminEmail() { return adminEmail; }
        public void setAdminEmail(String adminEmail) { this.adminEmail = adminEmail; }

        public String getInstituteEmail() { return instituteEmail; }
        public void setInstituteEmail(String instituteEmail) { this.instituteEmail = instituteEmail; }

        public String getInstitutePassword() { 
            return (institutePassword != null && !institutePassword.isBlank()) ? institutePassword : password; 
        }
        public void setInstitutePassword(String institutePassword) { this.institutePassword = institutePassword; }

        public String getAdminPassword() { return adminPassword; }
        public void setAdminPassword(String adminPassword) { this.adminPassword = adminPassword; }

        public String getPassword() { return password != null ? password : institutePassword; }
        public void setPassword(String password) { this.password = password; }

        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }

        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }

        public String getCity() { return city; }
        public void setCity(String city) { this.city = city; }

        public String getState() { return state; }
        public void setState(String state) { this.state = state; }

        public String getEstablishedYear() { return establishedYear; }
        public void setEstablishedYear(String establishedYear) { this.establishedYear = establishedYear; }
    }

    public static class StudentRegisterRequest {
        private String fullName;
        private String email;
        private String password;
        private String rollNumber;
        private String course;
        private String instituteCode;
        private String phone;

        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }

        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }

        public String getRollNumber() { return rollNumber; }
        public void setRollNumber(String rollNumber) { this.rollNumber = rollNumber; }

        public String getCourse() { return course; }
        public void setCourse(String course) { this.course = course; }

        public String getInstituteCode() { return instituteCode; }
        public void setInstituteCode(String instituteCode) { this.instituteCode = instituteCode; }

        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
    }

    public static class TeacherRegisterRequest {
        private String fullName;
        private String email;
        private String password;
        private String employeeId;
        private String department;
        private String instituteCode;
        private String phone;

        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }

        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }

        public String getEmployeeId() { return employeeId; }
        public void setEmployeeId(String employeeId) { this.employeeId = employeeId; }

        public String getDepartment() { return department; }
        public void setDepartment(String department) { this.department = department; }

        public String getInstituteCode() { return instituteCode; }
        public void setInstituteCode(String instituteCode) { this.instituteCode = instituteCode; }

        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
    }
}
