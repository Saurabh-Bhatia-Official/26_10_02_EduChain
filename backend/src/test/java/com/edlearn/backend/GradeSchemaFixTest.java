package com.edlearn.backend;

import org.junit.jupiter.api.Test;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.Properties;

public class GradeSchemaFixTest {

    @Test
    public void fixGradesTableSchema() throws Exception {
        String url = "jdbc:postgresql://ep-dark-lake-b3emihul-pooler.c-4.ap-southeast-1.aws.neon.tech:5432/edlearndb?sslmode=require&currentSchema=edlearn&socketFactory=com.edlearn.backend.config.NeonSocketFactory";
        Properties props = new Properties();
        props.setProperty("user", "neondb_owner");
        props.setProperty("password", "npg_Vfwy7MXd2QuA");

        try (Connection conn = DriverManager.getConnection(url, props);
             Statement stmt = conn.createStatement()) {

            System.out.println("Relaxing NOT NULL on subject and semester in edlearn.grades...");
            stmt.execute("ALTER TABLE edlearn.grades ALTER COLUMN subject DROP NOT NULL");
            stmt.execute("ALTER TABLE edlearn.grades ALTER COLUMN semester DROP NOT NULL");
            System.out.println("Successfully dropped NOT NULL on subject and semester!");
        }
    }
}
