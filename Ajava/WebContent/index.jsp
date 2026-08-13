<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.interviewportal.model.User" %>
<%@ page import="com.interviewportal.model.InterviewExperience" %>
<%@ page import="com.interviewportal.service.ExperienceService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>

<%
    // Session Tracking
    User currentUser = (User) session.getAttribute("currentUser");
    String adminUser = (String) session.getAttribute("adminUser");
    
    // Fetch some experiences for landing display
    ExperienceService expService = new ExperienceService();
    List<InterviewExperience> allExps = expService.getAllExperiences();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Interview Experience Sharing Portal</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <nav class="navbar">
        <div class="container nav-container">
            <a href="<%= request.getContextPath() %>/index.jsp" class="logo">
                PrepShare <span>Portal</span>
            </a>
            <ul class="nav-links">
                <li><a href="<%= request.getContextPath() %>/index.jsp" class="active">Home</a></li>
                <li><a href="<%= request.getContextPath() %>/search?company=&role=&difficulty=All&result=All">Browse All</a></li>
                <% if (currentUser != null) { %>
                    <li><a href="<%= request.getContextPath() %>/dashboard.jsp">Dashboard</a></li>
                    <li><a href="<%= request.getContextPath() %>/analytics">Analytics</a></li>
                    <li><a href="<%= request.getContextPath() %>/profile.jsp">Profile</a></li>
                    <li><a href="<%= request.getContextPath() %>/logout" class="btn-secondary">Logout (<%= currentUser.getUsername() %>)</a></li>
                <% } else if (adminUser != null) { %>
                    <li><a href="<%= request.getContextPath() %>/adminDashboard.jsp">Admin Panel</a></li>
                    <li><a href="<%= request.getContextPath() %>/analytics">Analytics</a></li>
                    <li><a href="<%= request.getContextPath() %>/logout" class="btn-secondary">Logout (Admin)</a></li>
                <% } else { %>
                    <li><a href="<%= request.getContextPath() %>/login.jsp">Login</a></li>
                    <li><a href="<%= request.getContextPath() %>/register.jsp" class="btn-primary">Register</a></li>
                <% } %>
            </ul>
        </div>
    </nav>

    <!-- Main Hero Banner -->
    <header class="hero">
        <div class="container">
            <h1>Unlock Your Next Career Move</h1>
            <p>Learn from real interview questions, rounds, and success tips shared by peers. Explore interview journeys at Google, Microsoft, Amazon, Meta and more.</p>
            <div class="hero-actions">
                <a href="<%= request.getContextPath() %>/search?company=&role=&difficulty=All&result=All" class="btn-primary">Explore Experiences</a>
                <% if (currentUser == null && adminUser == null) { %>
                    <a href="<%= request.getContextPath() %>/register.jsp" class="btn-secondary">Share Yours</a>
                <% } else if (currentUser != null) { %>
                    <a href="<%= request.getContextPath() %>/addExperience.jsp" class="btn-secondary">Add Experience</a>
                <% } %>
            </div>
        </div>
    </header>

    <!-- Recent Experiences Grid -->
    <main class="container" style="margin-bottom: 5rem;">
        <h2 style="font-size: 2rem; font-weight: 700; margin-bottom: 1rem; text-align: center;">Recent Interview Submissions</h2>
        <p style="color: var(--text-muted); text-align: center; margin-bottom: 2.5rem;">See what companies are asking right now</p>

        <% if (allExps != null && !allExps.isEmpty()) { %>
            <div class="exp-grid">
                <% 
                    // Display up to 6 recent experiences using Iterator (Module 1) and JSP Scriptlet loops
                    int count = 0;
                    Iterator<InterviewExperience> iterator = allExps.iterator();
                    while (iterator.hasNext() && count < 6) {
                        InterviewExperience exp = iterator.next();
                        count++;
                        
                        // Set badges according to difficulty and result
                        String diffClass = "badge-medium";
                        if ("Easy".equalsIgnoreCase(exp.getDifficultyLevel())) diffClass = "badge-easy";
                        else if ("Hard".equalsIgnoreCase(exp.getDifficultyLevel())) diffClass = "badge-hard";

                        String resultClass = "badge-waiting";
                        if ("Selected".equalsIgnoreCase(exp.getResult())) resultClass = "badge-selected";
                        else if ("Rejected".equalsIgnoreCase(exp.getResult())) resultClass = "badge-rejected";
                %>
                    <div class="exp-card">
                        <div>
                            <div class="exp-header">
                                <h3 class="exp-title"><%= exp.getCompanyName() %></h3>
                                <span class="badge <%= diffClass %>"><%= exp.getDifficultyLevel() %></span>
                            </div>
                            <div class="exp-subtitle"><%= exp.getRole() %> | Rounds: <%= exp.getRoundsCount() %></div>
                            
                            <!-- Display Truncated Questions Asked using substring (Module 2) -->
                            <div class="exp-body">
                                <strong>Questions Asked:</strong><br>
                                <% 
                                    String qAsked = exp.getQuestionsAsked();
                                    if (qAsked != null && qAsked.length() > 140) {
                                        qAsked = qAsked.substring(0, 137) + "...";
                                    }
                                %>
                                <p style="white-space: pre-line; margin-top: 0.25rem;"><%= qAsked %></p>
                            </div>
                        </div>
                        <div class="exp-footer">
                            <span class="badge <%= resultClass %>"><%= exp.getResult() %></span>
                            <span class="exp-meta">By <%= exp.getUsername() %> on <%= exp.getInterviewDate() %></span>
                        </div>
                    </div>
                <% } %>
            </div>
            
            <div style="text-align: center; margin-top: 3rem;">
                <a href="<%= request.getContextPath() %>/search?company=&role=&difficulty=All&result=All" class="btn-secondary">View All Experiences (<%= allExps.size() %>)</a>
            </div>
        <% } else { %>
            <div style="text-align: center; padding: 4rem; background-color: var(--bg-surface); border: 1px dashed var(--border-color); border-radius: 1rem;">
                <p style="color: var(--text-muted); font-size: 1.1rem;">No interview experiences shared yet. Be the first to share one!</p>
                <a href="<%= request.getContextPath() %>/register.jsp" class="btn-primary" style="margin-top: 1.5rem;">Share Experience</a>
            </div>
        <% } %>
    </main>

    <!-- Footer -->
    <footer style="text-align: center; padding: 2rem; border-top: 1px solid var(--border-color); color: var(--text-muted); font-size: 0.9rem;">
        <p>&copy; 2026 PrepShare Portal. Developed for Advanced Java Curriculum (Eclipse + Tomcat 10 + MySQL 8).</p>
    </footer>

</body>
</html>
