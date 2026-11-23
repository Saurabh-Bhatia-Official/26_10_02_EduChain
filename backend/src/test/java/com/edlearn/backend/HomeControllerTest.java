package com.edlearn.backend;

import com.edlearn.backend.controller.HomeController;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class HomeControllerTest {

    @Test
    void frontendLinkUsesConfiguredFlutterWebUrl() {
        String html = new HomeController("https://learn.example.com").home().getBody();

        assertTrue(html.contains("href=\"https://learn.example.com\""));
        assertTrue(html.contains("Open EduChain Flutter Web App"));
        assertFalse(html.contains("localhost:5173"));
    }
}
