<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.interviewportal.model.User" %>
<%@ page import="com.interviewportal.model.InterviewExperience" %>
<%@ page import="com.interviewportal.service.ExperienceService" %>

<%
    // Session Verification
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    int id = 0;
    try {
        if (idStr != null) {
            id = Integer.parseInt(idStr);
        }
    } catch (NumberFormatException e) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        return;
    }

    ExperienceService expService = new ExperienceService();
    InterviewExperience exp = expService.getExperienceById(id);

    // Ownership check
    if (exp == null || exp.getUserId() != currentUser.getId()) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp?msg=unauthorized");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Experience - PrepShare Portal</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <script>
        function validateForm() {
            var company = document.getElementById("companyName").value.trim();
            var role = document.getElementById("role").value.trim();
            var rounds = document.getElementById("roundsCount").value;
            var date = document.getElementById("interviewDate").value;
            var questions = document.getElementById("questionsAsked").value.trim();

            if (company === "" || role === "" || date === "" || questions === "") {
                alert("Please fill in all required fields.");
                return false;
            }

            var roundsNum = parseInt(rounds);
            if (isNaN(roundsNum) || roundsNum < 1 || roundsNum > 10) {
                alert("Number of rounds must be between 1 and 10.");
                return false;
            }

            if (questions.length < 20) {
                alert("Please provide more details about the questions asked (min 20 characters).");
                return false;
            }

            return true;
        }
    </script>
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

    <!-- Workspace -->
    <main class="container">
        <div class="dashboard-grid">
            
            <!-- Sidebar Navigation -->
            <aside class="sidebar">
                <h3 style="font-size: 1rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 1rem; padding-left: 1rem;">Menu</h3>
                <ul class="sidebar-menu">
                    <li><a href="<%= request.getContextPath() %>/dashboard.jsp">My Dashboard</a></li>
                    <li><a href="<%= request.getContextPath() %>/addExperience.jsp">Add Experience</a></li>
                    <li><a href="<%= request.getContextPath() %>/search?company=&role=&difficulty=All&result=All">Search Portal</a></li>
                    <li><a href="<%= request.getContextPath() %>/analytics">Analytics Summary</a></li>
                    <li><a href="<%= request.getContextPath() %>/profile.jsp">Manage Profile</a></li>
                    <li><a href="<%= request.getContextPath() %>/logout" style="color: var(--error);">Logout</a></li>
                </ul>
            </aside>

            <!-- Edit Form Workspace -->
            <section class="main-panel">
                <h2 style="font-size: 1.75rem; font-weight: 700; margin-bottom: 0.5rem;">Edit Interview Experience</h2>
                <p style="color: var(--text-muted); margin-bottom: 2rem;">Modify details of your published interview experience.</p>

                <% 
                    String errorMsg = (String) request.getAttribute("errorMsg");
                    if (errorMsg != null) {
                %>
                    <div class="alert alert-danger"><%= errorMsg %></div>
                <% } %>

                <form action="<%= request.getContextPath() %>/editExperience" method="POST" onsubmit="return validateForm()">
                    
                    <!-- Hidden ID input field -->
                    <input type="hidden" name="id" value="<%= exp.getId() %>">

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div class="form-group">
                            <label for="companyName" class="form-label">Company Name *</label>
                            <input type="text" id="companyName" name="companyName" class="form-control" 
                                   value="<%= exp.getCompanyName() %>" required>
                        </div>
                        <div class="form-group">
                            <label for="role" class="form-label">Role / Job Title *</label>
                            <input type="text" id="role" name="role" class="form-control" 
                                   value="<%= exp.getRole() %>" required>
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div class="form-group">
                            <label for="interviewDate" class="form-label">Interview Date *</label>
                            <input type="date" id="interviewDate" name="interviewDate" class="form-control" 
                                   value="<%= exp.getInterviewDate() %>" required>
                        </div>
                        <div class="form-group">
                            <label for="roundsCount" class="form-label">Number of Rounds *</label>
                            <input type="number" id="roundsCount" name="roundsCount" class="form-control" 
                                   min="1" max="10" value="<%= exp.getRoundsCount() %>" required>
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div class="form-group">
                            <label for="difficultyLevel" class="form-label">Difficulty Level</label>
                            <select id="difficultyLevel" name="difficultyLevel" class="form-control" style="background-color: var(--bg-main);">
                                <option value="Easy" <%= "Easy".equalsIgnoreCase(exp.getDifficultyLevel()) ? "selected" : "" %>>Easy</option>
                                <option value="Medium" <%= "Medium".equalsIgnoreCase(exp.getDifficultyLevel()) ? "selected" : "" %>>Medium</option>
                                <option value="Hard" <%= "Hard".equalsIgnoreCase(exp.getDifficultyLevel()) ? "selected" : "" %>>Hard</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="result" class="form-label">Interview Result</label>
                            <select id="result" name="result" class="form-control" style="background-color: var(--bg-main);">
                                <option value="Selected" <%= "Selected".equalsIgnoreCase(exp.getResult()) ? "selected" : "" %>>Selected</option>
                                <option value="Rejected" <%= "Rejected".equalsIgnoreCase(exp.getResult()) ? "selected" : "" %>>Rejected</option>
                                <option value="Waiting" <%= "Waiting".equalsIgnoreCase(exp.getResult()) ? "selected" : "" %>>Waiting</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="questionsAsked" class="form-label">Questions Asked *</label>
                        <textarea id="questionsAsked" name="questionsAsked" class="form-control" required><%= exp.getQuestionsAsked() %></textarea>
                    </div>

                    <div class="form-group">
                        <label for="tips" class="form-label">Preparation Tips for Juniors</label>
                        <textarea id="tips" name="tips" class="form-control"><%= exp.getTips() != null ? exp.getTips() : "" %></textarea>
                    </div>

                    <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                        <button type="submit" class="btn-primary">Update Experience</button>
                        <a href="<%= request.getContextPath() %>/dashboard.jsp" class="btn-secondary">Cancel</a>
                    </div>

                </form>

            </section>

        </div>
    </main>

    <!-- Footer -->
    <footer style="text-align: center; padding: 2rem; border-top: 1px solid var(--border-color); color: var(--text-muted); font-size: 0.9rem; margin-top: 3rem;">
        <p>&copy; 2026 PrepShare Portal. Developed for Advanced Java Curriculum.</p>
    </footer>

</body>
</html>
