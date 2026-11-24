package com.edlearn.backend;

import org.junit.jupiter.api.Assumptions;

import java.net.URI;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/** Shared guard for tests that connect to or mutate a PostgreSQL database. */
final class TestDatabaseSupport {
    private TestDatabaseSupport() {}

    static boolean isSafeTestUrl(String url) {
        if (url == null || !url.startsWith("jdbc:postgresql://")) return false;
        try {
            URI uri = URI.create(url.substring("jdbc:".length()));
            String database = uri.getPath() == null ? "" : uri.getPath().replaceFirst("^/", "");
            String host = uri.getHost() == null ? "" : uri.getHost().toLowerCase();
            boolean local = host.equals("localhost") || host.equals("127.0.0.1") || host.equals("::1");
            boolean remoteAllowed = "true".equalsIgnoreCase(System.getenv("ALLOW_REMOTE_TEST_DATABASES"));
            return database.toLowerCase().contains("test") && (local || remoteAllowed);
        } catch (IllegalArgumentException ex) {
            return false;
        }
    }

    static void assumeSafeTestDatabase() {
        Assumptions.assumeTrue(isSafeTestUrl(System.getenv("TEST_DATABASE_URL")),
                "Set TEST_DATABASE_URL to an isolated database whose name contains 'test'. Remote test databases also require ALLOW_REMOTE_TEST_DATABASES=true.");
    }

    static Connection openConnection() throws SQLException {
        assumeSafeTestDatabase();
        String username = System.getenv("TEST_DATABASE_USERNAME");
        String password = System.getenv("TEST_DATABASE_PASSWORD");
        if (username == null || username.isBlank() || password == null) {
            throw new IllegalStateException("TEST_DATABASE_USERNAME and TEST_DATABASE_PASSWORD are required for database integration tests.");
        }
        Properties properties = new Properties();
        properties.setProperty("user", username);
        properties.setProperty("password", password);
        return DriverManager.getConnection(System.getenv("TEST_DATABASE_URL"), properties);
    }
}
