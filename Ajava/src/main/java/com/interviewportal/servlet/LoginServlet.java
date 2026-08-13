package com.interviewportal.servlet;

import com.interviewportal.model.User;
import com.interviewportal.service.AnalyticsService;
import com.interviewportal.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserService userService;
    private AnalyticsService analyticsService;

    @Override
    public void init() throws ServletException {
        super.init();
        userService = new UserService();
        analyticsService = new AnalyticsService();
        System.out.println("LoginServlet Initialized.");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");
        String role = request.getParameter("role"); // "user" or "admin"

        if (role != null && role.equalsIgnoreCase("admin")) {
            // Admin Authentication
            boolean isAdmin = userService.authenticateAdmin(username, password);
            if (isAdmin) {
                HttpSession session = request.getSession(true);
                session.setAttribute("adminUser", username);
                session.setAttribute("role", "admin");

                // Cookie-based Remember Me for Admin
                handleRememberMeCookie(response, username, rememberMe);

                analyticsService.logEvent("ADMIN_LOGIN", "Admin " + username + " logged in successfully.");
                response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp");
                return;
            }
        } else {
            // Regular User Authentication
            User user = userService.authenticateUser(username, password);
            if (user != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("currentUser", user);
                session.setAttribute("role", "user");

                // Cookie-based Remember Me
                handleRememberMeCookie(response, username, rememberMe);

                analyticsService.logEvent("USER_LOGIN", "User " + username + " logged in successfully.");
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
                return;
            }
        }

        // Authentication failed
        request.setAttribute("errorMsg", "Invalid username, password, or role choice.");
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    private void handleRememberMeCookie(HttpServletResponse response, String username, String rememberMe) {
        if (rememberMe != null && rememberMe.equalsIgnoreCase("on")) {
            // Set remember me cookie for 30 days
            Cookie userCookie = new Cookie("rememberedUser", username);
            userCookie.setMaxAge(30 * 24 * 60 * 60); // 30 days
            userCookie.setPath("/");
            response.addCookie(userCookie);
        } else {
            // Clear remember me cookie
            Cookie userCookie = new Cookie("rememberedUser", "");
            userCookie.setMaxAge(0);
            userCookie.setPath("/");
            response.addCookie(userCookie);
        }
    }
}
