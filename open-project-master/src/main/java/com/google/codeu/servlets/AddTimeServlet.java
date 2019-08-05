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
@WebServlet("/addtime")
public class AddTimeServlet extends HttpServlet {

    Connection conn;

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        String url = System.getProperty("cloudsql");
        log("blah blah blah: " + url);
        try {
            this.conn = DriverManager.getConnection(url);
        } catch (SQLException e) {
            throw new ServletException("Unable to connect to Cloud SQL", e);
        }

        String groupid = request.getParameter("id");
        log(groupid);
        String creatorid = request.getParameter("userid");
        log(creatorid);
        String group = request.getParameter("group");
        log(group);
        String mtgid = request.getParameter("mtgid");
        log(mtgid);
        String day = request.getParameter("day");
        log(day);
        String time = request.getParameter("time");

        log(time);


        String confirmed = "0"; //by default the meeting has not been confirmed

        //first check to see if there is a group that exists with that id number

        String query = "SELECT * FROM open_project_db.meetings WHERE id = " + mtgid;
        try(ResultSet rs = conn.prepareStatement(query).executeQuery()) {

            //look to see if the user has already chosen at least one time for the meeting

            if(!rs.next()) { //if there isn't an event yet, you should create it and then update it with the time

                String makenewmeeting = "INSERT INTO open_project_db.meetings (id, groupid, creatorid, confirmed, sunday, monday, tuesday, wednesday, thursday, friday, saturday, mtgagenda) VALUES (" + mtgid + ", " + groupid + ", " + creatorid + ", \"" + 0 + "\", + \"0\", \"0\", \"0\", \"0\", \"0\", \"0\", \"0\", \"0\");\n";
                log("AND got to this point in time");
                PreparedStatement statement = null;
                try {
                    statement = this.conn.prepareStatement(makenewmeeting);
                    statement.executeUpdate();


                } catch (SQLException e) {
                    e.printStackTrace();
                }

            }

            try(ResultSet rs1 = conn.prepareStatement(query).executeQuery()) {
                String update = "";
                if (rs1.next()) {
                    if (rs1.getString(day).equals("0")) { //havent added time for that day
                        update = "UPDATE open_project_db.meetings SET " + day + " = \"" + (time) + "\" WHERE (id = " + mtgid + ");";
                    } else {
                        update = "UPDATE open_project_db.meetings SET " + day + " = \"" + (rs1.getString(day) + "," + time) + "\" WHERE (id = " + mtgid + ");";
                    }

                    PreparedStatement statement = null;
                    try {
                        statement = this.conn.prepareStatement(update);
                        statement.executeUpdate();


                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
            catch (SQLException e){
                throw new ServletException("SQL error", e);
            }


        } catch (SQLException e) {
            throw new ServletException("SQL error", e);

        }


        //response.sendRedirect("/schedule-meeting.jsp?&userid=" + creatorid+ "&id=" + groupid +"&group=" + group);
       request.getServletContext().getRequestDispatcher("/schedule-meeting.jsp?&userid=" + creatorid+ "&id=" + groupid +"&group=" + group + "&mid=" + mtgid).forward(request, response);



    }

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        doPost(request, response);
    }

}
