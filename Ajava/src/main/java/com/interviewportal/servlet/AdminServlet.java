package com.interviewportal.servlet;

import com.interviewportal.service.AnalyticsService;
import com.interviewportal.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserService userService;
    private AnalyticsService analyticsService;

    @Override
    public void init() throws ServletException {
        super.init();
        userService = new UserService();
        analyticsService = new AnalyticsService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp");
            return;
        }

        if (action.equalsIgnoreCase("deleteUser")) {
            String userIdStr = request.getParameter("userId");
            try {
                int userId = Integer.parseInt(userIdStr);
                boolean success = userService.deleteUser(userId);
                if (success) {
                    analyticsService.logEvent("ADMIN_DELETE_USER", "Admin deleted user ID: " + userId);
                    response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?msg=delete_user_success");
                } else {
                    response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?msg=delete_user_failed");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?msg=invalid_id");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp");
        }
    }
}
