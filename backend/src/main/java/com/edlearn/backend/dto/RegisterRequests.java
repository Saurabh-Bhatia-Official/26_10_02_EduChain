package com.edlearn.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;

public class RegisterRequests {

    public static class InstituteRegisterRequest {
        @JsonAlias({"institute_name", "name"})
        private String instituteName;

        @JsonAlias({"institute_type", "type"})
        private String instituteType;

        @JsonAlias({"admin_name", "fullName", "name", "contactPerson"})
        private String adminName;

        @JsonAlias({"admin_email", "adminMail"})
        private String adminEmail;

        @JsonAlias({"institute_email", "email", "officialEmail"})
        private String instituteEmail;

        @JsonAlias({"institute_password", "instPassword"})
        private String institutePassword;

        @JsonAlias({"admin_password", "masterPassword"})
        private String adminPassword;

        private String password; // Fallback

        @JsonAlias({"phoneNumber", "phone_number", "contactNumber", "mobile"})
        private String phone;

        @JsonAlias({"campusLocation", "campus_location", "location"})
        private String address;

        private String city;
        private String state;

        @JsonAlias({"established_year", "estYear", "year"})
        private String establishedYear;

        @JsonAlias({"accreditation_details", "accreditationStatus"})
        private String accreditation;

        public String getInstituteName() { return instituteName; }
        public void setInstituteName(String instituteName) { this.instituteName = instituteName; }

        public String getInstituteType() { return instituteType; }
        public void setInstituteType(String instituteType) { this.instituteType = instituteType; }

        public String getAdminName() { 
            if (adminName != null && !adminName.isBlank()) return adminName;
            return "Institute Administrator";
        }
        public void setAdminName(String adminName) { this.adminName = adminName; }

        public String getAdminEmail() { return adminEmail; }
        public void setAdminEmail(String adminEmail) { this.adminEmail = adminEmail; }

        public String getInstituteEmail() { return instituteEmail; }
        public void setInstituteEmail(String instituteEmail) { this.instituteEmail = instituteEmail; }

        public String getInstitutePassword() { 
            if (institutePassword != null && !institutePassword.isBlank()) return institutePassword;
            return password;
        }
        public void setInstitutePassword(String institutePassword) { this.institutePassword = institutePassword; }

        public String getAdminPassword() { return adminPassword; }
        public void setAdminPassword(String adminPassword) { this.adminPassword = adminPassword; }

        public String getPassword() { return password != null ? password : getInstitutePassword(); }
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

        public String getAccreditation() { return accreditation; }
        public void setAccreditation(String accreditation) { this.accreditation = accreditation; }
    }

    public static class StudentRegisterRequest {
        @JsonAlias({"name", "studentName", "userName"})
        private String fullName;

        private String email;
        private String password;

        @JsonAlias({"roll_number", "rollNo", "roll"})
        private String rollNumber;

        @JsonAlias({"class_name", "className", "studentClass"})
        private String className;

        private String course;

        @JsonAlias({"institute_code", "instCode"})
        private String instituteCode;

        @JsonAlias({"phoneNumber", "phone_number", "contactNumber", "mobile"})
        private String phone;

        private String semester;
        private String gender;
        private String dob;
        private String address;

        @JsonAlias({"parentName", "parent_name", "guardianName"})
        private String fatherName;

        @JsonAlias({"parentPhone", "parent_phone", "guardianPhone"})
        private String fatherPhone;

        private String motherName;

        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }

        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }

        public String getRollNumber() { return rollNumber; }
        public void setRollNumber(String rollNumber) { this.rollNumber = rollNumber; }

        public String getClassName() { return className; }
        public void setClassName(String className) { this.className = className; }

        public String getCourse() { return course; }
        public void setCourse(String course) { this.course = course; }

        public String getInstituteCode() { return instituteCode; }
        public void setInstituteCode(String instituteCode) { this.instituteCode = instituteCode; }

        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }

        public String getSemester() { return semester; }
        public void setSemester(String semester) { this.semester = semester; }

        public String getGender() { return gender; }
        public void setGender(String gender) { this.gender = gender; }

        public String getDob() { return dob; }
        public void setDob(String dob) { this.dob = dob; }

        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }

        public String getFatherName() { return fatherName; }
        public void setFatherName(String fatherName) { this.fatherName = fatherName; }

        public String getFatherPhone() { return fatherPhone; }
        public void setFatherPhone(String fatherPhone) { this.fatherPhone = fatherPhone; }

        public String getMotherName() { return motherName; }
        public void setMotherName(String motherName) { this.motherName = motherName; }
    }

    public static class TeacherRegisterRequest {
        @JsonAlias({"name", "teacherName", "instructorName", "userName"})
        private String fullName;

        private String email;
        private String password;

        @JsonAlias({"instructorId", "instructor_id", "empId", "employee_id"})
        private String employeeId;

        private String department;

        @JsonAlias({"institute_code", "instCode"})
        private String instituteCode;

        @JsonAlias({"phoneNumber", "phone_number", "contactNumber", "mobile"})
        private String phone;

        private String designation;
        private String qualification;
        private String experience;
        private String address;

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

        public String getDesignation() { return designation; }
        public void setDesignation(String designation) { this.designation = designation; }

        public String getQualification() { return qualification; }
        public void setQualification(String qualification) { this.qualification = qualification; }

        public String getExperience() { return experience; }
        public void setExperience(String experience) { this.experience = experience; }

        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }
    }
}
