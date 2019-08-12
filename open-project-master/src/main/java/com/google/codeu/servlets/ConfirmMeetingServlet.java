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
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;

// [START gae_java8_mysql_app]
@WebServlet("/confirmmtg")
public class ConfirmMeetingServlet extends HttpServlet {

    Connection conn;

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        String url = System.getProperty("cloudsql");
        try {
            this.conn = DriverManager.getConnection(url);
        } catch (SQLException e) {
            throw new ServletException("Unable to connect to Cloud SQL", e);
        }

        String groupid = request.getParameter("id");

        String creatorid = request.getParameter("userid");

        String group = request.getParameter("group");

        String mtgid = request.getParameter("mtgid");

        String choice = request.getParameter("choice");

        String[] splitchoice = choice.split(" ");

        HashMap<String, Integer> daysofweek = new HashMap<>();
        daysofweek.put("sunday", 0);
        daysofweek.put("monday", 1);
        daysofweek.put("tuesday", 2);
        daysofweek.put("wednesday", 3);
        daysofweek.put("thursday", 4);
        daysofweek.put("friday", 5);
        daysofweek.put("saturday", 6);


        Date now = new Date();
        SimpleDateFormat simpleDateformat = new SimpleDateFormat("EEEE"); // the day of the week spelled out completely
        String downow = simpleDateformat.format(now).toLowerCase();

        //find where you are in the week
        int dayval = daysofweek.get(downow);

        //find when the meeting is and its value
        int desval = daysofweek.get(splitchoice[0]);

        int difference = Math.abs(dayval-desval);

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        Calendar c = Calendar.getInstance();
        c.setTime(new Date()); // Now use today date.
        c.add(Calendar.DATE, difference); // Adding 5 days
        String output = sdf.format(c.getTime());

        String choicewday = choice + " " + output;
        //first check to see if there is a group that exists with that id number

        String query = "UPDATE open_project_db.meetings SET confirmed = \"" + choicewday + "\" WHERE (id = " + mtgid + ");\n";
        PreparedStatement statement = null;
                try {
                    statement = this.conn.prepareStatement(query);
                    statement.executeUpdate();


                } catch (SQLException e) {
                    e.printStackTrace();
                }



        //response.sendRedirect("/schedule-meeting.jsp?&userid=" + creatorid+ "&id=" + groupid +"&group=" + group);
        request.getServletContext().getRequestDispatcher("/meeting.jsp?&userid=" + creatorid+ "&id=" + groupid +"&group=" + group).forward(request, response);



    }

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        doPost(request, response);
    }

}