package com.edlearn.backend;

import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.Statement;

class GradeSchemaFixTest {
    @Test
    void gradeSchemaMigrationRunsOnlyAgainstAnExplicitTestDatabase() throws Exception {
        TestDatabaseSupport.assumeSafeTestDatabase();
        try (Connection connection = TestDatabaseSupport.openConnection();
             Statement statement = connection.createStatement()) {
            statement.execute("ALTER TABLE edlearn.grades ALTER COLUMN subject DROP NOT NULL");
            statement.execute("ALTER TABLE edlearn.grades ALTER COLUMN semester DROP NOT NULL");
        }
    }
}
