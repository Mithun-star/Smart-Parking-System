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
    <title>My Profile - PrepShare Portal</title>
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
                <li><a href="<%= request.getContextPath() %>/dashboard.jsp">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/analytics">Analytics</a></li>
                <li><a href="<%= request.getContextPath() %>/profile.jsp" class="active">Profile</a></li>
                <li><a href="<%= request.getContextPath() %>/logout" class="btn-secondary">Logout</a></li>
            </ul>
        </div>
    </nav>

    <!-- Profile workspace -->
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
                    <li><a href="<%= request.getContextPath() %>/profile.jsp" class="active">Manage Profile</a></li>
                    <li><a href="<%= request.getContextPath() %>/logout" style="color: var(--error);">Logout</a></li>
                </ul>
            </aside>

            <!-- Main Panel -->
            <section class="main-panel">
                <h2 style="font-size: 1.75rem; font-weight: 700; margin-bottom: 0.5rem;">User Profile Account</h2>
                <p style="color: var(--text-muted); margin-bottom: 2rem;">Review your credentials and registration metadata details.</p>

                <div class="table-responsive">
                    <table class="table" style="max-width: 600px; margin-top: 0;">
                        <tbody>
                            <tr>
                                <th style="width: 200px;">Full Name</th>
                                <td><%= currentUser.getFullName() %></td>
                            </tr>
                            <tr>
                                <th>Username</th>
                                <td><%= currentUser.getUsername() %></td>
                            </tr>
                            <tr>
                                <th>Email Address</th>
                                <td><%= currentUser.getEmail() %></td>
                            </tr>
                            <tr>
                                <th>Account Type</th>
                                <td><span class="badge" style="background-color: var(--primary); color: #fff;">Registered User</span></td>
                            </tr>
                            <tr>
                                <th>Member Since</th>
                                <td><%= currentUser.getCreatedAt() %></td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div style="margin-top: 2rem; padding: 1.5rem; background-color: var(--bg-main); border: 1px solid var(--border-color); border-radius: 0.5rem; max-width: 600px;">
                    <h3 style="font-size: 1.1rem; font-weight: 600; margin-bottom: 0.5rem; color: var(--accent);">Need to modify your details?</h3>
                    <p style="color: var(--text-muted); font-size: 0.9rem;">To change your password or update your email, please contact the administrator via the Swing Dashboard tool or raise an IT ticket.</p>
                </div>
            </section>

        </div>
    </main>

    <!-- Footer -->
    <footer style="text-align: center; padding: 2rem; border-top: 1px solid var(--border-color); color: var(--text-muted); font-size: 0.9rem; margin-top: 3rem;">
        <p>&copy; 2026 PrepShare Portal. Developed for Advanced Java Curriculum.</p>
    </footer>

</body>
</html>
