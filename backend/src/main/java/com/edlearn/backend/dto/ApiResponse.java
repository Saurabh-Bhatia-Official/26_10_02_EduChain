package com.edlearn.backend.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse {

    private boolean success;
    private String token;
    private Object user;
    private String message;
    private Object data;

    public ApiResponse() {}

    public ApiResponse(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public ApiResponse(boolean success, String token, Object user, String message) {
        this.success = success;
        this.token = token;
        this.user = user;
        this.message = message;
    }

    public static ApiResponse ok(String message) {
        return new ApiResponse(true, message);
    }

    public static ApiResponse ok(String token, Object user, String message) {
        return new ApiResponse(true, token, user, message);
    }

    public static ApiResponse error(String message) {
        return new ApiResponse(false, message);
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Object getUser() {
        return user;
    }

    public void setUser(Object user) {
        this.user = user;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }
}
