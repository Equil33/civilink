package com.civilink.civilink.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;
import org.springframework.web.filter.OncePerRequestFilter;
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

    private UrlBasedCorsConfigurationSource corsConfigurationSource() {
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
        return source;
    }

    /**
     * CorsFilter bean — runs in the servlet filter chain before the
     * DispatcherServlet, so it covers every path (including paths that
     * have no matching controller).  When a CORS check fails the filter
     * writes a JSON error body instead of Spring's default plain-text
     * "Invalid CORS request" message.
     *
     * Spring Framework 6 removed the protected rejectRequest() hook from
     * CorsFilter, so we wrap the standard CorsFilter in a
     * OncePerRequestFilter that intercepts the 403 it sets and rewrites
     * the response body as JSON before the response is committed.
     */
    @Bean
    @Order(Ordered.HIGHEST_PRECEDENCE)
    public OncePerRequestFilter corsFilter() {
        UrlBasedCorsConfigurationSource source = corsConfigurationSource();
        CorsFilter delegate = new CorsFilter(source);

        return new OncePerRequestFilter() {
            @Override
            protected void doFilterInternal(
                    HttpServletRequest request,
                    HttpServletResponse response,
                    FilterChain filterChain) throws ServletException, IOException {

                // Use a response wrapper so we can intercept the status before
                // the response is committed.
                StatusCapturingResponseWrapper wrapper =
                        new StatusCapturingResponseWrapper(response);

                delegate.doFilter(request, wrapper, filterChain);

                // If the CORS filter rejected the request it sets 403 and
                // returns without calling the chain, leaving the body empty.
                // We detect that here and write a proper JSON error body.
                if (wrapper.getStatus() == HttpServletResponse.SC_FORBIDDEN
                        && !response.isCommitted()) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.setContentType("application/json;charset=UTF-8");
                    Map<String, Object> body = new LinkedHashMap<>();
                    body.put("timestamp", LocalDateTime.now().toString());
                    body.put("status", HttpServletResponse.SC_FORBIDDEN);
                    body.put("error", "CORS policy: request origin is not allowed");
                    objectMapper.writeValue(response.getWriter(), body);
                }
            }
        };
    }

    /**
     * Minimal HttpServletResponseWrapper that captures the status code so
     * the outer filter can inspect it without committing the response.
     */
    private static class StatusCapturingResponseWrapper
            extends jakarta.servlet.http.HttpServletResponseWrapper {

        private int status = HttpServletResponse.SC_OK;

        StatusCapturingResponseWrapper(HttpServletResponse response) {
            super(response);
        }

        @Override
        public void setStatus(int sc) {
            this.status = sc;
            super.setStatus(sc);
        }

        @Override
        @SuppressWarnings("deprecation")
        public void setStatus(int sc, String sm) {
            this.status = sc;
            super.setStatus(sc, sm);
        }

        @Override
        public void sendError(int sc) throws IOException {
            this.status = sc;
            super.sendError(sc);
        }

        @Override
        public void sendError(int sc, String msg) throws IOException {
            this.status = sc;
            super.sendError(sc, msg);
        }

        @Override
        public int getStatus() {
            return this.status;
        }
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
