package com.interviewportal.servlet;

import com.interviewportal.model.InterviewExperience;
import com.interviewportal.service.AnalyticsService;
import com.interviewportal.service.ExperienceService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ExperienceService experienceService;
    private AnalyticsService analyticsService;

    @Override
    public void init() throws ServletException {
        super.init();
        experienceService = new ExperienceService();
        analyticsService = new AnalyticsService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String company = request.getParameter("company");
        String role = request.getParameter("role");
        String difficulty = request.getParameter("difficulty");
        String result = request.getParameter("result");
        String sort = request.getParameter("sort");

        // Execute search
        List<InterviewExperience> results = experienceService.searchExperiences(company, role, difficulty, result);

        // Perform sorting if requested
        if (sort != null && !sort.trim().isEmpty()) {
            experienceService.sortExperiences(results, sort);
        }

        // Log search event in analytics
        HttpSession session = request.getSession(false);
        String username = "Anonymous";
        if (session != null && session.getAttribute("currentUser") != null) {
            username = ((com.interviewportal.model.User) session.getAttribute("currentUser")).getUsername();
        }
        
        StringBuilder queryDesc = new StringBuilder("Search query:");
        if (company != null && !company.trim().isEmpty()) queryDesc.append(" company=").append(company);
        if (role != null && !role.trim().isEmpty()) queryDesc.append(" role=").append(role);
        if (difficulty != null && !difficulty.trim().isEmpty()) queryDesc.append(" difficulty=").append(difficulty);
        if (result != null && !result.trim().isEmpty()) queryDesc.append(" result=").append(result);

        analyticsService.logEvent("SEARCH", "User " + username + " searched. " + queryDesc.toString());

        // Set attributes and forward to search.jsp
        request.setAttribute("searchResults", results);
        request.setAttribute("paramCompany", company);
        request.setAttribute("paramRole", role);
        request.setAttribute("paramDifficulty", difficulty);
        request.setAttribute("paramResult", result);
        request.setAttribute("paramSort", sort);

        request.getRequestDispatcher("/search.jsp").forward(request, response);
    }
}
