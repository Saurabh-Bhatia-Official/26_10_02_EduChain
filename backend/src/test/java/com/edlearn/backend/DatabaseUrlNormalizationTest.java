package com.edlearn.backend;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class DatabaseUrlNormalizationTest {

    @Test
    void convertsRemotePostgresUrlAndRequiresSsl() {
        assertEquals(
                "jdbc:postgresql://db.example:5432/edlearn?sslmode=require"
                        + "&currentSchema=edlearn",
                EdLearnBackendApplication.normalizeDatabaseUrl(
                        "postgresql://db.example:5432/edlearn?sslmode=disable"));
    }

    @Test
    void leavesLocalPostgresUrlUsableWithoutSslOrSocketOverrides() {
        assertEquals(
                "jdbc:postgresql://localhost:5432/edlearndb?currentSchema=edlearn",
                EdLearnBackendApplication.normalizeDatabaseUrl(
                        "jdbc:postgresql://localhost:5432/edlearndb"));
    }

    @Test
    void preservesExistingSchemaAndSocketFactoryParameters() {
        String jdbcUrl = "jdbc:postgresql://db.example:5432/edlearn"
                + "?currentSchema=custom&sslmode=require&socketFactory=custom";

        assertEquals(
                jdbcUrl,
                EdLearnBackendApplication.normalizeDatabaseUrl(jdbcUrl));
    }

    @Test
    void rejectsUnresolvedDatabaseUrlPlaceholders() {
        assertThrows(
                IllegalArgumentException.class,
                () -> EdLearnBackendApplication.normalizeDatabaseUrl("${DATABASE_URL}"));
    }

    @Test
    void rejectsNonPostgresDatabaseUrls() {
        assertThrows(
                IllegalArgumentException.class,
                () -> EdLearnBackendApplication.normalizeDatabaseUrl(
                        "jdbc:mysql://db.example:3306/edlearn"));
    }
}
