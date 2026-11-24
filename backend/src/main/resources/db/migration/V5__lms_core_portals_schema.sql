-- EduChain LMS: Admin, Instructor, Student Portals & Assignments Schema
-- Version: V5__lms_core_portals_schema.sql

-- 1. Courses Table
CREATE TABLE IF NOT EXISTS edlearn.courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_name VARCHAR(255) NOT NULL,
    course_code VARCHAR(50),
    description TEXT,
    thumbnail_url VARCHAR(1000),
    instructor_id UUID REFERENCES edlearn.users(id) ON DELETE SET NULL,
    institute_code VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Batches Table
CREATE TABLE IF NOT EXISTS edlearn.batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_name VARCHAR(255) NOT NULL,
    course_id UUID NOT NULL REFERENCES edlearn.courses(id) ON DELETE CASCADE,
    start_date VARCHAR(50),
    end_date VARCHAR(50),
    institute_code VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Instructor Profiles Table
CREATE TABLE IF NOT EXISTS edlearn.instructor_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE,
    qualification VARCHAR(255),
    expertise VARCHAR(255),
    experience VARCHAR(100),
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_instructor_profile_user UNIQUE (user_id)
);

-- 4. Student Profiles Table
CREATE TABLE IF NOT EXISTS edlearn.student_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE,
    student_id VARCHAR(100),
    batch_id UUID REFERENCES edlearn.batches(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_student_profile_user UNIQUE (user_id)
);

-- 5. Enrollments Table
CREATE TABLE IF NOT EXISTS edlearn.enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES edlearn.courses(id) ON DELETE CASCADE,
    batch_id UUID REFERENCES edlearn.batches(id) ON DELETE SET NULL,
    enrollment_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'Active',
    CONSTRAINT uq_enrollment_student_batch UNIQUE (student_id, course_id, batch_id)
);

-- 6. Classes Table
CREATE TABLE IF NOT EXISTS edlearn.classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    instructor_id UUID NOT NULL REFERENCES edlearn.users(id) ON DELETE CASCADE,
    course_id UUID REFERENCES edlearn.courses(id) ON DELETE SET NULL,
    batch_id UUID REFERENCES edlearn.batches(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    subject VARCHAR(150),
    description TEXT,
    class_date VARCHAR(50) NOT NULL,
    start_time VARCHAR(50) NOT NULL,
    end_time VARCHAR(50) NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    google_meet_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(1000),
    status VARCHAR(50) DEFAULT 'Upcoming',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Add columns to assignments table if not already present
ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS instructor_id UUID REFERENCES edlearn.users(id) ON DELETE SET NULL;
ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS course_id UUID REFERENCES edlearn.courses(id) ON DELETE SET NULL;
ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS batch_id UUID REFERENCES edlearn.batches(id) ON DELETE SET NULL;
ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS attachment_url VARCHAR(1000);
ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS start_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS maximum_marks INTEGER DEFAULT 100;
ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS allow_resubmission BOOLEAN DEFAULT true;
ALTER TABLE edlearn.assignments ADD COLUMN IF NOT EXISTS allowed_file_types VARCHAR(255) DEFAULT 'PDF, DOC, DOCX, JPG, PNG';

-- 8. Add columns to assignment_submissions table if not already present
ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS submission_file_url VARCHAR(1000);
ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS student_comments TEXT;
ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS marks_obtained NUMERIC(6, 2);
ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS instructor_feedback TEXT;
ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS evaluated_file_url VARCHAR(1000);
ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS evaluated_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE edlearn.assignment_submissions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 9. Add profile_image column alias to users if needed
ALTER TABLE edlearn.users ADD COLUMN IF NOT EXISTS profile_image VARCHAR(1000);
