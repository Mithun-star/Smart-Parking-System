package com.interviewportal.servlet;

import com.interviewportal.service.AnalyticsService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/analytics")
public class AnalyticsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AnalyticsService analyticsService;

    @Override
    public void init() throws ServletException {
        super.init();
        analyticsService = new AnalyticsService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || (session.getAttribute("currentUser") == null && session.getAttribute("adminUser") == null)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Gather statistics
        int totalExperiences = analyticsService.getTotalExperiences();
        double selectionRate = analyticsService.getSelectionRate();
        Map<String, Integer> companyCounts = analyticsService.getCompanyExperienceCountsSorted();
        List<Map.Entry<String, Integer>> topCompanies = analyticsService.getMostFrequentCompanies(5);
        Map<String, Integer> topTopics = analyticsService.getMostFrequentTopics();
        String reportText = analyticsService.generateAnalyticsSummaryReport();

        // Log search event in analytics
        String username = "Anonymous";
        if (session.getAttribute("currentUser") != null) {
            username = ((com.interviewportal.model.User) session.getAttribute("currentUser")).getUsername();
        } else if (session.getAttribute("adminUser") != null) {
            username = (String) session.getAttribute("adminUser");
        }
        analyticsService.logEvent("VIEW_ANALYTICS", "User " + username + " viewed the analytics dashboard.");

        // Set attributes
        request.setAttribute("totalExperiences", totalExperiences);
        request.setAttribute("selectionRate", selectionRate);
        request.setAttribute("companyCounts", companyCounts);
        request.setAttribute("topCompanies", topCompanies);
        request.setAttribute("topTopics", topTopics);
        request.setAttribute("reportText", reportText);

        request.getRequestDispatcher("/analytics.jsp").forward(request, response);
    }
}
