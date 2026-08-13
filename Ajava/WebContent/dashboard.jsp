<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.interviewportal.model.User" %>
<%@ page import="com.interviewportal.model.InterviewExperience" %>
<%@ page import="com.interviewportal.service.ExperienceService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>

<%
    // Session Verification
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    ExperienceService expService = new ExperienceService();
    
    // Fetch experiences shared by the logged-in user
    List<InterviewExperience> myExps = expService.getExperiencesByUserId(currentUser.getId());
    
    // Collection algorithms: find experience with max rounds among user's submissions
    InterviewExperience maxRoundsExp = expService.getExperienceWithMaxRounds(myExps);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard - PrepShare Portal</title>
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
                <li><a href="<%= request.getContextPath() %>/index.jsp">Home</a></li>
                <li><a href="<%= request.getContextPath() %>/search?company=&role=&difficulty=All&result=All">Browse All</a></li>
                <li><a href="<%= request.getContextPath() %>/dashboard.jsp" class="active">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/analytics">Analytics</a></li>
                <li><a href="<%= request.getContextPath() %>/profile.jsp">Profile</a></li>
                <li><a href="<%= request.getContextPath() %>/logout" class="btn-secondary">Logout</a></li>
            </ul>
        </div>
    </nav>

    <!-- Main Workspace -->
    <main class="container">
        <div class="dashboard-grid">
            
            <!-- Sidebar Navigation -->
            <aside class="sidebar">
                <h3 style="font-size: 1rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 1rem; padding-left: 1rem;">Menu</h3>
                <ul class="sidebar-menu">
                    <li><a href="<%= request.getContextPath() %>/dashboard.jsp" class="active">My Dashboard</a></li>
                    <li><a href="<%= request.getContextPath() %>/addExperience.jsp">Add Experience</a></li>
                    <li><a href="<%= request.getContextPath() %>/search?company=&role=&difficulty=All&result=All">Search Portal</a></li>
                    <li><a href="<%= request.getContextPath() %>/analytics">Analytics Summary</a></li>
                    <li><a href="<%= request.getContextPath() %>/profile.jsp">Manage Profile</a></li>
                    <li><a href="<%= request.getContextPath() %>/logout" style="color: var(--error);">Logout</a></li>
                </ul>
            </aside>

            <!-- Main Panel -->
            <section class="main-panel">
                <h1 style="font-size: 2rem; font-weight: 700; margin-bottom: 0.5rem;">Welcome, <%= currentUser.getFullName() %>!</h1>
                <p style="color: var(--text-muted); margin-bottom: 2rem;">Manage your interview experience entries and see system statistics.</p>

                <%
                    // Display query messages (success, warning)
                    String msg = request.getParameter("msg");
                    if (msg != null) {
                        if (msg.equalsIgnoreCase("add_success")) {
                %>
                            <div class="alert alert-success">Your interview experience has been successfully published!</div>
                <%
                        } else if (msg.equalsIgnoreCase("edit_success")) {
                %>
                            <div class="alert alert-success">Your entry has been successfully updated.</div>
                <%
                        } else if (msg.equalsIgnoreCase("delete_success")) {
                %>
                            <div class="alert alert-success">Interview experience deleted successfully.</div>
                <%
                        } else if (msg.equalsIgnoreCase("delete_failed") || msg.equalsIgnoreCase("edit_failed")) {
                %>
                            <div class="alert alert-danger">An error occurred while updating the database.</div>
                <%
                        } else if (msg.equalsIgnoreCase("unauthorized")) {
                %>
                            <div class="alert alert-danger">Warning: You are not authorized to edit that record!</div>
                <%
                        }
                    }
                %>

                <!-- Quick Stats -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-val"><%= myExps.size() %></div>
                        <div class="stat-label">My Contributions</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-val">
                            <%= (maxRoundsExp != null) ? maxRoundsExp.getRoundsCount() : 0 %>
                        </div>
                        <div class="stat-label">Max Interview Rounds</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-val" style="color: var(--accent);">
                            <%= (maxRoundsExp != null) ? maxRoundsExp.getCompanyName() : "N/A" %>
                        </div>
                        <div class="stat-label">Longest Interview</div>
                    </div>
                </div>

                <!-- Own Contributions Table -->
                <h2 style="font-size: 1.5rem; font-weight: 600; margin-bottom: 1rem;">My Shared Experiences</h2>
                <% if (!myExps.isEmpty()) { %>
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Company</th>
                                    <th>Role</th>
                                    <th>Interview Date</th>
                                    <th>Rounds</th>
                                    <th>Difficulty</th>
                                    <th>Result</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    // Iterate using Iterator (Module 1 syllabus requirement)
                                    Iterator<InterviewExperience> iter = myExps.iterator();
                                    while (iter.hasNext()) {
                                        InterviewExperience exp = iter.next();

                                        String diffClass = "badge-medium";
                                        if ("Easy".equalsIgnoreCase(exp.getDifficultyLevel())) diffClass = "badge-easy";
                                        else if ("Hard".equalsIgnoreCase(exp.getDifficultyLevel())) diffClass = "badge-hard";

                                        String resultClass = "badge-waiting";
                                        if ("Selected".equalsIgnoreCase(exp.getResult())) resultClass = "badge-selected";
                                        else if ("Rejected".equalsIgnoreCase(exp.getResult())) resultClass = "badge-rejected";
                                %>
                                    <tr>
                                        <td><strong><%= exp.getCompanyName() %></strong></td>
                                        <td><%= exp.getRole() %></td>
                                        <td><%= exp.getInterviewDate() %></td>
                                        <td><%= exp.getRoundsCount() %></td>
                                        <td><span class="badge <%= diffClass %>"><%= exp.getDifficultyLevel() %></span></td>
                                        <td><span class="badge <%= resultClass %>"><%= exp.getResult() %></span></td>
                                        <td>
                                            <a href="<%= request.getContextPath() %>/editExperience.jsp?id=<%= exp.getId() %>" class="btn-primary" style="padding: 0.3rem 0.6rem; font-size: 0.8rem; margin-right: 0.5rem;">Edit</a>
                                            <a href="<%= request.getContextPath() %>/deleteExperience?id=<%= exp.getId() %>" class="btn-danger" style="padding: 0.3rem 0.6rem; font-size: 0.8rem;" onclick="return confirm('Are you sure you want to delete this entry?');">Delete</a>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } else { %>
                    <div style="text-align: center; padding: 3rem; background-color: var(--bg-main); border: 1px dashed var(--border-color); border-radius: 0.5rem; margin-top: 1rem;">
                        <p style="color: var(--text-muted);">You haven't contributed any experiences yet.</p>
                        <a href="<%= request.getContextPath() %>/addExperience.jsp" class="btn-primary" style="margin-top: 1rem;">Add My First Experience</a>
                    </div>
                <% } %>

            </section>

        </div>
    </main>

    <!-- Footer -->
    <footer style="text-align: center; padding: 2rem; border-top: 1px solid var(--border-color); color: var(--text-muted); font-size: 0.9rem; margin-top: 3rem;">
        <p>&copy; 2026 PrepShare Portal. Developed for Advanced Java Curriculum.</p>
    </footer>

</body>
</html>
