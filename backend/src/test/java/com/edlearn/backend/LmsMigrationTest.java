package com.edlearn.backend;

import org.junit.jupiter.api.Test;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Properties;

public class LmsMigrationTest {

    private Connection getDbConnection() throws Exception {
        String url = "jdbc:postgresql://ep-dark-lake-b3emihul-pooler.c-4.ap-southeast-1.aws.neon.tech:5432/edlearndb?sslmode=require&currentSchema=edlearn&socketFactory=com.edlearn.backend.config.NeonSocketFactory";
        Properties props = new Properties();
        props.setProperty("user", "neondb_owner");
        props.setProperty("password", "npg_Vfwy7MXd2QuA");
        return DriverManager.getConnection(url, props);
    }

    @Test
    public void executeLmsSchemaMigration() throws Exception {
        try (Connection conn = getDbConnection();
             Statement stmt = conn.createStatement()) {

            System.out.println("Beginning LMS schema migration on schema 'edlearn'...");

            // 1. Classrooms
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS edlearn.classrooms (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    name VARCHAR(255) NOT NULL,
                    section VARCHAR(100),
                    subject VARCHAR(150),
                    room VARCHAR(100),
                    description TEXT,
                    invitation_code VARCHAR(20) UNIQUE NOT NULL,
                    banner_url VARCHAR(1000),
                    theme_color VARCHAR(30) DEFAULT '#1967d2',
                    is_public BOOLEAN DEFAULT false,
                    requires_approval BOOLEAN DEFAULT false,
                    is_archived BOOLEAN DEFAULT false,
                    creator_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE,
                    institute_code VARCHAR(50),
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                );
            """);
            System.out.println("Table edlearn.classrooms created or verified.");

            // 2. Classroom Members
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS edlearn.classroom_members (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    classroom_id UUID NOT NULL REFERENCES edlearn.classrooms(id) ON DELETE CASCADE,
                    user_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE,
                    role VARCHAR(30) NOT NULL,
                    status VARCHAR(30) DEFAULT 'ACTIVE',
                    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                    CONSTRAINT uq_classroom_member UNIQUE (classroom_id, user_id)
                );
            """);
            System.out.println("Table edlearn.classroom_members created or verified.");

            // 3. Assignments
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS edlearn.assignments (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    classroom_id UUID NOT NULL REFERENCES edlearn.classrooms(id) ON DELETE CASCADE,
                    title VARCHAR(255) NOT NULL,
                    instructions TEXT,
                    points_possible INTEGER DEFAULT 100,
                    due_date TIMESTAMP WITH TIME ZONE,
                    topic VARCHAR(100) DEFAULT 'General',
                    allow_late_submissions BOOLEAN DEFAULT true,
                    status VARCHAR(30) DEFAULT 'PUBLISHED',
                    created_by UUID NOT NULL REFERENCES edlearn.users(id),
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                );
            """);
            System.out.println("Table edlearn.assignments created or verified.");

            // 4. Assignment Submissions
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS edlearn.assignment_submissions (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    assignment_id UUID NOT NULL REFERENCES edlearn.assignments(id) ON DELETE CASCADE,
                    student_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE,
                    submission_text TEXT,
                    status VARCHAR(30) DEFAULT 'TURNED_IN',
                    version_number INTEGER DEFAULT 1,
                    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                    CONSTRAINT uq_assignment_submission UNIQUE (assignment_id, student_id)
                );
            """);
            System.out.println("Table edlearn.assignment_submissions created or verified.");

            // 5. Assignment Attachments
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS edlearn.assignment_attachments (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    assignment_id UUID REFERENCES edlearn.assignments(id) ON DELETE CASCADE,
                    submission_id UUID REFERENCES edlearn.assignment_submissions(id) ON DELETE CASCADE,
                    file_name VARCHAR(255) NOT NULL,
                    file_url VARCHAR(1000) NOT NULL,
                    file_type VARCHAR(100),
                    file_size BIGINT,
                    cloudinary_public_id VARCHAR(255),
                    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                );
            """);
            System.out.println("Table edlearn.assignment_attachments created or verified.");

            // 6. Grades
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS edlearn.grades (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    submission_id UUID NOT NULL REFERENCES edlearn.assignment_submissions(id) ON DELETE CASCADE CONSTRAINT uq_grade_submission UNIQUE,
                    score NUMERIC(6, 2) NOT NULL,
                    feedback TEXT,
                    graded_by UUID NOT NULL REFERENCES edlearn.users(id),
                    graded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                    is_returned BOOLEAN DEFAULT false
                );
            """);
            System.out.println("Table edlearn.grades created or verified.");

            // 7. Live Classes (Google Meet)
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS edlearn.live_classes (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    classroom_id UUID NOT NULL REFERENCES edlearn.classrooms(id) ON DELETE CASCADE,
                    title VARCHAR(255) NOT NULL,
                    description TEXT,
                    meet_link VARCHAR(500) NOT NULL,
                    calendar_event_id VARCHAR(255),
                    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
                    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
                    host_teacher_id UUID NOT NULL REFERENCES edlearn.users(id),
                    status VARCHAR(30) DEFAULT 'SCHEDULED',
                    recording_url VARCHAR(1000),
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                );
            """);
            System.out.println("Table edlearn.live_classes created or verified.");

            // 8. Attendance
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS edlearn.attendance (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    live_class_id UUID NOT NULL REFERENCES edlearn.live_classes(id) ON DELETE CASCADE,
                    user_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE,
                    status VARCHAR(30) DEFAULT 'PRESENT',
                    join_time TIMESTAMP WITH TIME ZONE,
                    leave_time TIMESTAMP WITH TIME ZONE,
                    duration_minutes INTEGER DEFAULT 0,
                    CONSTRAINT uq_live_class_attendance UNIQUE (live_class_id, user_id)
                );
            """);
            System.out.println("Table edlearn.attendance created or verified.");

            // 9. Comments / Discussions
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS edlearn.comments (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    classroom_id UUID NOT NULL REFERENCES edlearn.classrooms(id) ON DELETE CASCADE,
                    parent_id UUID REFERENCES edlearn.comments(id) ON DELETE CASCADE,
                    author_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE,
                    target_type VARCHAR(30) NOT NULL,
                    target_id UUID,
                    content TEXT NOT NULL,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                );
            """);
            System.out.println("Table edlearn.comments created or verified.");

            // 10. User OAuth Tokens
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS edlearn.user_oauth_tokens (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    user_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE CONSTRAINT uq_user_oauth UNIQUE,
                    provider VARCHAR(50) NOT NULL DEFAULT 'google',
                    access_token TEXT,
                    refresh_token TEXT,
                    token_expiry TIMESTAMP WITH TIME ZONE,
                    scope TEXT,
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                );
            """);
            System.out.println("Table edlearn.user_oauth_tokens created or verified.");

            // Verify tables exist in edlearn schema
            try (ResultSet rs = stmt.executeQuery(
                    "SELECT table_name FROM information_schema.tables WHERE table_schema='edlearn' ORDER BY table_name")) {
                System.out.println("All existing tables in edlearn schema:");
                while (rs.next()) {
                    System.out.println(" - " + rs.getString(1));
                }
            }
        }
    }
}
