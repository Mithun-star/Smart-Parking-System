package com.interviewportal.servlet;

import com.interviewportal.model.InterviewExperience;
import com.interviewportal.model.User;
import com.interviewportal.service.ExperienceService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/deleteExperience")
public class DeleteExperienceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ExperienceService experienceService;

    @Override
    public void init() throws ServletException {
        super.init();
        experienceService = new ExperienceService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Also support GET for simple link-based deletions from dashboard, if needed
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null) {
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
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp?msg=delete_failed");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        String adminUser = (String) session.getAttribute("adminUser");

        boolean isAuthorized = false;

        // If admin is logged in
        if (adminUser != null) {
            isAuthorized = true;
        } else if (currentUser != null) {
            // Verify ownership
            InterviewExperience exp = experienceService.getExperienceById(id);
            if (exp != null && exp.getUserId() == currentUser.getId()) {
                isAuthorized = true;
            }
        }

        if (!isAuthorized) {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp?msg=unauthorized");
            return;
        }

        boolean success = experienceService.deleteExperience(id);

        if (success) {
            if (adminUser != null) {
                response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?msg=delete_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp?msg=delete_success");
            }
        } else {
            if (adminUser != null) {
                response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?msg=delete_failed");
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp?msg=delete_failed");
            }
        }
    }
}
