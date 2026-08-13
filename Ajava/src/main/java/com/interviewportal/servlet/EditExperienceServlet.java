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
import java.sql.Date;

@WebServlet("/editExperience")
public class EditExperienceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ExperienceService experienceService;

    @Override
    public void init() throws ServletException {
        super.init();
        experienceService = new ExperienceService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");

        String idStr = request.getParameter("id");
        String companyName = request.getParameter("companyName");
        String role = request.getParameter("role");
        String interviewDateStr = request.getParameter("interviewDate");
        String roundsCountStr = request.getParameter("roundsCount");
        String questionsAsked = request.getParameter("questionsAsked");
        String difficultyLevel = request.getParameter("difficultyLevel");
        String result = request.getParameter("result");
        String tips = request.getParameter("tips");

        int id = 0;
        int roundsCount = 1;
        Date interviewDate = null;
        try {
            if (idStr != null) {
                id = Integer.parseInt(idStr);
            }
            if (roundsCountStr != null) {
                roundsCount = Integer.parseInt(roundsCountStr);
            }
            if (interviewDateStr != null && !interviewDateStr.isEmpty()) {
                interviewDate = Date.valueOf(interviewDateStr);
            }
        } catch (NumberFormatException | IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp?msg=edit_failed");
            return;
        }

        // Fetch experience and verify ownership
        InterviewExperience existingExp = experienceService.getExperienceById(id);
        if (existingExp == null || existingExp.getUserId() != currentUser.getId()) {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp?msg=unauthorized");
            return;
        }

        existingExp.setCompanyName(companyName);
        existingExp.setRole(role);
        existingExp.setInterviewDate(interviewDate);
        existingExp.setRoundsCount(roundsCount);
        existingExp.setQuestionsAsked(questionsAsked);
        existingExp.setDifficultyLevel(difficultyLevel);
        existingExp.setResult(result);
        existingExp.setTips(tips);

        boolean success = experienceService.updateExperience(existingExp);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp?msg=edit_success");
        } else {
            request.setAttribute("errorMsg", "Failed to update experience.");
            request.getRequestDispatcher("/editExperience.jsp?id=" + id).forward(request, response);
        }
    }
}
