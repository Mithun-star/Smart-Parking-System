package com.interviewportal.servlet;

import com.interviewportal.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserService userService;

    @Override
    public void init() throws ServletException {
        // Servlet Lifecycle init()
        super.init();
        userService = new UserService();
        System.out.println("RegisterServlet Initialized.");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");

        boolean isRegistered = userService.registerUser(username, password, email, fullName);

        if (isRegistered) {
            // Registration success, redirect to login page with parameter
            response.sendRedirect(request.getContextPath() + "/login.jsp?msg=registration_success");
        } else {
            // Registration failure, set error message and forward back
            request.setAttribute("errorMsg", "Registration failed. Username or email may already be in use.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }

    @Override
    public void destroy() {
        // Servlet Lifecycle destroy()
        System.out.println("RegisterServlet Destroyed.");
        super.destroy();
    }
}
