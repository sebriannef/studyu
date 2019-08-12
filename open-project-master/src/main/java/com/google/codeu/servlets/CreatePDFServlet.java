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
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.Base64;

import com.itextpdf.text.*;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.PdfReader;
import com.itextpdf.text.pdf.PdfStamper;
import com.itextpdf.text.pdf.PdfWriter;

// [START gae_java8_mysql_app]
//help for this servlet came from https://stackoverflow.com/questions/36408805/how-to-receive-a-file-type-parameter-from-html-jsp-into-a-servlet
@WebServlet("/pdf")
public class CreatePDFServlet extends HttpServlet {

    Connection conn;

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {




        String url = System.getProperty("cloudsql");
        log("connecting to: " + url);
        try {
            conn = DriverManager.getConnection(url);
        } catch (SQLException e) {
            throw new ServletException("Unable to connect to Cloud SQL", e);
        }

        String groupid = request.getParameter("id"); //groupid
        String userid = request.getParameter("userid"); //userid
        String group = request.getParameter("group"); //group

        String query = "SELECT * FROM open_project_db.studyguide WHERE groupid =" + groupid;
        ArrayList<String> names = new ArrayList<>();
        ArrayList<String> concepts = new ArrayList<>();
        ArrayList<String> images = new ArrayList<>();

        Document document = new Document();
        String docname = group+"studyguide.pdf";
        try {
            response.setContentType("application/pdf;charset=UTF-8");
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();
            Font font = FontFactory.getFont(FontFactory.COURIER, 10, BaseColor.BLACK);

            try (ResultSet rs = conn.prepareStatement(query).executeQuery()) {

                while (rs.next()){

                    byte[] namebytes = rs.getBlob("name").getBytes(1, (int) rs.getBlob("name").length());
                    String cname = new String(namebytes, "UTF-8");

                    //concept description
                    byte[] descbytes = rs.getBlob("description").getBytes(1, (int) rs.getBlob("description").length());
                    String cdesc = new String(descbytes, "UTF-8");

                    Phrase chunk1 = new Phrase(cname, font);
                    Phrase chunk2 = new Phrase(cdesc, font);


                    byte[] imagedata = rs.getBlob("image").getBytes(1, (int) rs.getBlob("image").length());
                    byte[] encodedImage = Base64.getEncoder().encode(imagedata);

                    String printimage = new String(encodedImage, "UTF-8");
                    //Image image;

                    try {
                        document.add(chunk1);
                        document.add(chunk2);
                    } catch (DocumentException e) {
                        e.printStackTrace();
                    }

                }
               // PdfReader pdfReader = new PdfReader(docname);

            }

            catch (SQLException e){
                throw new ServletException("SQL error -- couldnt count", e);
            }

            document.close();

        } catch (DocumentException e) {
            e.printStackTrace();
        }



    }


}
