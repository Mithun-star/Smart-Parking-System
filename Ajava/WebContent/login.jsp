<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.interviewportal.model.User" %>
<%@ page import="jakarta.servlet.http.Cookie" %>

<%
    // If user is already logged in, redirect to dashboard
    User currentUser = (User) session.getAttribute("currentUser");
    String adminUser = (String) session.getAttribute("adminUser");
    if (currentUser != null) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        return;
    } else if (adminUser != null) {
        response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp");
        return;
    }

    // Read remember me cookie to pre-fill username
    String prefilledUser = "";
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("rememberedUser".equalsIgnoreCase(cookie.getName())) {
                prefilledUser = cookie.getValue();
                break;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Log In - PrepShare Portal</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <script>
        function validateForm() {
            var username = document.getElementById("username").value.trim();
            var password = document.getElementById("password").value;

            if (username === "" || password === "") {
                alert("Please enter both username and password.");
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
                <li><a href="<%= request.getContextPath() %>/login.jsp" class="active">Login</a></li>
                <li><a href="<%= request.getContextPath() %>/register.jsp" class="btn-primary">Register</a></li>
            </ul>
        </div>
    </nav>

    <!-- Login Card -->
    <main class="container">
        <div class="form-card">
            <h2 class="form-title">Log In to PrepShare</h2>
            <p class="form-subtitle">Access your account and shared experiences</p>

            <% 
                // Display messages if present
                String errorMsg = (String) request.getAttribute("errorMsg");
                String msg = request.getParameter("msg");
                
                if (errorMsg != null) {
            %>
                <div class="alert alert-danger"><%= errorMsg %></div>
            <% 
                }
                if (msg != null) {
                    if (msg.equalsIgnoreCase("registration_success")) {
            %>
                        <div class="alert alert-success">Registration successful! Please login below.</div>
            <%
                    } else if (msg.equalsIgnoreCase("logged_out")) {
            %>
                        <div class="alert alert-success">You have successfully logged out.</div>
            <%
                    }
                }
            %>

            <form action="<%= request.getContextPath() %>/login" method="POST" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="username" class="form-label">Username</label>
                    <input type="text" id="username" name="username" class="form-control" 
                           placeholder="Enter username" value="<%= prefilledUser %>" required>
                </div>

                <div class="form-group">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" id="password" name="password" class="form-control" 
                           placeholder="Enter password" required>
                </div>

                <div class="form-group">
                    <label for="role" class="form-label">Login As</label>
                    <select id="role" name="role" class="form-control" style="background-color: var(--bg-main);">
                        <option value="user">User</option>
                        <option value="admin">Administrator</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-check">
                        <input type="checkbox" name="rememberMe" <%= !prefilledUser.isEmpty() ? "checked" : "" %>>
                        <span class="form-label" style="display: inline; margin: 0;">Remember Me</span>
                    </label>
                </div>

                <button type="submit" class="btn-primary" style="width: 100%; justify-content: center;">
                    Log In
                </button>
            </form>

            <div style="text-align: center; margin-top: 1.5rem; font-size: 0.9rem; color: var(--text-muted);">
                Don't have an account? <a href="<%= request.getContextPath() %>/register.jsp">Register Here</a>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer style="text-align: center; padding: 2rem; border-top: 1px solid var(--border-color); color: var(--text-muted); font-size: 0.9rem; margin-top: 3rem;">
        <p>&copy; 2026 PrepShare Portal. Developed for Advanced Java Curriculum.</p>
    </footer>

</body>
</html>
