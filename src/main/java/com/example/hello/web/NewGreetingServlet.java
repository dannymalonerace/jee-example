package com.example.hello.web;

import com.example.hello.service.GreetingService;
import com.example.hello.service.InvalidGreetingException;
import com.example.hello.web.dto.FieldErrors;
import com.example.hello.web.dto.GreetingForm;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/greetings/new")
public class NewGreetingServlet extends HttpServlet {

    @Inject
    private GreetingService service;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        renderForm(req, resp, new GreetingForm(), FieldErrors.empty());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        GreetingForm form = new GreetingForm(
                req.getParameter("name"),
                req.getParameter("message")
        );

        try {
            service.create(form);
            resp.sendRedirect(req.getContextPath() + "/greetings");
        } catch (InvalidGreetingException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            renderForm(req, resp, form, e.getFieldErrors());
        }
    }

    private void renderForm(HttpServletRequest req, HttpServletResponse resp,
                            GreetingForm form, FieldErrors errors) throws ServletException, IOException {
        req.setAttribute("activeNav", "new");
        req.setAttribute("form", form);
        req.setAttribute("errors", errors);
        req.getRequestDispatcher("/WEB-INF/views/greeting-form.jsp").forward(req, resp);
    }
}
