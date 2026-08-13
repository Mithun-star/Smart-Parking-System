<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.interviewportal.model.User" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    String adminUser = (String) session.getAttribute("adminUser");

    if (currentUser == null && adminUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Read attributes set by AnalyticsServlet
    Integer totalExperiences = (Integer) request.getAttribute("totalExperiences");
    Double selectionRate = (Double) request.getAttribute("selectionRate");
    Map<String, Integer> companyCounts = (Map<String, Integer>) request.getAttribute("companyCounts");
    List<Map.Entry<String, Integer>> topCompanies = (List<Map.Entry<String, Integer>>) request.getAttribute("topCompanies");
    Map<String, Integer> topTopics = (Map<String, Integer>) request.getAttribute("topTopics");
    String reportText = (String) request.getAttribute("reportText");

    // If attributes are null, redirect through the servlet to load them
    if (totalExperiences == null) {
        response.sendRedirect(request.getContextPath() + "/analytics");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics Dashboard - PrepShare Portal</title>
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
                <% if (currentUser != null) { %>
                    <li><a href="<%= request.getContextPath() %>/dashboard.jsp">Dashboard</a></li>
                    <li><a href="<%= request.getContextPath() %>/analytics" class="active">Analytics</a></li>
                    <li><a href="<%= request.getContextPath() %>/profile.jsp">Profile</a></li>
                    <li><a href="<%= request.getContextPath() %>/logout" class="btn-secondary">Logout</a></li>
                <% } else if (adminUser != null) { %>
                    <li><a href="<%= request.getContextPath() %>/adminDashboard.jsp">Admin Panel</a></li>
                    <li><a href="<%= request.getContextPath() %>/analytics" class="active">Analytics</a></li>
                    <li><a href="<%= request.getContextPath() %>/logout" class="btn-secondary">Logout</a></li>
                <% } %>
            </ul>
        </div>
    </nav>

    <!-- Analytics workspace -->
    <main class="container" style="margin-top: 2.5rem; margin-bottom: 5rem;">
        
        <div class="dashboard-grid">
            
            <!-- Sidebar -->
            <aside class="sidebar">
                <h3 style="font-size: 1rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 1rem; padding-left: 1rem;">Menu</h3>
                <ul class="sidebar-menu">
                    <% if (currentUser != null) { %>
                        <li><a href="<%= request.getContextPath() %>/dashboard.jsp">My Dashboard</a></li>
                        <li><a href="<%= request.getContextPath() %>/addExperience.jsp">Add Experience</a></li>
                    <% } else if (adminUser != null) { %>
                        <li><a href="<%= request.getContextPath() %>/adminDashboard.jsp">Admin Dashboard</a></li>
                    <% } %>
                    <li><a href="<%= request.getContextPath() %>/search?company=&role=&difficulty=All&result=All">Search Portal</a></li>
                    <li><a href="<%= request.getContextPath() %>/analytics" class="active">Analytics Summary</a></li>
                    <% if (currentUser != null) { %>
                        <li><a href="<%= request.getContextPath() %>/profile.jsp">Manage Profile</a></li>
                    <% } %>
                    <li><a href="<%= request.getContextPath() %>/logout" style="color: var(--error);">Logout</a></li>
                </ul>
            </aside>

            <!-- Main Content Area -->
            <section class="main-panel">
                <h1 style="font-size: 2rem; font-weight: 700; margin-bottom: 0.5rem;">System Analytics Dashboard</h1>
                <p style="color: var(--text-muted); margin-bottom: 2rem;">Real-time metrics, selection trends, and key topic indicators compiled across the portal.</p>

                <!-- Core metrics -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-val"><%= totalExperiences %></div>
                        <div class="stat-label">Total Contributions</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-val" style="color: var(--accent);"><%= selectionRate %>%</div>
                        <div class="stat-label">System Selection Rate</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-val" style="color: #60a5fa;"><%= companyCounts.size() %></div>
                        <div class="stat-label">Unique Companies</div>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin-top: 2rem;">
                    
                    <!-- Top Companies counts (HashMap sorted by count descending) -->
                    <div>
                        <h2 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem; color: var(--text-main);">Most Frequent Companies</h2>
                        <div class="table-responsive" style="margin-top: 0;">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Company Name</th>
                                        <th>Submissions Count</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                        if (topCompanies != null && !topCompanies.isEmpty()) {
                                            Iterator<Map.Entry<String, Integer>> companyIter = topCompanies.iterator();
                                            while (companyIter.hasNext()) {
                                                Map.Entry<String, Integer> entry = companyIter.next();
                                    %>
                                        <tr>
                                            <td><strong><%= entry.getKey() %></strong></td>
                                            <td><%= entry.getValue() %></td>
                                        </tr>
                                    <% 
                                            }
                                        } else {
                                    %>
                                        <tr><td colspan="2" style="color: var(--text-muted);">No company data found.</td></tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Topic Frequency (Analyzed by String parsing of questions asked) -->
                    <div>
                        <h2 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem; color: var(--text-main);">Most Frequently Asked Topics</h2>
                        <div class="table-responsive" style="margin-top: 0;">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Core Syllabus Topic</th>
                                        <th>Matches Detected</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                        if (topTopics != null && !topTopics.isEmpty()) {
                                            for (Map.Entry<String, Integer> entry : topTopics.entrySet()) {
                                    %>
                                        <tr>
                                            <td><span class="badge" style="background-color: var(--border-color); color: var(--text-main); font-weight: 500; font-size: 0.85rem;"><%= entry.getKey() %></span></td>
                                            <td><%= entry.getValue() %> interview(s)</td>
                                        </tr>
                                    <% 
                                            }
                                        } else {
                                    %>
                                        <tr><td colspan="2" style="color: var(--text-muted);">No matching topics identified.</td></tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </div>

                <!-- Alphabetical company table (TreeMap sorted) -->
                <div style="margin-top: 3rem;">
                    <h2 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem;">Complete Directory Listing (Alphabetical)</h2>
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Company</th>
                                    <th>Submissions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    Iterator<Map.Entry<String, Integer>> alphabeticIter = companyCounts.entrySet().iterator();
                                    while (alphabeticIter.hasNext()) {
                                        Map.Entry<String, Integer> entry = alphabeticIter.next();
                                %>
                                    <tr>
                                        <td><strong><%= entry.getKey() %></strong></td>
                                        <td><%= entry.getValue() %> experience(s) shared</td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Text report generated using StringBuffer thread-safe code -->
                <div style="margin-top: 3rem;">
                    <h2 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 0.5rem;">System Console Report</h2>
                    <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1rem;">Automated thread-safe console report summary generated via `StringBuffer` (Advanced Java coverage):</p>
                    <pre class="report-box"><%= reportText %></pre>
                </div>

            </section>

        </div>

    </main>

    <!-- Footer -->
    <footer style="text-align: center; padding: 2rem; border-top: 1px solid var(--border-color); color: var(--text-muted); font-size: 0.9rem;">
        <p>&copy; 2026 PrepShare Portal. Developed for Advanced Java Curriculum.</p>
    </footer>

</body>
</html>
