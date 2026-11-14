package com.edlearn.backend;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class EdLearnBackendApplication {

    public static void main(String[] args) {
        System.setProperty("java.net.preferIPv4Stack", "true");
        // Load .env if present in current dir or parent dirs
        try {
            Dotenv dotenv = Dotenv.configure()
                    .ignoreIfMissing()
                    .directory("./")
                    .load();
            dotenv.entries().forEach(entry -> {
                if (System.getProperty(entry.getKey()) == null && System.getenv(entry.getKey()) == null) {
                    System.setProperty(entry.getKey(), entry.getValue());
                }
            });
        } catch (Exception e) {
            // Check parent dir
            try {
                Dotenv dotenvParent = Dotenv.configure()
                        .ignoreIfMissing()
                        .directory("../")
                        .load();
                dotenvParent.entries().forEach(entry -> {
                    if (System.getProperty(entry.getKey()) == null && System.getenv(entry.getKey()) == null) {
                        System.setProperty(entry.getKey(), entry.getValue());
                    }
                });
            } catch (Exception ex) {
                // Ignore fallback to defaults
            }
        }

        // Auto-configure Spring Datasource from DATABASE_URL if present
        try {
            String dbUrl = System.getProperty("DATABASE_URL");
            if (dbUrl == null || dbUrl.isBlank()) {
                dbUrl = System.getenv("DATABASE_URL");
            }
            if (dbUrl != null && !dbUrl.isBlank() && (dbUrl.startsWith("postgres://") || dbUrl.startsWith("postgresql://"))) {
                String clean = dbUrl.replace("postgres://", "").replace("postgresql://", "");
                String userInfo = "";
                String hostPortDb = clean;
                if (clean.contains("@")) {
                    String[] parts = clean.split("@", 2);
                    userInfo = parts[0];
                    hostPortDb = parts[1];
                }
                if (!userInfo.isBlank() && userInfo.contains(":")) {
                    String[] userPass = userInfo.split(":", 2);
                    System.setProperty("SPRING_DATASOURCE_USERNAME", userPass[0]);
                    System.setProperty("SPRING_DATASOURCE_PASSWORD", userPass[1]);
                }
                String jdbcHostPortDb = hostPortDb;
                if (jdbcHostPortDb.contains("channel_binding=")) {
                    jdbcHostPortDb = jdbcHostPortDb.replace("&channel_binding=require", "")
                                                   .replace("channel_binding=require&", "")
                                                   .replace("channel_binding=require", "");
                }
                if (!jdbcHostPortDb.contains("currentSchema=")) {
                    jdbcHostPortDb += (jdbcHostPortDb.contains("?") ? "&" : "?") + "currentSchema=edlearn";
                }
                if (!jdbcHostPortDb.contains("socketFactory=")) {
                    jdbcHostPortDb += (jdbcHostPortDb.contains("?") ? "&" : "?") + "socketFactory=com.edlearn.backend.config.NeonSocketFactory";
                }
                System.setProperty("SPRING_DATASOURCE_URL", "jdbc:postgresql://" + jdbcHostPortDb);
                System.setProperty("SPRING_DATASOURCE_DRIVER", "org.postgresql.Driver");
            }
        } catch (Exception ex) {
            System.err.println("Notice: DATABASE_URL auto-parsing: " + ex.getMessage());
        }

        String finalUrl = System.getProperty("SPRING_DATASOURCE_URL");
        if (finalUrl != null && !finalUrl.contains("socketFactory=")) {
            finalUrl += (finalUrl.contains("?") ? "&" : "?") + "socketFactory=com.edlearn.backend.config.NeonSocketFactory";
            System.setProperty("SPRING_DATASOURCE_URL", finalUrl);
        }

        SpringApplication.run(EdLearnBackendApplication.class, args);
    }
}
