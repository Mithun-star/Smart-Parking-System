<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Error - PrepShare Portal</title>
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
            </ul>
        </div>
    </nav>

    <!-- Error message card -->
    <main class="container" style="text-align: center; margin-top: 5rem;">
        <div class="form-card" style="max-width: 650px;">
            <div style="font-size: 4rem; color: var(--error); margin-bottom: 1rem;">⚠️</div>
            <h2 class="form-title" style="color: var(--error);">Internal Server Error (500)</h2>
            <p class="form-subtitle">An unexpected exception occurred on the server while executing your request.</p>

            <% if (exception != null) { %>
                <div style="text-align: left; background-color: var(--bg-main); border: 1px solid var(--border-color); border-radius: 0.5rem; padding: 1rem; overflow-x: auto; margin-bottom: 2rem;">
                    <strong style="color: var(--text-main);">Error Message:</strong>
                    <p style="color: var(--text-muted); font-family: monospace; font-size: 0.9rem; margin-top: 0.25rem;"><%= exception.getMessage() %></p>
                    
                    <strong style="color: var(--text-main); display: block; margin-top: 1rem;">StackTrace:</strong>
                    <pre style="color: #fca5a5; font-family: monospace; font-size: 0.8rem; margin-top: 0.25rem; white-space: pre-wrap; line-height: 1.4;"><%
                        java.io.StringWriter sw = new java.io.StringWriter();
                        java.io.PrintWriter pw = new java.io.PrintWriter(sw);
                        exception.printStackTrace(pw);
                        out.print(sw.toString());
                    %></pre>
                </div>
            <% } %>

            <a href="<%= request.getContextPath() %>/index.jsp" class="btn-primary" style="margin-top: 1rem;">Go Back Home</a>
        </div>
    </main>

</body>
</html>
