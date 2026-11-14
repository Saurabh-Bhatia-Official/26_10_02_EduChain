package com.edlearn.backend.controller;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeController {

    @GetMapping(value = "/", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> home() {
        String html = """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>EdLearn Backend API</title>
                <style>
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                        background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
                        color: #f8fafc;
                        min-height: 100vh;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        margin: 0;
                        padding: 20px;
                        box-sizing: border-box;
                    }
                    .card {
                        background: rgba(30, 41, 59, 0.85);
                        backdrop-filter: blur(12px);
                        border: 1px solid rgba(255, 255, 255, 0.1);
                        border-radius: 16px;
                        padding: 36px;
                        max-width: 620px;
                        width: 100%;
                        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
                        text-align: center;
                    }
                    .badge {
                        display: inline-block;
                        padding: 6px 14px;
                        background: rgba(16, 185, 129, 0.2);
                        color: #34d399;
                        border: 1px solid rgba(16, 185, 129, 0.3);
                        border-radius: 9999px;
                        font-size: 13px;
                        font-weight: 600;
                        margin-bottom: 16px;
                    }
                    h1 {
                        font-size: 28px;
                        font-weight: 700;
                        margin: 0 0 12px 0;
                        color: #ffffff;
                    }
                    p {
                        color: #94a3b8;
                        font-size: 15px;
                        line-height: 1.6;
                        margin-bottom: 24px;
                    }
                    .frontend-btn {
                        display: inline-block;
                        background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
                        color: #ffffff;
                        font-weight: 600;
                        font-size: 16px;
                        padding: 14px 28px;
                        border-radius: 10px;
                        text-decoration: none;
                        transition: all 0.2s ease;
                        box-shadow: 0 8px 20px rgba(37, 99, 235, 0.35);
                        margin-bottom: 24px;
                    }
                    .frontend-btn:hover {
                        transform: translateY(-2px);
                        box-shadow: 0 12px 25px rgba(37, 99, 235, 0.5);
                    }
                    .links {
                        display: flex;
                        flex-wrap: wrap;
                        gap: 10px;
                        justify-content: center;
                    }
                    .links a {
                        color: #60a5fa;
                        text-decoration: none;
                        background: rgba(255, 255, 255, 0.05);
                        padding: 8px 14px;
                        border-radius: 8px;
                        font-size: 13px;
                        border: 1px solid rgba(255, 255, 255, 0.08);
                    }
                    .links a:hover {
                        background: rgba(255, 255, 255, 0.1);
                        color: #93c5fd;
                    }
                </style>
            </head>
            <body>
                <div class="card">
                    <div class="badge">&#9679; Spring Boot API & Neon PostgreSQL Online</div>
                    <h1>EdLearn Backend API</h1>
                    <p>
                        The backend REST API server is actively connected to your <strong>Neon PostgreSQL Cloud Console</strong> and <strong>Cloudinary Media Cloud</strong>.
                    </p>
                    <a href="http://localhost:5173" class="frontend-btn">
                        Open React Frontend App (Port 5173) &rarr;
                    </a>
                    <div class="links">
                        <a href="/api/db/health" target="_blank">Database Health Status</a>
                        <a href="/api/students" target="_blank">Live Students API</a>
                        <a href="/api/instructors" target="_blank">Live Instructors API</a>
                        <a href="/api/dashboard/admin" target="_blank">Admin Dashboard API</a>
                    </div>
                </div>
            </body>
            </html>
            """;
        return ResponseEntity.ok(html);
    }
}
