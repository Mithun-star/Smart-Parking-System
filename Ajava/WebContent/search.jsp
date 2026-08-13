<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.interviewportal.model.User" %>
<%@ page import="com.interviewportal.model.InterviewExperience" %>
<%@ page import="com.interviewportal.service.ExperienceService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    String adminUser = (String) session.getAttribute("adminUser");

    // Fetch search results set by servlet, or load all if null (first access)
    List<InterviewExperience> results = (List<InterviewExperience>) request.getAttribute("searchResults");
    
    String cParam = (String) request.getAttribute("paramCompany");
    String rParam = (String) request.getAttribute("paramRole");
    String dParam = (String) request.getAttribute("paramDifficulty");
    String resParam = (String) request.getAttribute("paramResult");
    String sParam = (String) request.getAttribute("paramSort");

    if (cParam == null) cParam = "";
    if (rParam == null) rParam = "";
    if (dParam == null) dParam = "All";
    if (resParam == null) resParam = "All";
    if (sParam == null) sParam = "date";

    if (results == null) {
        // Fallback: load all experiences if accessed directly
        ExperienceService service = new ExperienceService();
        results = service.searchExperiences(cParam, rParam, dParam, resParam);
        service.sortExperiences(results, sParam);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Experiences - PrepShare Portal</title>
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
                <li><a href="<%= request.getContextPath() %>/search?company=&role=&difficulty=All&result=All" class="active">Browse All</a></li>
                <% if (currentUser != null) { %>
                    <li><a href="<%= request.getContextPath() %>/dashboard.jsp">Dashboard</a></li>
                    <li><a href="<%= request.getContextPath() %>/analytics">Analytics</a></li>
                    <li><a href="<%= request.getContextPath() %>/profile.jsp">Profile</a></li>
                    <li><a href="<%= request.getContextPath() %>/logout" class="btn-secondary">Logout</a></li>
                <% } else if (adminUser != null) { %>
                    <li><a href="<%= request.getContextPath() %>/adminDashboard.jsp">Admin Panel</a></li>
                    <li><a href="<%= request.getContextPath() %>/analytics">Analytics</a></li>
                    <li><a href="<%= request.getContextPath() %>/logout" class="btn-secondary">Logout</a></li>
                <% } else { %>
                    <li><a href="<%= request.getContextPath() %>/login.jsp">Login</a></li>
                    <li><a href="<%= request.getContextPath() %>/register.jsp" class="btn-primary">Register</a></li>
                <% } %>
            </ul>
        </div>
    </nav>

    <!-- Search Section -->
    <main class="container" style="margin-top: 2.5rem; margin-bottom: 5rem;">
        
        <!-- Filters Card -->
        <div class="main-panel" style="margin-bottom: 2rem;">
            <h2 style="font-size: 1.5rem; font-weight: 700; margin-bottom: 1.5rem;">Filter Interview Experiences</h2>
            
            <form action="<%= request.getContextPath() %>/search" method="GET">
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;">
                    
                    <div class="form-group">
                        <label for="company" class="form-label">Company Name</label>
                        <input type="text" id="company" name="company" class="form-control" 
                               placeholder="e.g. Google" value="<%= cParam %>">
                    </div>

                    <div class="form-group">
                        <label for="role" class="form-label">Role</label>
                        <input type="text" id="role" name="role" class="form-control" 
                               placeholder="e.g. SDE" value="<%= rParam %>">
                    </div>

                    <div class="form-group">
                        <label for="difficulty" class="form-label">Difficulty</label>
                        <select id="difficulty" name="difficulty" class="form-control" style="background-color: var(--bg-main);">
                            <option value="All" <%= "All".equalsIgnoreCase(dParam) ? "selected" : "" %>>All Levels</option>
                            <option value="Easy" <%= "Easy".equalsIgnoreCase(dParam) ? "selected" : "" %>>Easy</option>
                            <option value="Medium" <%= "Medium".equalsIgnoreCase(dParam) ? "selected" : "" %>>Medium</option>
                            <option value="Hard" <%= "Hard".equalsIgnoreCase(dParam) ? "selected" : "" %>>Hard</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="result" class="form-label">Result</label>
                        <select id="result" name="result" class="form-control" style="background-color: var(--bg-main);">
                            <option value="All" <%= "All".equalsIgnoreCase(resParam) ? "selected" : "" %>>All Results</option>
                            <option value="Selected" <%= "Selected".equalsIgnoreCase(resParam) ? "selected" : "" %>>Selected</option>
                            <option value="Rejected" <%= "Rejected".equalsIgnoreCase(resParam) ? "selected" : "" %>>Rejected</option>
                            <option value="Waiting" <%= "Waiting".equalsIgnoreCase(resParam) ? "selected" : "" %>>Waiting</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="sort" class="form-label">Sort By</label>
                        <select id="sort" name="sort" class="form-control" style="background-color: var(--bg-main);">
                            <option value="date" <%= "date".equalsIgnoreCase(sParam) ? "selected" : "" %>>Interview Date</option>
                            <option value="rounds" <%= "rounds".equalsIgnoreCase(sParam) ? "selected" : "" %>>Rounds Count</option>
                            <option value="difficulty" <%= "difficulty".equalsIgnoreCase(sParam) ? "selected" : "" %>>Difficulty</option>
                        </select>
                    </div>

                </div>

                <div style="margin-top: 1.5rem; display: flex; gap: 1rem;">
                    <button type="submit" class="btn-primary">Apply Filters</button>
                    <a href="<%= request.getContextPath() %>/search?company=&role=&difficulty=All&result=All" class="btn-secondary" style="text-align: center;">Reset</a>
                </div>
            </form>
        </div>

        <!-- Search Results Count Banner -->
        <h3 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem;"><%= results.size() %> Matching Experiences Found</h3>

        <!-- Search Grid -->
        <% if (!results.isEmpty()) { %>
            <div class="exp-grid">
                <% 
                    // Iterate using Iterator (Module 1)
                    Iterator<InterviewExperience> iter = results.iterator();
                    while (iter.hasNext()) {
                        InterviewExperience exp = iter.next();

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
                            <div class="exp-body">
                                <strong>Questions Asked:</strong>
                                <p style="white-space: pre-line; margin-top: 0.25rem; font-size: 0.92rem;"><%= exp.getQuestionsAsked() %></p>
                                
                                <% if (exp.getTips() != null && !exp.getTips().trim().isEmpty()) { %>
                                    <div style="margin-top: 1rem; padding-top: 0.75rem; border-top: 1px dashed var(--border-color);">
                                        <strong>Preparation Tips:</strong>
                                        <p style="white-space: pre-line; margin-top: 0.25rem; font-size: 0.9rem; color: var(--text-muted);"><%= exp.getTips() %></p>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                        <div class="exp-footer">
                            <span class="badge <%= resultClass %>"><%= exp.getResult() %></span>
                            <span class="exp-meta">By <%= exp.getUsername() %> on <%= exp.getInterviewDate() %></span>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div style="text-align: center; padding: 4rem; background-color: var(--bg-surface); border: 1px dashed var(--border-color); border-radius: 1rem;">
                <p style="color: var(--text-muted); font-size: 1.1rem;">No experiences match your filter search parameters.</p>
                <a href="<%= request.getContextPath() %>/search?company=&role=&difficulty=All&result=All" class="btn-primary" style="margin-top: 1rem;">Reset Search Filters</a>
            </div>
        <% } %>

    </main>

    <!-- Footer -->
    <footer style="text-align: center; padding: 2rem; border-top: 1px solid var(--border-color); color: var(--text-muted); font-size: 0.9rem;">
        <p>&copy; 2026 PrepShare Portal. Developed for Advanced Java Curriculum.</p>
    </footer>

</body>
</html>
