<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.interviewportal.model.User" %>
<%@ page import="com.interviewportal.model.InterviewExperience" %>
<%@ page import="com.interviewportal.model.AnalyticsLog" %>
<%@ page import="com.interviewportal.service.UserService" %>
<%@ page import="com.interviewportal.service.ExperienceService" %>
<%@ page import="com.interviewportal.service.AnalyticsService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>

<%
    // Session Verification
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    UserService uService = new UserService();
    ExperienceService expService = new ExperienceService();
    AnalyticsService aService = new AnalyticsService();

    // Fetch lists
    List<User> usersList = uService.getAllUsers();
    List<InterviewExperience> expsList = expService.getAllExperiences();
    List<AnalyticsLog> logsList = aService.getAllLogs();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - PrepShare Portal</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <nav class="navbar">
        <div class="container nav-container">
            <a href="<%= request.getContextPath() %>/index.jsp" class="logo">
                PrepShare <span>Portal [Admin]</span>
            </a>
            <ul class="nav-links">
                <li><a href="<%= request.getContextPath() %>/index.jsp">Home</a></li>
                <li><a href="<%= request.getContextPath() %>/search?company=&role=&difficulty=All&result=All">Browse All</a></li>
                <li><a href="<%= request.getContextPath() %>/adminDashboard.jsp" class="active">Admin Panel</a></li>
                <li><a href="<%= request.getContextPath() %>/analytics">Analytics</a></li>
                <li><a href="<%= request.getContextPath() %>/logout" class="btn-secondary">Logout</a></li>
            </ul>
        </div>
    </nav>

    <!-- Workspace -->
    <main class="container" style="margin-top: 2.5rem; margin-bottom: 5rem;">
        
        <!-- Welcome banner and messages -->
        <div class="main-panel" style="margin-bottom: 2rem;">
            <h1 style="font-size: 2rem; font-weight: 700;">Administrator Control Board</h1>
            <p style="color: var(--text-muted);">Manage registered users, review contributed experiences, and monitor security system logs.</p>
            
            <%
                String msg = request.getParameter("msg");
                if (msg != null) {
                    if (msg.equalsIgnoreCase("delete_success")) {
            %>
                        <div class="alert alert-success" style="margin-top: 1rem;">Experience entry deleted successfully.</div>
            <%
                    } else if (msg.equalsIgnoreCase("delete_user_success")) {
            %>
                        <div class="alert alert-success" style="margin-top: 1rem;">User and all associated experiences deleted successfully.</div>
            <%
                    } else if (msg.equalsIgnoreCase("delete_user_failed") || msg.equalsIgnoreCase("delete_failed")) {
            %>
                        <div class="alert alert-danger" style="margin-top: 1rem;">Failed to execute request. Database integrity constraints block this action.</div>
            <%
                    }
                }
            %>
        </div>

        <!-- Section 1: Manage Users -->
        <div class="main-panel" style="margin-bottom: 2rem;">
            <h2 style="font-size: 1.5rem; font-weight: 600; margin-bottom: 1rem;">Registered Portal Users (<%= usersList.size() %>)</h2>
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>User ID</th>
                            <th>Username</th>
                            <th>Email Address</th>
                            <th>Full Name</th>
                            <th>Joined Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Iterator<User> userIter = usersList.iterator();
                            while (userIter.hasNext()) {
                                User u = userIter.next();
                        %>
                            <tr>
                                <td><%= u.getId() %></td>
                                <td><strong><%= u.getUsername() %></strong></td>
                                <td><%= u.getEmail() %></td>
                                <td><%= u.getFullName() %></td>
                                <td><%= u.getCreatedAt() %></td>
                                <td>
                                    <form action="<%= request.getContextPath() %>/admin" method="POST" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this user? All their submissions will be deleted.');">
                                        <input type="hidden" name="action" value="deleteUser">
                                        <input type="hidden" name="userId" value="<%= u.getId() %>">
                                        <button type="submit" class="btn-danger">Delete User</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Section 2: Manage Experiences -->
        <div class="main-panel" style="margin-bottom: 2rem;">
            <h2 style="font-size: 1.5rem; font-weight: 600; margin-bottom: 1rem;">Interview Experiences Shared (<%= expsList.size() %>)</h2>
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Author</th>
                            <th>Company</th>
                            <th>Role</th>
                            <th>Rounds</th>
                            <th>Difficulty</th>
                            <th>Result</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Iterator<InterviewExperience> expIter = expsList.iterator();
                            while (expIter.hasNext()) {
                                InterviewExperience exp = expIter.next();
                                
                                String diffClass = "badge-medium";
                                if ("Easy".equalsIgnoreCase(exp.getDifficultyLevel())) diffClass = "badge-easy";
                                else if ("Hard".equalsIgnoreCase(exp.getDifficultyLevel())) diffClass = "badge-hard";

                                String resultClass = "badge-waiting";
                                if ("Selected".equalsIgnoreCase(exp.getResult())) resultClass = "badge-selected";
                                else if ("Rejected".equalsIgnoreCase(exp.getResult())) resultClass = "badge-rejected";
                        %>
                            <tr>
                                <td><%= exp.getId() %></td>
                                <td><%= exp.getUsername() %> (ID: <%= exp.getUserId() %>)</td>
                                <td><strong><%= exp.getCompanyName() %></strong></td>
                                <td><%= exp.getRole() %></td>
                                <td><%= exp.getRoundsCount() %></td>
                                <td><span class="badge <%= diffClass %>"><%= exp.getDifficultyLevel() %></span></td>
                                <td><span class="badge <%= resultClass %>"><%= exp.getResult() %></span></td>
                                <td>
                                    <form action="<%= request.getContextPath() %>/deleteExperience" method="POST" style="display:inline;" onsubmit="return confirm('Delete this interview experience?');">
                                        <input type="hidden" name="id" value="<%= exp.getId() %>">
                                        <button type="submit" class="btn-danger">Delete</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Section 3: Audit System Logs -->
        <div class="main-panel">
            <h2 style="font-size: 1.5rem; font-weight: 600; margin-bottom: 1rem;">System Logs & Event Audits (LinkedList)</h2>
            <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Log ID</th>
                            <th>Event Type</th>
                            <th>Description</th>
                            <th>Timestamp</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Iterator<AnalyticsLog> logIter = logsList.iterator();
                            while (logIter.hasNext()) {
                                AnalyticsLog logVal = logIter.next();
                        %>
                            <tr>
                                <td><%= logVal.getId() %></td>
                                <td><span class="badge" style="background-color: var(--border-color); color: #c7d2fe;"><%= logVal.getEventType() %></span></td>
                                <td style="font-size: 0.9rem;"><%= logVal.getDescription() %></td>
                                <td style="font-size: 0.85rem; color: var(--text-muted);"><%= logVal.getCreatedAt() %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

    </main>

    <!-- Footer -->
    <footer style="text-align: center; padding: 2rem; border-top: 1px solid var(--border-color); color: var(--text-muted); font-size: 0.9rem;">
        <p>&copy; 2026 PrepShare Portal. Developed for Advanced Java Curriculum.</p>
    </footer>

</body>
</html>
