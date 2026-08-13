<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.interviewportal.model.User" %>

<%
    // If user is already logged in, redirect to dashboard
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser != null) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - PrepShare Portal</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <script>
        function validateForm() {
            var username = document.getElementById("username").value.trim();
            var email = document.getElementById("email").value.trim();
            var password = document.getElementById("password").value;
            var fullName = document.getElementById("fullName").value.trim();
            var confirmPassword = document.getElementById("confirmPassword").value;

            if (username === "" || email === "" || password === "" || fullName === "") {
                alert("All fields are required.");
                return false;
            }

            if (username.length < 4) {
                alert("Username must be at least 4 characters long.");
                return false;
            }

            // Simple email validation regex
            var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                alert("Please enter a valid email address.");
                return false;
            }

            if (password.length < 6) {
                alert("Password must be at least 6 characters long.");
                return false;
            }

            if (password !== confirmPassword) {
                alert("Passwords do not match.");
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
                <li><a href="<%= request.getContextPath() %>/login.jsp">Login</a></li>
                <li><a href="<%= request.getContextPath() %>/register.jsp" class="active btn-primary">Register</a></li>
            </ul>
        </div>
    </nav>

    <!-- Registration Card -->
    <main class="container">
        <div class="form-card">
            <h2 class="form-title">Join PrepShare</h2>
            <p class="form-subtitle">Start sharing your interview journeys today</p>

            <% 
                // Display error message if present
                String errorMsg = (String) request.getAttribute("errorMsg");
                if (errorMsg != null) {
            %>
                <div class="alert alert-danger"><%= errorMsg %></div>
            <% } %>

            <form action="<%= request.getContextPath() %>/register" method="POST" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="fullName" class="form-label">Full Name</label>
                    <input type="text" id="fullName" name="fullName" class="form-control" placeholder="e.g. Jane Doe" required>
                </div>

                <div class="form-group">
                    <label for="username" class="form-label">Username</label>
                    <input type="text" id="username" name="username" class="form-control" placeholder="e.g. janedoe" required>
                </div>

                <div class="form-group">
                    <label for="email" class="form-label">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" placeholder="e.g. jane@example.com" required>
                </div>

                <div class="form-group">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" id="password" name="password" class="form-control" placeholder="Min. 6 characters" required>
                </div>

                <div class="form-group">
                    <label for="confirmPassword" class="form-label">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" placeholder="Re-enter password" required>
                </div>

                <button type="submit" class="btn-primary" style="width: 100%; justify-content: center; margin-top: 1rem;">
                    Create Account
                </button>
            </form>

            <div style="text-align: center; margin-top: 1.5rem; font-size: 0.9rem; color: var(--text-muted);">
                Already have an account? <a href="<%= request.getContextPath() %>/login.jsp">Log In</a>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer style="text-align: center; padding: 2rem; border-top: 1px solid var(--border-color); color: var(--text-muted); font-size: 0.9rem; margin-top: 3rem;">
        <p>&copy; 2026 PrepShare Portal. Developed for Advanced Java Curriculum.</p>
    </footer>

</body>
</html>
