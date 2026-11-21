package com.edlearn.backend;

import org.junit.jupiter.api.Test;
import java.sql.*;
import java.util.Properties;

public class DatabaseInspectionTest {

    @Test
    public void checkStudentsAndFixAnnouncements() throws Exception {
        String url = "jdbc:postgresql://ep-dark-lake-b3emihul-pooler.c-4.ap-southeast-1.aws.neon.tech:5432/edlearndb?sslmode=require&currentSchema=edlearn&socketFactory=com.edlearn.backend.config.NeonSocketFactory";
        Properties props = new Properties();
        props.setProperty("user", "neondb_owner");
        props.setProperty("password", "npg_Vfwy7MXd2QuA");

        try (Connection conn = DriverManager.getConnection(url, props);
             Statement stmt = conn.createStatement()) {

            System.out.println("Dropping NOT NULL on legacy announcement columns...");
            stmt.execute("ALTER TABLE edlearn.announcements ALTER COLUMN message DROP NOT NULL");
            stmt.execute("ALTER TABLE edlearn.announcements ALTER COLUMN category DROP NOT NULL");
            stmt.execute("ALTER TABLE edlearn.announcements ALTER COLUMN status DROP NOT NULL");
            stmt.execute("ALTER TABLE edlearn.announcements ALTER COLUMN target_audience DROP NOT NULL");
            stmt.execute("ALTER TABLE edlearn.announcements ALTER COLUMN publish_date DROP NOT NULL");
            stmt.execute("ALTER TABLE edlearn.announcements ALTER COLUMN created_by DROP NOT NULL");
            stmt.execute("ALTER TABLE edlearn.announcements ALTER COLUMN updated_at DROP NOT NULL");
            stmt.execute("ALTER TABLE edlearn.announcements ALTER COLUMN institute_code DROP NOT NULL");

            System.out.println("Upserting rahul@institute.com into edlearn.users...");
            stmt.execute("INSERT INTO edlearn.users (id, email, password, name, role, status, institute_code) " +
                    "VALUES ('b0000000-0000-0000-0000-000000000077', 'rahul@institute.com', 'password123', 'Rahul Sharma', 'student', 'Active', 'INST-2025') " +
                    "ON CONFLICT (email) DO UPDATE SET password = 'password123', status = 'Active', institute_code = 'INST-2025'");
            try (ResultSet rs = stmt.executeQuery("SELECT id, email, role, status, institute_code, password, name FROM edlearn.users WHERE lower(role) = 'student'")) {
                while (rs.next()) {
                    System.out.printf("Student: id=%s | email=%s | role=%s | status=%s | institute=%s | pass=%s | name=%s%n",
                            rs.getString(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5), rs.getString(6), rs.getString(7));
                }
            }
        }
    }

