package com.interviewportal.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // We can optionally clear the remember me cookie here, but usually, remember me stays unless requested otherwise.
        // Let's clear the cookie to show clean logout if they want, or keep it. Let's just invalidate the session and redirect.
        // To be safe, let's keep the cookie so they are remembered next time they open login.jsp, but invalidate current login.
        
        response.sendRedirect(request.getContextPath() + "/login.jsp?msg=logged_out");
    }
}
