package com.edlearn.backend;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestConnection {
    public static void main(String[] args) {
        String ep = "ep-dark-lake-b3emihul";
        String host = ep + ".c-4.ap-southeast-1.aws.neon.tech";
        String pooler = ep + "-pooler.c-4.ap-southeast-1.aws.neon.tech";
        String pass = "npg_Vfwy7MXd2QuA";

        String[] tests = {
            "jdbc:postgresql://" + host + ":5432/edlearndb?sslmode=require|neondb_owner|" + pass,
            "jdbc:postgresql://" + pooler + ":5432/edlearndb?sslmode=require&options=endpoint%3D" + ep + "|neondb_owner|" + pass,
            "jdbc:postgresql://" + pooler + ":5432/edlearndb?sslmode=require|neondb_owner@" + ep + "|" + pass,
            "jdbc:postgresql://" + host + ":5432/neondb?sslmode=require|neondb_owner|" + pass,
            "jdbc:postgresql://" + pooler + ":5432/neondb?sslmode=require|neondb_owner|" + pass
        };

        for (String test : tests) {
            String[] p = test.split("\\|");
            String user = p[1];
            String password = p[2];
            System.out.println("Testing: " + p[0] + " | User: " + user);
            try (Connection conn = DriverManager.getConnection(p[0], user, password);
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT current_database(), current_user;")) {
                if (rs.next()) {
                    System.out.println(">>> SUCCESS! Database: " + rs.getString(1) + ", User: " + rs.getString(2));
                    return;
                }
            } catch (Exception e) {
                System.out.println("Failed: " + e.getMessage());
            }
        }
    }
}
