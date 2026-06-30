package com.example.hello.web;

import com.example.hello.service.GreetingService;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/greetings")
public class GreetingsListServlet extends HttpServlet {

    @Inject
    private GreetingService service;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("activeNav", "greetings");
        req.setAttribute("greetings", service.listAll());
        req.getRequestDispatcher("/WEB-INF/views/greetings-list.jsp").forward(req, resp);
    }
}
