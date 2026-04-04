package com.civilink.civilink.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class EnvController {

    @Value("${app.google-maps.api-key:}")
    private String googleMapsApiKey;

    @GetMapping(value = "/env.js", produces = "application/javascript")
    public ResponseEntity<String> envJs() {
        String key = googleMapsApiKey == null ? "" : googleMapsApiKey.trim();
        String payload = "window.__env = window.__env || {};\n"
            + "window.__env.GOOGLE_MAPS_API_KEY = " + jsString(key) + ";\n";
        return ResponseEntity.ok()
            .contentType(MediaType.valueOf("application/javascript; charset=UTF-8"))
            .cacheControl(CacheControl.noStore())
            .body(payload);
    }

    private static String jsString(String value) {
        if (value == null) {
            return "\"\"";
        }
        String escaped = value
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r");
        return "\"" + escaped + "\"";
    }
}

