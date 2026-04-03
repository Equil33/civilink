package com.civilink.civilink.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig implements WebMvcConfigurer {

    private final AppProperties appProperties;
    private final ObjectMapper objectMapper;

    public CorsConfig(AppProperties appProperties, ObjectMapper objectMapper) {
        this.appProperties = appProperties;
        this.objectMapper = objectMapper;
    }

    /**
     * Resolves the allowed-origin patterns from application properties.
     * Each entry may be a comma-separated list of Ant-style patterns or
     * regex patterns (prefixed with "regexp:").
     */
    private String[] resolvedPatterns() {
        List<String> allowedOriginsProperty = appProperties.getCors().getAllowedOrigins();
        return allowedOriginsProperty.stream()
            .flatMap(value -> Arrays.stream(value.split(",")))
            .map(String::trim)
            .filter(value -> !value.isEmpty())
            .toArray(String[]::new);
    }

    /**
     * CorsFilter bean — runs in the servlet filter chain before the
     * DispatcherServlet, so it covers every path (including paths that
     * have no matching controller).  When a CORS check fails the filter
     * writes a JSON error body instead of Spring's default plain-text
     * "Invalid CORS request" message.
     */
    @Bean
    public CorsFilter corsFilter() {
        String[] patterns = resolvedPatterns();

        CorsConfiguration config = new CorsConfiguration();
        for (String pattern : patterns) {
            config.addAllowedOriginPattern(pattern);
        }
        config.addAllowedMethod("*");
        config.addAllowedHeader("*");
        config.setAllowCredentials(false);
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);

        return new CorsFilter(source) {
            @Override
            protected void rejectRequest(HttpServletResponse response) throws IOException {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("application/json;charset=UTF-8");
                Map<String, Object> body = new LinkedHashMap<>();
                body.put("timestamp", LocalDateTime.now().toString());
                body.put("status", HttpServletResponse.SC_FORBIDDEN);
                body.put("error", "CORS policy: request origin is not allowed");
                objectMapper.writeValue(response.getWriter(), body);
            }
        };
    }

    /**
     * WebMvcConfigurer mapping kept in sync so that Spring MVC's own
     * CORS handling (used for pre-flight caching, etc.) matches the
     * filter above.
     */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        String[] patterns = resolvedPatterns();

        registry.addMapping("/**")
            .allowedOriginPatterns(patterns)
            .allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
            .allowedHeaders("*")
            .allowCredentials(false)
            .maxAge(3600);
    }
}
