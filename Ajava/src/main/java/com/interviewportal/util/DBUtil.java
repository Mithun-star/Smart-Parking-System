package com.interviewportal.util;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

public class DBUtil {
    private static final String URL = "jdbc:mysql://localhost:3306/interview_portal_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "admin";
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    static {
        try {
            Class.forName(DRIVER);
            System.out.println("MySQL JDBC Driver Registered Successfully!");
        } catch (ClassNotFoundException e) {
            System.err.println("Failed to load MySQL Driver: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Gets a new Database Connection.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    /**
     * Closes Connection, Statement, and ResultSet.
     */
    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        try {
            if (rs != null) rs.close();
        } catch (SQLException e) {
            System.err.println("Error closing ResultSet: " + e.getMessage());
        }
        try {
            if (stmt != null) stmt.close();
        } catch (SQLException e) {
            System.err.println("Error closing Statement: " + e.getMessage());
        }
        try {
            if (conn != null) conn.close();
        } catch (SQLException e) {
            System.err.println("Error closing Connection: " + e.getMessage());
        }
    }

    /**
     * Closes Connection and Statement.
     */
    public static void close(Connection conn, Statement stmt) {
        close(conn, stmt, null);
    }

    /**
     * Commits a transaction.
     */
    public static void commit(Connection conn) {
        if (conn != null) {
            try {
                conn.commit();
                System.out.println("Transaction committed successfully.");
            } catch (SQLException e) {
                System.err.println("Failed to commit transaction: " + e.getMessage());
            }
        }
    }

    /**
     * Rolls back a transaction.
     */
    public static void rollback(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
                System.out.println("Transaction rolled back successfully.");
            } catch (SQLException e) {
                System.err.println("Failed to rollback transaction: " + e.getMessage());
            }
        }
    }

    /**
     * Demonstration of DatabaseMetaData and ResultSetMetaData (Syllabus Requirement).
     * Prints database information and structural details of the users table.
     */
    public static void printMetaDataDemo() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            
            // 1. DatabaseMetaData Demo
            DatabaseMetaData dbMetaData = conn.getMetaData();
            System.out.println("=== Database MetaData ===");
            System.out.println("DB Product Name: " + dbMetaData.getDatabaseProductName());
            System.out.println("DB Product Version: " + dbMetaData.getDatabaseProductVersion());
            System.out.println("Driver Name: " + dbMetaData.getDriverName());
            System.out.println("Driver Version: " + dbMetaData.getDriverVersion());
            System.out.println("URL: " + dbMetaData.getURL());
            
            // 2. ResultSetMetaData Demo
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM users LIMIT 1");
            ResultSetMetaData rsMetaData = rs.getMetaData();
            System.out.println("\n=== ResultSet MetaData for 'users' Table ===");
            int columnCount = rsMetaData.getColumnCount();
            System.out.println("Total Columns: " + columnCount);
            for (int i = 1; i <= columnCount; i++) {
                System.out.println("Column " + i + ": " + rsMetaData.getColumnName(i) 
                        + " | Type: " + rsMetaData.getColumnTypeName(i) 
                        + " | Class: " + rsMetaData.getColumnClassName(i));
            }
        } catch (SQLException e) {
            System.err.println("Error demonstrating metadata: " + e.getMessage());
        } finally {
            close(conn, stmt, rs);
        }
    }
}
