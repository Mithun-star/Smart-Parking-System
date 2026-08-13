package com.interviewportal.dao;

import com.interviewportal.model.User;
import com.interviewportal.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    /**
     * Registers a new user in the database.
     */
    public boolean registerUser(User user) {
        String sql = "INSERT INTO users (username, password, email, full_name) VALUES (?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getPassword()); // In production, hash this password
            pstmt.setString(3, user.getEmail());
            pstmt.setString(4, user.getFullName());
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error registering user: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, pstmt);
        }
    }

    /**
     * Validates user credentials. Returns User object if valid, null otherwise.
     */
    public User validateUser(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setEmail(rs.getString("email"));
                user.setFullName(rs.getString("full_name"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                return user;
            }
        } catch (SQLException e) {
            System.err.println("Error validating user: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return null;
    }

    /**
     * Validates administrator credentials.
     */
    public boolean validateAdmin(String username, String password) {
        String sql = "SELECT * FROM admin WHERE username = ? AND password = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.err.println("Error validating admin: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return false;
    }

    /**
     * Fetches user by ID.
     */
    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setEmail(rs.getString("email"));
                user.setFullName(rs.getString("full_name"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                return user;
            }
        } catch (SQLException e) {
            System.err.println("Error getting user by ID: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return null;
    }

    /**
     * Retrieves all users (Module 1 - ArrayList).
     */
    public List<User> getAllUsers() {
        List<User> userList = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY id DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setEmail(rs.getString("email"));
                user.setFullName(rs.getString("full_name"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                userList.add(user);
            }
        } catch (SQLException e) {
            System.err.println("Error getting all users: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, stmt, rs);
        }
        return userList;
    }

    /**
     * Deletes a user by ID (Transactions usage: rolls back if user experiences deletion fails).
     */
    public boolean deleteUser(int userId) {
        Connection conn = null;
        PreparedStatement deleteExperiencesPstmt = null;
        PreparedStatement deleteUserPstmt = null;
        try {
            conn = DBUtil.getConnection();
            // Start Transaction
            conn.setAutoCommit(false);

            // 1. Delete associated experiences first (although ON DELETE CASCADE handles this, we do it explicitly to demonstrate transaction rollback/commit)
            String sqlExp = "DELETE FROM interview_experiences WHERE user_id = ?";
            deleteExperiencesPstmt = conn.prepareStatement(sqlExp);
            deleteExperiencesPstmt.setInt(1, userId);
            deleteExperiencesPstmt.executeUpdate();

            // 2. Delete user
            String sqlUser = "DELETE FROM users WHERE id = ?";
            deleteUserPstmt = conn.prepareStatement(sqlUser);
            deleteUserPstmt.setInt(1, userId);
            int rowsDeleted = deleteUserPstmt.executeUpdate();

            // Commit Transaction
            conn.commit();
            return rowsDeleted > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting user, rolling back transaction: " + e.getMessage());
            DBUtil.rollback(conn);
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (deleteExperiencesPstmt != null) deleteExperiencesPstmt.close();
                if (deleteUserPstmt != null) deleteUserPstmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }
}
