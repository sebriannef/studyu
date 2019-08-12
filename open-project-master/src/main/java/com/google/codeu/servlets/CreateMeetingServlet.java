/*
 * Copyright 2016 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.codeu.servlets;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

// [START gae_java8_mysql_app]
@WebServlet("/createmeeting")
public class CreateMeetingServlet extends HttpServlet {

    Connection conn;

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        String url = System.getProperty("cloudsql");
        log("blah blah bl: " + url);
        try {
            this.conn = DriverManager.getConnection(url);
        } catch (SQLException e) {
            throw new ServletException("Unable to connect to Cloud SQL", e);
        }

        String groupid = request.getParameter("id");

        String creatorid = request.getParameter("userid");

        String group = request.getParameter("group");

        String mtgid = request.getParameter("mtgid");

        String agenda = request.getParameter("agenda");


        //first check to see if there is a group that exists with that id number

        String query = "UPDATE open_project_db.meetings SET mtgagenda = \"" + agenda + "\" WHERE (id = \"" + mtgid + "\");\n";
        PreparedStatement statement = null;
        try {
            statement = this.conn.prepareStatement(query);
            statement.executeUpdate();


        } catch (SQLException e) {
            e.printStackTrace();
        }


        //response.sendRedirect("/schedule-meeting.jsp?&userid=" + creatorid+ "&id=" + groupid +"&group=" + group);
        request.getServletContext().getRequestDispatcher("/meeting.jsp?userid=" + creatorid+ "&id=" + groupid +"&group=" + group).forward(request, response);



    }

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        doPost(request, response);
    }

}