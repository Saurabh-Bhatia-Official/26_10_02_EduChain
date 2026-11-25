package com.edlearn.backend.config;

import jakarta.annotation.PostConstruct;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class LmsSchemaFixer {

    private final JdbcTemplate jdbcTemplate;

    public LmsSchemaFixer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    public void fixSchema() {
        try {
            // Fix courses
            jdbcTemplate.execute("ALTER TABLE edlearn.courses ADD COLUMN IF NOT EXISTS course_name VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE edlearn.courses ADD COLUMN IF NOT EXISTS course_code VARCHAR(50)");
            jdbcTemplate.execute("ALTER TABLE edlearn.courses ADD COLUMN IF NOT EXISTS description TEXT");
            jdbcTemplate.execute("ALTER TABLE edlearn.courses ADD COLUMN IF NOT EXISTS thumbnail_url VARCHAR(1000)");
            jdbcTemplate.execute("ALTER TABLE edlearn.courses ADD COLUMN IF NOT EXISTS instructor_id UUID");
            jdbcTemplate.execute("ALTER TABLE edlearn.courses ADD COLUMN IF NOT EXISTS institute_code VARCHAR(50)");
            jdbcTemplate.execute("ALTER TABLE edlearn.courses ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP");
            jdbcTemplate.execute("ALTER TABLE edlearn.courses ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP");
            jdbcTemplate.execute("UPDATE edlearn.courses SET course_name = 'Course ' || COALESCE(course_code, id::text) WHERE course_name IS NULL");

            // Fix batches
            jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS edlearn.batches (" +
                    "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), " +
                    "batch_name VARCHAR(255), " +
                    "course_id UUID, " +
                    "start_date VARCHAR(50), " +
                    "end_date VARCHAR(50), " +
                    "institute_code VARCHAR(50), " +
                    "created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP)");

            // Fix classes
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS instructor_id UUID");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS course_id UUID");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS batch_id UUID");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS title VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS subject VARCHAR(150)");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS description TEXT");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS class_date VARCHAR(50)");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS start_time VARCHAR(50)");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS end_time VARCHAR(50)");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS duration_minutes INTEGER DEFAULT 60");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS google_meet_url VARCHAR(500)");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS thumbnail_url VARCHAR(1000)");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'Upcoming'");
            jdbcTemplate.execute("ALTER TABLE edlearn.classes ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP");
            jdbcTemplate.execute("UPDATE edlearn.classes SET class_date = '2026-11-24' WHERE class_date IS NULL");
            jdbcTemplate.execute("UPDATE edlearn.classes SET start_time = '10:00' WHERE start_time IS NULL");
            jdbcTemplate.execute("UPDATE edlearn.classes SET end_time = '11:00' WHERE end_time IS NULL");
            jdbcTemplate.execute("UPDATE edlearn.classes SET google_meet_url = 'https://meet.google.com/abc-defg-hij' WHERE google_meet_url IS NULL");
            jdbcTemplate.execute("UPDATE edlearn.classes SET status = 'Upcoming' WHERE status IS NULL");
            jdbcTemplate.execute("UPDATE edlearn.classes SET title = 'Class Session' WHERE title IS NULL");

            // Clean up invalid foreign keys in classes
            jdbcTemplate.execute("UPDATE edlearn.classes SET instructor_id = NULL WHERE instructor_id IS NOT NULL AND instructor_id NOT IN (SELECT id FROM edlearn.users)");

            // Fix instructor_profiles
            jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS edlearn.instructor_profiles (" +
                    "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), " +
                    "user_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE, " +
                    "qualification VARCHAR(255), " +
                    "expertise VARCHAR(255), " +
                    "experience VARCHAR(100), " +
                    "bio TEXT, " +
                    "created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP)");

            // Fix student_profiles
            jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS edlearn.student_profiles (" +
                    "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), " +
                    "user_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE, " +
                    "student_id VARCHAR(100), " +
                    "batch_id UUID, " +
                    "created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP)");

            // Fix enrollments
            jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS edlearn.enrollments (" +
                    "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), " +
                    "student_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE, " +
                    "course_id UUID NOT NULL, " +
                    "batch_id UUID, " +
                    "enrollment_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, " +
                    "status VARCHAR(50) DEFAULT 'Active')");

            // Fix assignments columns
            jdbcTemplate.execute("ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS instructor_id UUID");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS course_id UUID");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS batch_id UUID");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS attachment_url VARCHAR(1000)");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS start_date TIMESTAMP WITH TIME ZONE");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS maximum_marks INTEGER DEFAULT 100");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS allow_resubmission BOOLEAN DEFAULT true");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS allowed_file_types VARCHAR(255) DEFAULT 'PDF, DOC, DOCX, JPG, PNG'");

            // Fix assignment_submissions columns
            jdbcTemplate.execute("ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS submission_file_url VARCHAR(1000)");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS student_comments TEXT");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS marks_obtained NUMERIC(6, 2)");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS instructor_feedback TEXT");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS evaluated_file_url VARCHAR(1000)");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS evaluated_at TIMESTAMP WITH TIME ZONE");
            jdbcTemplate.execute("ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP");

            System.out.println(">>> LmsSchemaFixer: All database tables & columns successfully verified and updated! <<<");
        } catch (Exception e) {
            System.err.println("LmsSchemaFixer warning: " + e.getMessage());
        }
    }
}
