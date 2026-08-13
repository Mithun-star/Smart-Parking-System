package com.interviewportal.service;

import com.interviewportal.dao.UserDAO;
import com.interviewportal.model.User;

import java.util.List;

public class UserService {
    private final UserDAO userDAO = new UserDAO();

    public boolean registerUser(String username, String password, String email, String fullName) {
        // Demonstrate String trimming and validation (Syllabus Module 2)
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty()) {
            return false;
        }

        User user = new User();
        user.setUsername(username.trim());
        user.setPassword(password.trim()); // Simple clear-text password for demo, or hash it
        user.setEmail(email.trim());
        user.setFullName(fullName.trim());

        return userDAO.registerUser(user);
    }

    public User authenticateUser(String username, String password) {
        if (username == null || password == null) {
            return null;
        }
        return userDAO.validateUser(username.trim(), password.trim());
    }

    public boolean authenticateAdmin(String username, String password) {
        if (username == null || password == null) {
            return false;
        }
        return userDAO.validateAdmin(username.trim(), password.trim());
    }

    public User getUserById(int id) {
        return userDAO.getUserById(id);
    }

    public List<User> getAllUsers() {
        return userDAO.getAllUsers();
    }

    public boolean deleteUser(int id) {
        return userDAO.deleteUser(id);
    }
}
