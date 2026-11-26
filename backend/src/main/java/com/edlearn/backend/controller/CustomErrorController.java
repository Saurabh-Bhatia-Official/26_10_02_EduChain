package com.edlearn.backend.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
public class CustomErrorController implements ErrorController {

    @RequestMapping(value = "/error", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, Object>> handleErrorJson(HttpServletRequest request) {
        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        Object message = request.getAttribute(RequestDispatcher.ERROR_MESSAGE);
        Object path = request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI);

        int statusCode = HttpStatus.NOT_FOUND.value();
        if (status != null) {
            try {
                statusCode = Integer.parseInt(status.toString());
            } catch (Exception ignored) {}
        }

        HttpStatus httpStatus = HttpStatus.resolve(statusCode);
        String reason = httpStatus != null ? httpStatus.getReasonPhrase() : "Error";

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("status", statusCode);
        body.put("error", reason);
        body.put("message", (message != null && !message.toString().isBlank()) ? message.toString() : "Endpoint not found or method not allowed.");
        body.put("path", path != null ? path.toString() : request.getRequestURI());
        body.put("hint", "Check the URL path or verify your authentication token.");
        body.put("availableEndpoints", List.of(
                "/",
                "/api/db/health",
                "/api/students",
                "/api/instructors",
                "/api/courses",
                "/api/batches",
                "/api/classrooms",
                "/api/assignments",
                "/api/portal/exams",
                "/api/auth/login",
                "/api/admin/login",
                "/api/institutes/login"
        ));

        return ResponseEntity.status(statusCode).body(body);
    }

    @RequestMapping(value = "/error", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> handleErrorHtml(HttpServletRequest request) {
        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        Object path = request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI);
        String requestedPath = path != null ? path.toString() : request.getRequestURI();
        int statusCode = HttpStatus.NOT_FOUND.value();
        if (status != null) {
            try {
                statusCode = Integer.parseInt(status.toString());
            } catch (Exception ignored) {}
        }

        String html = """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <title>EduChain - Endpoint Not Found</title>
                <style>
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                        background: #0f172a;
                        color: #f8fafc;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        min-height: 100vh;
                        margin: 0;
                        padding: 20px;
                    }
                    .card {
                        background: #1e293b;
                        border: 1px solid rgba(255, 255, 255, 0.1);
                        border-radius: 12px;
                        padding: 32px;
                        max-width: 580px;
                        width: 100%;
                        text-align: center;
                    }
                    .code { color: #f43f5e; font-size: 40px; font-weight: 800; margin: 0; }
                    h2 { margin: 12px 0 8px; font-size: 20px; }
                    p { color: #94a3b8; font-size: 14px; line-height: 1.5; }
                    .badge {
                        display: inline-block;
                        padding: 4px 10px;
                        background: rgba(244, 63, 94, 0.15);
                        color: #fb7185;
                        border-radius: 6px;
                        font-family: monospace;
                        font-size: 13px;
                        margin-bottom: 16px;
                    }
                    .links { margin-top: 20px; display: flex; flex-wrap: wrap; gap: 8px; justify-content: center; }
                    .links a {
                        color: #38bdf8;
                        text-decoration: none;
                        background: rgba(56, 189, 248, 0.1);
                        padding: 6px 12px;
                        border-radius: 6px;
                        font-size: 12px;
                    }
                    .links a:hover { background: rgba(56, 189, 248, 0.2); }
                </style>
            </head>
            <body>
                <div class="card">
                    <p class="code">404</p>
                    <h2>Endpoint Not Found</h2>
                    <div class="badge">%s</div>
                    <p>The requested endpoint does not exist or requires a specific sub-path or HTTP method.</p>
                    <div class="links">
                        <a href="/">Home</a>
                        <a href="/api/db/health">DB Health</a>
                        <a href="/api/students">Students</a>
                        <a href="/api/instructors">Instructors</a>
                        <a href="/api/courses">Courses</a>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(requestedPath);
        return ResponseEntity.status(statusCode).body(html);
    }
}
