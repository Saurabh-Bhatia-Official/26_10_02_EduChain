package com.edlearn.backend;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class DatabaseInspectionTest {
    @Test
    void databaseMaintenanceRequiresAnExplicitTestDatabase() {
        assertFalse(TestDatabaseSupport.isSafeTestUrl(null));
        assertFalse(TestDatabaseSupport.isSafeTestUrl("jdbc:postgresql://db.example:5432/edlearndb"));
        assertTrue(TestDatabaseSupport.isSafeTestUrl("jdbc:postgresql://localhost:5432/edlearndb_test"));
    }
}
