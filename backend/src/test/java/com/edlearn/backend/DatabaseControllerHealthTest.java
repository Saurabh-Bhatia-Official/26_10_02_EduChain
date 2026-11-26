package com.edlearn.backend;

import com.edlearn.backend.controller.DatabaseController;
import com.edlearn.backend.repository.InstituteRepository;
import com.edlearn.backend.repository.StoredFileRepository;
import com.edlearn.backend.repository.UserRepository;
import com.edlearn.backend.service.CloudinaryService;
import com.edlearn.backend.service.PortalAccessService;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.mock.web.MockHttpServletRequest;

import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class DatabaseControllerHealthTest {

    @Test
    public void testGetDatabaseHealthUnauthenticatedReturns200() {
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        InstituteRepository instituteRepository = mock(InstituteRepository.class);
        UserRepository userRepository = mock(UserRepository.class);
        StoredFileRepository storedFileRepository = mock(StoredFileRepository.class);
        CloudinaryService cloudinaryService = mock(CloudinaryService.class);
        PortalAccessService accessService = mock(PortalAccessService.class);

        when(accessService.resolveOptional(any())).thenReturn(Optional.empty());
        when(instituteRepository.count()).thenReturn(2L);
        when(userRepository.count()).thenReturn(10L);
        when(storedFileRepository.count()).thenReturn(5L);
        when(cloudinaryService.testConnection()).thenReturn(Map.of("status", "UP"));

        DatabaseController controller = new DatabaseController(
                jdbcTemplate,
                instituteRepository,
                userRepository,
                storedFileRepository,
                cloudinaryService,
                accessService
        );

        MockHttpServletRequest request = new MockHttpServletRequest();
        ResponseEntity<Map<String, Object>> response = controller.getDatabaseHealth(request);
        assertNotNull(response);
        assertEquals(200, response.getStatusCode().value());
        Map<String, Object> body = response.getBody();
        assertNotNull(body);
        assertEquals("UP", body.get("databaseStatus"));
        assertEquals("CONNECTED", body.get("status"));
        assertEquals(2L, body.get("instituteCount"));
        assertEquals(10L, body.get("userCount"));
        assertEquals(5L, body.get("storedFilesCount"));
    }
}
