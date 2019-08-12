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
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.file.Path;
import java.nio.file.Paths;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.Part;

// [START gae_java8_mysql_app]
//help for this servlet came from https://stackoverflow.com/questions/36408805/how-to-receive-a-file-type-parameter-from-html-jsp-into-a-servlet
@WebServlet("/addconcept")
@MultipartConfig(location="/tmp", fileSizeThreshold=1048576, maxFileSize=20848820, maxRequestSize=418018841)
public class AddToStudyGuideServlet extends HttpServlet {

    Connection conn;

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        //for getting the image

        Part filePart=request.getPart("image");// Retrieves <input type="file" name="image">
        String filePath = filePart.getSubmittedFileName();//Retrieves complete file name with path and directories
        Path p = Paths.get(filePath); //creates a Path object
        String fileName = p.getFileName().toString();//Retrieves file name from Path object
        InputStream fileContent = filePart.getInputStream();//IMAGE

        String url = System.getProperty("cloudsql");
        log("connecting to: " + url);
        try {
            conn = DriverManager.getConnection(url);
        } catch (SQLException e) {
            throw new ServletException("Unable to connect to Cloud SQL", e);
        }

        String cn = request.getParameter("conceptname");
        String cd = request.getParameter("conceptdesc");

        byte[] fo = cn.getBytes();
        Blob conceptname = null;
        try {
            conceptname = conn.createBlob();
            conceptname.setBytes(1, fo);
        } catch (SQLException e) {
            e.printStackTrace();
        }

        fo = cd.getBytes();
        Blob conceptdesc = null;
        try {
            conceptdesc = conn.createBlob();
            conceptdesc.setBytes(1, fo);
        } catch (SQLException e) {
            e.printStackTrace();
        }


        String groupid = request.getParameter("id"); //groupid
        String userid = request.getParameter("userid"); //userid
        String group = request.getParameter("group"); //group
        int idno = getResourceId(); //id

        String priority = request.getParameter("priority"); //priority
        int  len=(int) filePart.getSize(); //len of image


        String query = ("insert into open_project_db.studyguide(id, name, description, priority, groupid, image) VALUES(?,?,?,?,?,?)");

        PreparedStatement statement;
        try {
            statement = conn.prepareStatement(query);
            statement.setInt(1, idno);
            statement.setBlob(2, conceptname);
            statement.setBlob(3, conceptdesc);
            statement.setInt(4, Integer.parseInt(priority));
            statement.setInt(5, Integer.parseInt(groupid));
            statement.setBlob(6, fileContent);
            statement.executeUpdate();

        } catch (SQLException e) {
            throw new ServletException("SQL error", e);

        }

        //response.sendRedirect("/group_resources.jsp?group="+ group +"&id="+ groupid +"&userid=" + userid);
        request.getServletContext().getRequestDispatcher("/studyguide.jsp?group="+ group +"&id="+ groupid +"&userid=" + userid).forward(request, response);

    }

    public int getResourceId() throws ServletException {

        String query = "SELECT * FROM open_project_db.studyguide";
        try(ResultSet rs = conn.prepareStatement(query).executeQuery()) {

            if(rs.next()) {
                rs.last();
                return rs.getInt("id") + 1;
            }

        } catch (SQLException e) {
            throw new ServletException("SQL error", e);

        }

        return 0;


    }
}
