package com.google.codeu.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigInteger;
import java.sql.*;

public class ScheduleMeetingServlet extends HttpServlet {

    Connection conn;

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse resp) throws IOException, ServletException {
        String url = System.getProperty("cloudsql");
        log("connecting to: " + url);
        try {
            conn = DriverManager.getConnection(url);
        } catch (SQLException e) {
            throw new ServletException("Unable to connect to Cloud SQL", e);
        }

        int id = Integer.parseInt(request.getParameter("id"));
        int groupid = Integer.parseInt(request.getParameter("groupid"));
        int creatorid = Integer.parseInt(request.getParameter("creatorid"));
        String agenda = request.getParameter("agenda");
        String confirmed = request.getParameter("confirmed");
        String sunday = request.getParameter("sunday");
        String monday = request.getParameter("monday");
        String tuesday = request.getParameter("tuesday");
        String wednesday = request.getParameter("wednesday");
        String thursday = request.getParameter("thursday");
        String friday = request.getParameter("friday");
        String saturday = request.getParameter("saturday");






    }

    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        doPost(request, response);
    }

    private int countUsers() throws ServletException {

        final String selectSql = "SELECT * FROM open_project_db.users";
        int count = 0;
        try (ResultSet rs = conn.prepareStatement(selectSql).executeQuery()) {

            if (rs.next()){
                rs.last();
                count = rs.getInt("id") + 1;
            }
            /** while (rs.next()) {
             count++;
             }*/
        } catch (SQLException e) {
            throw new ServletException("SQL error -- couldnt count", e);
        }
        return count;
    }


}