    @Test
    public void fixAnnouncementsTable() throws Exception {
        String url = "jdbc:postgresql://ep-dark-lake-b3emihul-pooler.c-4.ap-southeast-1.aws.neon.tech:5432/edlearndb?sslmode=require&currentSchema=edlearn&socketFactory=com.edlearn.backend.config.NeonSocketFactory";
        Properties props = new Properties();
        props.setProperty("user", "neondb_owner");
        props.setProperty("password", "npg_Vfwy7MXd2QuA");

        try (Connection conn = DriverManager.getConnection(url, props);
             Statement stmt = conn.createStatement()) {

            System.out.println("Inspecting edlearn.announcements columns...");
            try (ResultSet rs = stmt.executeQuery(
                    "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_schema='edlearn' AND table_name='announcements'")) {
                while (rs.next()) {
                    System.out.printf("Column: %s (%s, nullable=%s)%n", rs.getString(1), rs.getString(2), rs.getString(3));
                }
            }

            System.out.println("Adding columns to edlearn.announcements if missing...");
            stmt.execute("ALTER TABLE edlearn.announcements ADD COLUMN IF NOT EXISTS announcement_date DATE DEFAULT CURRENT_DATE");
            stmt.execute("ALTER TABLE edlearn.announcements ADD COLUMN IF NOT EXISTS audience VARCHAR(20) DEFAULT 'BOTH'");
            stmt.execute("ALTER TABLE edlearn.announcements ADD COLUMN IF NOT EXISTS published BOOLEAN DEFAULT true");
            stmt.execute("ALTER TABLE edlearn.announcements ADD COLUMN IF NOT EXISTS publisher_id UUID");
            stmt.execute("ALTER TABLE edlearn.announcements ADD COLUMN IF NOT EXISTS expires_at DATE");
            stmt.execute("ALTER TABLE edlearn.announcements ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
            stmt.execute("ALTER TABLE edlearn.announcements ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP");

            // Backfill nulls
            System.out.println("Backfilling null values in edlearn.announcements...");
            String adminId = "b0000000-0000-0000-0000-000000000002";
            try (ResultSet rs = stmt.executeQuery("SELECT id FROM edlearn.users WHERE lower(role) = 'admin' LIMIT 1")) {
                if (rs.next()) adminId = rs.getString(1);
            }
            stmt.execute("UPDATE edlearn.announcements SET announcement_date = CURRENT_DATE WHERE announcement_date IS NULL");
            stmt.execute("UPDATE edlearn.announcements SET audience = 'BOTH' WHERE audience IS NULL");
            stmt.execute("UPDATE edlearn.announcements SET published = true WHERE published IS NULL");
            stmt.execute("UPDATE edlearn.announcements SET publisher_id = '" + adminId + "'::uuid WHERE publisher_id IS NULL");

            // Alter NOT NULL
            stmt.execute("ALTER TABLE edlearn.announcements ALTER COLUMN announcement_date SET NOT NULL");
            stmt.execute("ALTER TABLE edlearn.announcements ALTER COLUMN audience SET NOT NULL");
            stmt.execute("ALTER TABLE edlearn.announcements ALTER COLUMN published SET NOT NULL");
            stmt.execute("ALTER TABLE edlearn.announcements ALTER COLUMN publisher_id SET NOT NULL");

            // Seed sample announcement if empty
            int count = 0;
            try (ResultSet rs = stmt.executeQuery("SELECT count(*) FROM edlearn.announcements")) {
                if (rs.next()) count = rs.getInt(1);
            }
            System.out.println("Current announcements count: " + count);
            if (count == 0) {
                System.out.println("Seeding default announcement...");
                stmt.execute("INSERT INTO edlearn.announcements (id, title, description, audience, announcement_date, expires_at, published, publisher_id, created_at, updated_at) " +
                        "VALUES ('20000000-0000-0000-0000-000000000001', 'Academic Session 2025–2026 Commencement', 'Welcome to the new academic session. All lectures, examinations, and leave requests are managed via the EduChain Portal.', 'BOTH', CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', true, '" + adminId + "'::uuid, NOW(), NOW())");
            }

            System.out.println("Checking edlearn.announcements rows:");
            try (ResultSet rs = stmt.executeQuery("SELECT id, title, audience, published, publisher_id, announcement_date FROM edlearn.announcements")) {
                while (rs.next()) {
                    System.out.printf("Announcement: %s | %s | %s | published=%b | publisher=%s | date=%s%n",
                            rs.getString(1), rs.getString(2), rs.getString(3), rs.getBoolean(4), rs.getString(5), rs.getString(6));
                }
            }
        }
    }

    @Test
    public void seedExamIfEmpty() throws Exception {
        String url = "jdbc:postgresql://ep-dark-lake-b3emihul-pooler.c-4.ap-southeast-1.aws.neon.tech:5432/edlearndb?sslmode=require&currentSchema=edlearn&socketFactory=com.edlearn.backend.config.NeonSocketFactory";
        Properties props = new Properties();
        props.setProperty("user", "neondb_owner");
        props.setProperty("password", "npg_Vfwy7MXd2QuA");

        try (Connection conn = DriverManager.getConnection(url, props);
             Statement stmt = conn.createStatement()) {
            
            System.out.println("Adding results_released column to exams if missing...");
            stmt.execute("ALTER TABLE edlearn.exams ADD COLUMN IF NOT EXISTS results_released BOOLEAN DEFAULT false");

            System.out.println("Checking count in exams...");
            int examCount = 0;
            try (ResultSet rs = stmt.executeQuery("SELECT count(*) FROM edlearn.exams")) {
                if (rs.next()) examCount = rs.getInt(1);
            }
            System.out.println("Current exams count: " + examCount);

            if (examCount == 0) {
                System.out.println("Seeding default examination into edlearn.exams...");
                // Get admin user ID for created_by
                String adminId = null;
                try (ResultSet rs = stmt.executeQuery("SELECT id FROM edlearn.users WHERE lower(role) = 'admin' LIMIT 1")) {
                    if (rs.next()) adminId = rs.getString(1);
                }
                if (adminId == null) adminId = "b0000000-0000-0000-0000-000000000002";

                // Read questions from examinations
                String questionsJson = null;
                try (ResultSet rs = stmt.executeQuery("SELECT questions_json FROM edlearn.examinations LIMIT 1")) {
                    if (rs.next()) questionsJson = rs.getString(1);
                }
                if (questionsJson == null) {
                    questionsJson = "[{\"id\":1,\"text\":\"What is the primary role of the virtual DOM in React?\",\"options\":{\"A\":\"Directly update browser real DOM\",\"B\":\"Compute minimum diffs before updating real DOM efficiently\",\"C\":\"Store user session cookies\",\"D\":\"Handle server database queries\"},\"correctAnswer\":\"B\"}]";
                }

                String insertSql = "INSERT INTO edlearn.exams (id, title, course_code, course_name, class_name, section_name, institute_code, duration_minutes, total_marks, exam_date, questions_json, status, created_by, created_at, updated_at, results_released) " +
                        "VALUES ('10000000-0000-0000-0000-000000000001', 'DBMS & Full Stack Web Development Mid-Term Examination', 'CS-301', 'Database Management & Web Applications', 'BCA - Sem 3', 'Section A', 'INST-2025', 60, 100, NOW() + INTERVAL '1 day', ?, 'Published', ?::uuid, NOW(), NOW(), false)";
                
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setString(1, questionsJson);
                    ps.setString(2, adminId);
                    ps.executeUpdate();
                    System.out.println("Seeded examination successfully!");
                }
            }

            try (ResultSet rs = stmt.executeQuery("SELECT id, title, course_code, duration_minutes, total_marks, status, results_released FROM edlearn.exams")) {
                while (rs.next()) {
                    System.out.printf("Exam: %s | %s | %s | %d mins | %d marks | %s | released=%b%n",
                            rs.getString(1), rs.getString(2), rs.getString(3), rs.getInt(4), rs.getInt(5), rs.getString(6), rs.getBoolean(7));
                }
            }
        }
    }
}
