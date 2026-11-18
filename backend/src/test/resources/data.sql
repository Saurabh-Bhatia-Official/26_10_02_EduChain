INSERT INTO edlearn.institutes (
    id, institute_code, institute_name, email, is_verified,
    verification_status, verification_date, student_count,
    faculty_count, department_count, active_semester, created_at
) VALUES (
    '00000000-0000-0000-0000-000000002025', 'INST-2025', 'EduChain Test Institute',
    'test-institute@edlearn.test', TRUE, 'Verified', 'Test session',
    0, 0, 1, 'Test semester', CURRENT_TIMESTAMP
);
