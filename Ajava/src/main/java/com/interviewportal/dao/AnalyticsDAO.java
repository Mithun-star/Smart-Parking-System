package com.interviewportal.dao;

import com.interviewportal.model.AnalyticsLog;
import com.interviewportal.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AnalyticsDAO {

    /**
     * Inserts an audit log record into analytics_log.
     */
    public boolean logEvent(String eventType, String description) {
        String sql = "INSERT INTO analytics_log (event_type, description) VALUES (?, ?)";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, eventType);
            pstmt.setString(2, description);
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error logging event: " + e.getMessage());
            return false;
        } finally {
            DBUtil.close(conn, pstmt);
        }
    }

    /**
     * Gets count of total interview experiences.
     */
    public int getTotalExperiencesCount() {
        String sql = "SELECT COUNT(*) AS total FROM interview_experiences";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            System.err.println("Error getting total experiences count: " + e.getMessage());
        } finally {
            DBUtil.close(conn, stmt, rs);
        }
        return 0;
    }

    /**
     * Fetches all logs from the database for admin view (Module 1 - LinkedList).
     */
    public List<AnalyticsLog> getAllLogs() {
        List<AnalyticsLog> logList = new java.util.LinkedList<>(); // Using LinkedList as per syllabus
        String sql = "SELECT * FROM analytics_log ORDER BY id DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                AnalyticsLog log = new AnalyticsLog();
                log.setId(rs.getInt("id"));
                log.setEventType(rs.getString("event_type"));
                log.setDescription(rs.getString("description"));
                log.setCreatedAt(rs.getTimestamp("created_at"));
                logList.add(log);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching analytics logs: " + e.getMessage());
        } finally {
            DBUtil.close(conn, stmt, rs);
        }
        return logList;
    }

    /**
     * Fetches raw company experience counts.
     */
    public Map<String, Integer> getCompanyExperienceCountsRaw() {
        Map<String, Integer> map = new HashMap<>();
        String sql = "SELECT company_name, COUNT(*) AS count_val FROM interview_experiences GROUP BY company_name";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                map.put(rs.getString("company_name"), rs.getInt("count_val"));
            }
        } catch (SQLException e) {
            System.err.println("Error getting company counts: " + e.getMessage());
        } finally {
            DBUtil.close(conn, stmt, rs);
        }
        return map;
    }

    /**
     * Fetches raw counts by interview result (Selected, Rejected, Waiting).
     */
    public Map<String, Integer> getResultCountsRaw() {
        Map<String, Integer> map = new HashMap<>();
        String sql = "SELECT result, COUNT(*) AS count_val FROM interview_experiences GROUP BY result";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                map.put(rs.getString("result"), rs.getInt("count_val"));
            }
        } catch (SQLException e) {
            System.err.println("Error getting result counts: " + e.getMessage());
        } finally {
            DBUtil.close(conn, stmt, rs);
        }
        return map;
    }

    /**
     * Fetches all questions asked to perform keyword frequency analysis.
     */
    public List<String> getAllQuestions() {
        List<String> questions = new ArrayList<>();
        String sql = "SELECT questions_asked FROM interview_experiences";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                questions.add(rs.getString("questions_asked"));
            }
        } catch (SQLException e) {
            System.err.println("Error fetching all questions: " + e.getMessage());
        } finally {
            DBUtil.close(conn, stmt, rs);
        }
        return questions;
    }
}
