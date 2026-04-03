package com.civilink.civilink.exception;

import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.HttpRequestMethodNotAllowedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.resource.NoResourceFoundException;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<Map<String, Object>> handleApiException(ApiException exception, HttpServletRequest request) {
        Map<String, Object> body = baseBody(exception.getStatus(), exception.getMessage(), request.getRequestURI());
        body.put("detail", exception.getMessage());
        return jsonResponse(exception.getStatus(), body);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidation(MethodArgumentNotValidException exception, HttpServletRequest request) {
        String details = exception.getBindingResult().getFieldErrors().stream()
            .map(this::formatFieldError)
            .collect(Collectors.joining(", "));
        String message = details.isBlank() ? "Validation failed" : details;
        Map<String, Object> body = baseBody(HttpStatus.BAD_REQUEST, message, request.getRequestURI());
        return jsonResponse(HttpStatus.BAD_REQUEST, body);
    }

    @ExceptionHandler(HttpRequestMethodNotAllowedException.class)
    public ResponseEntity<Map<String, Object>> handleMethodNotAllowed(HttpRequestMethodNotAllowedException exception, HttpServletRequest request) {
        Map<String, Object> body = baseBody(HttpStatus.METHOD_NOT_ALLOWED, "Method not allowed: " + exception.getMethod(), request.getRequestURI());
        return jsonResponse(HttpStatus.METHOD_NOT_ALLOWED, body);
    }

    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<Map<String, Object>> handleNoResource(NoResourceFoundException exception, HttpServletRequest request) {
        Map<String, Object> body = baseBody(HttpStatus.NOT_FOUND, "Not found", request.getRequestURI());
        return jsonResponse(HttpStatus.NOT_FOUND, body);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGeneric(Exception exception, HttpServletRequest request) {
        log.error("Unhandled exception for {}", request.getRequestURI(), exception);
        Map<String, Object> body = baseBody(HttpStatus.INTERNAL_SERVER_ERROR, "Internal server error", request.getRequestURI());
        body.put("detail", exception.getClass().getName() + ": " + String.valueOf(exception.getMessage()));
        return jsonResponse(HttpStatus.INTERNAL_SERVER_ERROR, body);
    }

    private String formatFieldError(FieldError fieldError) {
        return fieldError.getField() + " " + fieldError.getDefaultMessage();
    }

    private Map<String, Object> baseBody(HttpStatus status, String message, String path) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("timestamp", LocalDateTime.now().toString());
        body.put("status", status.value());
        body.put("error", message);
        body.put("path", path);
        return body;
    }

    /** Builds a ResponseEntity with Content-Type: application/json always set. */
    private ResponseEntity<Map<String, Object>> jsonResponse(HttpStatus status, Map<String, Object> body) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        return new ResponseEntity<>(body, headers, status);
    }
}

