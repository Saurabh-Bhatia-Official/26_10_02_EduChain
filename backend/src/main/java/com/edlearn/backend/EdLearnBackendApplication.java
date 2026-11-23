package com.edlearn.backend;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@SpringBootApplication
public class EdLearnBackendApplication {

    public static void main(String[] args) {
        System.setProperty("java.net.preferIPv4Stack", "true");
        loadDotenv("./");
        loadDotenv("../");

        String databaseUrl = configuredValue("DATABASE_URL");
        if (databaseUrl == null || databaseUrl.isBlank()) {
            databaseUrl = configuredValue("SPRING_DATASOURCE_URL");
        }
        if (databaseUrl != null && !databaseUrl.isBlank()) {
            databaseUrl = databaseUrl.trim();
            String schemeLess = databaseUrl.replaceFirst("^jdbc:", "");
            if (schemeLess.startsWith("postgres://") || schemeLess.startsWith("postgresql://")) {
                try {
                    URI uri = URI.create(schemeLess);
                    if (uri.getUserInfo() != null) {
                        String[] userParts = uri.getUserInfo().split(":", 2);
                        if (configuredValue("DATABASE_USERNAME") == null && configuredValue("SPRING_DATASOURCE_USERNAME") == null) {
                            System.setProperty("spring.datasource.username", userParts[0]);
                        }
                        if (userParts.length > 1 && configuredValue("DATABASE_PASSWORD") == null && configuredValue("SPRING_DATASOURCE_PASSWORD") == null) {
                            System.setProperty("spring.datasource.password", userParts[1]);
                        }
                        databaseUrl = databaseUrl.replace(uri.getUserInfo() + "@", "");
                    }
                } catch (Exception ignored) {}
            }
            System.setProperty("spring.datasource.url", normalizeDatabaseUrl(databaseUrl));
        }

        String username = configuredValue("DATABASE_USERNAME");
        if (username == null || username.isBlank()) username = configuredValue("SPRING_DATASOURCE_USERNAME");
        if (username != null && !username.isBlank()) {
            System.setProperty("spring.datasource.username", username.trim());
        }

        String password = configuredValue("DATABASE_PASSWORD");
        if (password == null || password.isBlank()) password = configuredValue("SPRING_DATASOURCE_PASSWORD");
        if (password != null && !password.isBlank()) {
            System.setProperty("spring.datasource.password", password.trim());
        }

        SpringApplication.run(EdLearnBackendApplication.class, args);
    }

    private static void loadDotenv(String directory) {
        Dotenv.configure()
                .ignoreIfMissing()
                .directory(directory)
                .load()
                .entries()
                .forEach(entry -> {
                    if (System.getProperty(entry.getKey()) == null
                            && System.getenv(entry.getKey()) == null) {
                        System.setProperty(entry.getKey(), entry.getValue());
                    }
                });
    }

    static String normalizeDatabaseUrl(String databaseUrl) {
        String jdbcUrl = databaseUrl.trim();
        if (jdbcUrl.contains("${")) {
            throw new IllegalArgumentException(
                    "Database URL contains an unresolved placeholder. Set DATABASE_URL or SPRING_DATASOURCE_URL "
                            + "to a PostgreSQL JDBC URL.");
        }
        if (jdbcUrl.startsWith("postgres://")) {
            jdbcUrl = "jdbc:postgresql://" + jdbcUrl.substring("postgres://".length());
        } else if (jdbcUrl.startsWith("postgresql://")) {
            jdbcUrl = "jdbc:postgresql://" + jdbcUrl.substring("postgresql://".length());
        } else if (!jdbcUrl.startsWith("jdbc:postgresql://")) {
            throw new IllegalArgumentException("DATABASE_URL must be a PostgreSQL connection URL");
        }

        if (jdbcUrl.contains("@")) {
            int atIndex = jdbcUrl.indexOf('@');
            int slashIndex = jdbcUrl.indexOf("://");
            if (slashIndex >= 0 && atIndex > slashIndex) {
                jdbcUrl = jdbcUrl.substring(0, slashIndex + 3) + jdbcUrl.substring(atIndex + 1);
            }
        }

        jdbcUrl = jdbcUrl.replace("&channel_binding=require", "")
                .replace("channel_binding=require&", "")
                .replace("channel_binding=require", "");
        if (!isLocalDatabase(jdbcUrl)) {
            jdbcUrl = setParameter(jdbcUrl, "sslmode", "require");
        }
        if (jdbcUrl.contains(".neon.tech") && !jdbcUrl.contains("socketFactory=")) {
            jdbcUrl = addParameterIfMissing(jdbcUrl, "socketFactory", "com.edlearn.backend.config.NeonSocketFactory");
            System.setProperty("spring.datasource.hikari.data-source-properties.socketFactory", "com.edlearn.backend.config.NeonSocketFactory");
        }
        jdbcUrl = addParameterIfMissing(jdbcUrl, "currentSchema", "edlearn");
        return jdbcUrl;
    }

    private static boolean isLocalDatabase(String jdbcUrl) {
        try {
            String host = URI.create(jdbcUrl.substring("jdbc:".length())).getHost();
            if (host == null) {
                return false;
            }
            String normalizedHost = host.toLowerCase(Locale.ROOT);
            return normalizedHost.equals("localhost")
                    || normalizedHost.equals("127.0.0.1")
                    || normalizedHost.equals("::1");
        } catch (Exception e) {
            return false;
        }
    }

    private static String configuredValue(String name) {
        String value = System.getProperty(name);
        return value == null || value.isBlank() ? System.getenv(name) : value;
    }

    private static String setParameter(String url, String name, String value) {
        int queryStart = url.indexOf('?');
        String baseUrl = queryStart < 0 ? url : url.substring(0, queryStart);
        List<String> parameters = new ArrayList<>();
        boolean found = false;
        if (queryStart >= 0) {
            for (String parameter : url.substring(queryStart + 1).split("&")) {
                int equalsIndex = parameter.indexOf('=');
                String parameterName = equalsIndex < 0
                        ? parameter
                        : parameter.substring(0, equalsIndex);
                if (parameterName.equalsIgnoreCase(name)) {
                    parameters.add(name + "=" + value);
                    found = true;
                } else if (!parameter.isEmpty()) {
                    parameters.add(parameter);
                }
            }
        }
        if (!found) {
            parameters.add(name + "=" + value);
        }
        return baseUrl + "?" + String.join("&", parameters);
    }

    private static String addParameterIfMissing(String url, String name, String value) {
        int queryStart = url.indexOf('?');
        if (queryStart >= 0) {
            for (String parameter : url.substring(queryStart + 1).split("&")) {
                int equalsIndex = parameter.indexOf('=');
                String parameterName = equalsIndex < 0
                        ? parameter
                        : parameter.substring(0, equalsIndex);
                if (parameterName.equalsIgnoreCase(name)) {
                    return url;
                }
            }
        }
        return url + (url.contains("?") ? "&" : "?") + name + "=" + value;
    }
}
