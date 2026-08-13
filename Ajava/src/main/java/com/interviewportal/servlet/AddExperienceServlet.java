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

@WebServlet("/addExperience")
public class AddExperienceServlet extends HttpServlet {
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

        String companyName = request.getParameter("companyName");
        String role = request.getParameter("role");
        String interviewDateStr = request.getParameter("interviewDate");
        String roundsCountStr = request.getParameter("roundsCount");
        String questionsAsked = request.getParameter("questionsAsked");
        String difficultyLevel = request.getParameter("difficultyLevel");
        String result = request.getParameter("result");
        String tips = request.getParameter("tips");

        Date interviewDate = null;
        int roundsCount = 1;
        try {
            if (interviewDateStr != null && !interviewDateStr.isEmpty()) {
                interviewDate = Date.valueOf(interviewDateStr);
            } else {
                interviewDate = new Date(System.currentTimeMillis());
            }
            if (roundsCountStr != null && !roundsCountStr.isEmpty()) {
                roundsCount = Integer.parseInt(roundsCountStr);
            }
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMsg", "Invalid date format or round count.");
            request.getRequestDispatcher("/addExperience.jsp").forward(request, response);
            return;
        }

        InterviewExperience exp = new InterviewExperience();
        exp.setUserId(currentUser.getId());
        exp.setCompanyName(companyName);
        exp.setRole(role);
        exp.setInterviewDate(interviewDate);
        exp.setRoundsCount(roundsCount);
        exp.setQuestionsAsked(questionsAsked);
        exp.setDifficultyLevel(difficultyLevel);
        exp.setResult(result);
        exp.setTips(tips);

        boolean success = experienceService.addExperience(exp);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp?msg=add_success");
        } else {
            request.setAttribute("errorMsg", "Failed to save the interview experience. Check your inputs.");
            request.getRequestDispatcher("/addExperience.jsp").forward(request, response);
        }
    }
}
