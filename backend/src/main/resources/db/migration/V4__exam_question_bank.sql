-- Institute-scoped question bank. ExamEntity.questions_json remains the immutable exam snapshot.
CREATE TABLE IF NOT EXISTS edlearn.exam_question_bank (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institute_code VARCHAR(50) NOT NULL,
    created_by UUID NOT NULL REFERENCES edlearn.users(id),
    question_text TEXT NOT NULL,
    question_type VARCHAR(40) NOT NULL,
    subject VARCHAR(150),
    class_name VARCHAR(150),
    chapter VARCHAR(150),
    topic VARCHAR(150),
    difficulty VARCHAR(30) NOT NULL DEFAULT 'MEDIUM',
    marks INTEGER NOT NULL CHECK (marks > 0),
    negative_marks DOUBLE PRECISION NOT NULL DEFAULT 0 CHECK (negative_marks >= 0),
    options_json TEXT,
    correct_answer TEXT,
    explanation TEXT,
    version INTEGER NOT NULL DEFAULT 1 CHECK (version > 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_exam_question_bank_institute_updated
    ON edlearn.exam_question_bank (LOWER(institute_code), updated_at DESC);

CREATE TABLE IF NOT EXISTS edlearn.exam_question_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID NOT NULL REFERENCES edlearn.exam_question_bank(id) ON DELETE CASCADE,
    version_number INTEGER NOT NULL CHECK (version_number > 0),
    question_snapshot TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_exam_question_version UNIQUE (question_id, version_number)
);
