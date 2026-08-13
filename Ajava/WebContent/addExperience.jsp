<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.interviewportal.model.User" %>

<%
    // Session Verification
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Experience - PrepShare Portal</title>
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
                    <li><a href="<%= request.getContextPath() %>/addExperience.jsp" class="active">Add Experience</a></li>
                    <li><a href="<%= request.getContextPath() %>/search?company=&role=&difficulty=All&result=All">Search Portal</a></li>
                    <li><a href="<%= request.getContextPath() %>/analytics">Analytics Summary</a></li>
                    <li><a href="<%= request.getContextPath() %>/profile.jsp">Manage Profile</a></li>
                    <li><a href="<%= request.getContextPath() %>/logout" style="color: var(--error);">Logout</a></li>
                </ul>
            </aside>

            <!-- Form Workspace -->
            <section class="main-panel">
                <h2 style="font-size: 1.75rem; font-weight: 700; margin-bottom: 0.5rem;">Share Your Interview Experience</h2>
                <p style="color: var(--text-muted); margin-bottom: 2rem;">Help juniors prepare by sharing questions asked, rounds count, and tips.</p>

                <% 
                    String errorMsg = (String) request.getAttribute("errorMsg");
                    if (errorMsg != null) {
                %>
                    <div class="alert alert-danger"><%= errorMsg %></div>
                <% } %>

                <form action="<%= request.getContextPath() %>/addExperience" method="POST" onsubmit="return validateForm()">
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div class="form-group">
                            <label for="companyName" class="form-label">Company Name *</label>
                            <input type="text" id="companyName" name="companyName" class="form-control" placeholder="e.g. Google" required>
                        </div>
                        <div class="form-group">
                            <label for="role" class="form-label">Role / Job Title *</label>
                            <input type="text" id="role" name="role" class="form-control" placeholder="e.g. Software Engineer SDE-1" required>
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div class="form-group">
                            <label for="interviewDate" class="form-label">Interview Date *</label>
                            <input type="date" id="interviewDate" name="interviewDate" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="roundsCount" class="form-label">Number of Rounds *</label>
                            <input type="number" id="roundsCount" name="roundsCount" class="form-control" min="1" max="10" value="3" required>
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div class="form-group">
                            <label for="difficultyLevel" class="form-label">Difficulty Level</label>
                            <select id="difficultyLevel" name="difficultyLevel" class="form-control" style="background-color: var(--bg-main);">
                                <option value="Easy">Easy</option>
                                <option value="Medium" selected>Medium</option>
                                <option value="Hard">Hard</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="result" class="form-label">Interview Result</label>
                            <select id="result" name="result" class="form-control" style="background-color: var(--bg-main);">
                                <option value="Selected" selected>Selected</option>
                                <option value="Rejected">Rejected</option>
                                <option value="Waiting">Waiting</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="questionsAsked" class="form-label">Questions Asked * (Min 20 characters)</label>
                        <textarea id="questionsAsked" name="questionsAsked" class="form-control" 
                                  placeholder="List coding exercises, system architecture issues, or HR topics asked in rounds..." required></textarea>
                    </div>

                    <div class="form-group">
                        <label for="tips" class="form-label">Preparation Tips for Juniors</label>
                        <textarea id="tips" name="tips" class="form-control" 
                                  placeholder="What topics should they focus on? What books or resources did you use?"></textarea>
                    </div>

                    <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                        <button type="submit" class="btn-primary">Publish Experience</button>
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
