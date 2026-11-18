package com.edlearn.backend;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

/** Optional local connectivity check; reads all connection details from environment. */
public class TestConnection {
    public static void main(String[] args) {
        String url = System.getenv("SPRING_DATASOURCE_URL");
        String user = System.getenv("SPRING_DATASOURCE_USERNAME");
        String password = System.getenv("SPRING_DATASOURCE_PASSWORD");
        if (url == null || user == null || password == null) {
            System.err.println("Set SPRING_DATASOURCE_URL, SPRING_DATASOURCE_USERNAME, and SPRING_DATASOURCE_PASSWORD.");
            return;
        }
        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT current_database(), current_user")) {
            if (rs.next()) System.out.println("Database: " + rs.getString(1) + ", user: " + rs.getString(2));
        } catch (Exception e) {
            System.err.println("Database connection failed: " + e.getMessage());
        }
    }
}
