package com.interviewportal.dao;

import com.interviewportal.model.InterviewExperience;
import com.interviewportal.util.DBUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class InterviewExperienceDAO {

    /**
     * Adds an interview experience.
     */
    public boolean addExperience(InterviewExperience exp) {
        String sql = "INSERT INTO interview_experiences (user_id, company_name, role, interview_date, rounds_count, questions_asked, difficulty_level, result, tips) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, exp.getUserId());
            pstmt.setString(2, exp.getCompanyName());
            pstmt.setString(3, exp.getRole());
            pstmt.setDate(4, exp.getInterviewDate());
            pstmt.setInt(5, exp.getRoundsCount());
            pstmt.setString(6, exp.getQuestionsAsked());
            pstmt.setString(7, exp.getDifficultyLevel());
            pstmt.setString(8, exp.getResult());
            pstmt.setString(9, exp.getTips());
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error adding interview experience: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, pstmt);
        }
    }

    /**
     * Updates an existing interview experience.
     */
    public boolean updateExperience(InterviewExperience exp) {
        String sql = "UPDATE interview_experiences SET company_name = ?, role = ?, interview_date = ?, rounds_count = ?, questions_asked = ?, difficulty_level = ?, result = ?, tips = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, exp.getCompanyName());
            pstmt.setString(2, exp.getRole());
            pstmt.setDate(3, exp.getInterviewDate());
            pstmt.setInt(4, exp.getRoundsCount());
            pstmt.setString(5, exp.getQuestionsAsked());
            pstmt.setString(6, exp.getDifficultyLevel());
            pstmt.setString(7, exp.getResult());
            pstmt.setString(8, exp.getTips());
            pstmt.setInt(9, exp.getId());
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error updating interview experience: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, pstmt);
        }
    }

    /**
     * Deletes an interview experience.
     */
    public boolean deleteExperience(int id) {
        String sql = "DELETE FROM interview_experiences WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting interview experience: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, pstmt);
        }
    }

    /**
     * Fetches a specific interview experience by ID.
     */
    public InterviewExperience getExperienceById(int id) {
        String sql = "SELECT ie.*, u.username FROM interview_experiences ie JOIN users u ON ie.user_id = u.id WHERE ie.id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return extractExperience(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching experience by ID: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return null;
    }

    /**
     * Fetches experiences written by a specific user.
     */
    public List<InterviewExperience> getExperiencesByUserId(int userId) {
        List<InterviewExperience> list = new ArrayList<>();
        String sql = "SELECT ie.*, u.username FROM interview_experiences ie JOIN users u ON ie.user_id = u.id WHERE ie.user_id = ? ORDER BY ie.interview_date DESC";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(extractExperience(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error fetching experiences by user ID: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return list;
    }

    /**
     * Fetches all interview experiences in the system.
     */
    public List<InterviewExperience> getAllExperiences() {
        List<InterviewExperience> list = new ArrayList<>();
        String sql = "SELECT ie.*, u.username FROM interview_experiences ie JOIN users u ON ie.user_id = u.id ORDER BY ie.created_at DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                list.add(extractExperience(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error fetching all experiences: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, stmt, rs);
        }
        return list;
    }

    /**
     * Search interview experiences using dynamic SQL query construction.
     * Uses StringBuilder (Syllabus Module 2 coverage) and dynamic PreparedStatement parameters.
     */
    public List<InterviewExperience> searchExperiences(String company, String role, String difficulty, String result) {
        List<InterviewExperience> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT ie.*, u.username FROM interview_experiences ie JOIN users u ON ie.user_id = u.id WHERE 1=1");
        
        List<Object> params = new ArrayList<>();

        if (company != null && !company.trim().isEmpty()) {
            sql.append(" AND ie.company_name LIKE ?");
            params.add("%" + company.trim() + "%");
        }
        if (role != null && !role.trim().isEmpty()) {
            sql.append(" AND ie.role LIKE ?");
            params.add("%" + role.trim() + "%");
        }
        if (difficulty != null && !difficulty.trim().isEmpty() && !difficulty.equalsIgnoreCase("All")) {
            sql.append(" AND ie.difficulty_level = ?");
            params.add(difficulty.trim());
        }
        if (result != null && !result.trim().isEmpty() && !result.equalsIgnoreCase("All")) {
            sql.append(" AND ie.result = ?");
            params.add(result.trim());
        }

        sql.append(" ORDER BY ie.interview_date DESC");

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(extractExperience(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error searching experiences: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return list;
    }

    private InterviewExperience extractExperience(ResultSet rs) throws SQLException {
        InterviewExperience exp = new InterviewExperience();
        exp.setId(rs.getInt("id"));
        exp.setUserId(rs.getInt("user_id"));
        exp.setCompanyName(rs.getString("company_name"));
        exp.setRole(rs.getString("role"));
        exp.setInterviewDate(rs.getDate("interview_date"));
        exp.setRoundsCount(rs.getInt("rounds_count"));
        exp.setQuestionsAsked(rs.getString("questions_asked"));
        exp.setDifficultyLevel(rs.getString("difficulty_level"));
        exp.setResult(rs.getString("result"));
        exp.setTips(rs.getString("tips"));
        exp.setCreatedAt(rs.getTimestamp("created_at"));
        exp.setUsername(rs.getString("username"));
        return exp;
    }
}
