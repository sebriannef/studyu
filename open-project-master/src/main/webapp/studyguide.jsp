<!--
Copyright 2019 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->

<%@page import="java.util.ArrayList"%>
<%@page import="javax.servlet.ServletException"%>
<%@page import="javax.servlet.annotation.WebServlet"%>
<%@page import="javax.servlet.http.HttpServlet"%>
<%@page import="javax.servlet.http.HttpServletRequest"%>
<%@page import="javax.servlet.http.HttpServletResponse"%>
<%@page import="java.io.IOException"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Blob"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title> Group Study Guide | StudyU: Study Group Finder </title>
    <link rel="stylesheet" href="/css/main.css">
    <link rel="shortcut icon" type = "image/png" href = "img/favicon.png">

    <!-- jQuery CDN Link -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

    <!-- Bootstrap 4 Link -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>


    <!-- Font Awesome Icons link -->
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.1/css/all.css">


    <script src="/js/navigation-loader.js"></script>

            <link rel="stylesheet" type="text/css" href="//fonts.googleapis.com/css?family=Comfortaa" />



    <style>

     body {
                        font-family: 'Comfortaa', cursive;
                    }

   .square {
                      height: 50px;
                      width: 50px;
     }


  .modal {
    display: none; /* Hidden by default */
    position: fixed; /* Stay in place */
    z-index: 1; /* Sit on top */
    padding-top: 100px; /* Location of the box */
    left: 0;
    top: 0;
    width: 100%; /* Full width */
    height: 100%; /* Full height */
    overflow: auto; /* Enable scroll if needed */
    background-color: rgb(0,0,0); /* Fallback color */
    background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
  }

  /* Modal Content */
  .modal-content {
    background-color: #fefefe;
    margin: auto;
    padding: 20px;
    border: 1px solid #888;
    width: 80%;
  }

  /* The Close Button */
  .close {
    color: #aaaaaa;
    float: right;
    font-size: 28px;
    font-weight: bold;
  }

  .close:hover,
  .close:focus {
    color: #000;
    text-decoration: none;
    cursor: pointer;
  }

  <!-- post it notes - -->
  <!-- got this code and modified it from http://creative-punch.net/2014/02/create-css3-post-it-note/ -->

  .quote-container {
    margin-top: 50px;
    position: relative;
  }

  .note {
    color: #333;
    position: relative;
    width: 220px;
    height: 220px;
    margin: 0 auto;
    padding: 30px;
    font-size: 25px;
    text-align:center;
    box-shadow: 0 10px 10px 2px rgba(0,0,0,0.3);
  }

  .yellow {
    background: #eae672;
    -webkit-transform: rotate(2deg);
    -moz-transform: rotate(2deg);
    -o-transform: rotate(2deg);
    -ms-transform: rotate(2deg);
    transform: rotate(2deg);
  }


    </style>
</head>

<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">

<%

    String userid = request.getParameter("userid");
    String groupformalname = "";
    String groupid = request.getParameter("id");
    String thegroup = request.getParameter("group");
    int groupsize = 0;
    boolean admin = false;

    Connection conn;

    String url = System.getProperty("cloudsql");
    try {
       conn = DriverManager.getConnection(url);
    } catch (SQLException e) {
       throw new ServletException("Unable to connect to Cloud SQL", e);
    }
    //check to see if the user is logged in

         String loggedin = "SELECT * FROM open_project_db.users WHERE id = \"" + userid + "\"\n";

         try (ResultSet l = conn.prepareStatement(loggedin).executeQuery()){
            if (l.next()) {
              if (l.getString("loggedin").equals("0") || !(l.getString("ip").equals(request.getRemoteAddr()))) {
               %>
                     <jsp:forward page="/oops"/>
               <%
               }
            }
         } catch (SQLException e) {
             throw new ServletException("SQL error", e);
         }
                    String query = "SELECT * FROM open_project_db.groups WHERE id = \"" + groupid + "\"\n";
                    int grstyle = 0;

                    try(ResultSet rs = conn.prepareStatement(query).executeQuery()) {

                        if (rs.next()) {
                            grstyle = rs.getInt("style");
                            if (userid.equals(Integer.toString(rs.getInt("admin")))){
                                admin = true;
                            }
                            Blob b = rs.getBlob("name");
                            byte[] bdata = b.getBytes(1, (int) b.length());
                            groupformalname = new String(bdata, "UTF-8");

                            groupsize = rs.getInt("size");
                        }

                    } catch (SQLException e) {
                        throw new ServletException("SQL error", e);

                    }

%>

<body onload="buildUI();" style="background-color:#056691;font-family: 'Comfortaa', cursive;">
    <!-- Navigation menu component -->
    <nav>
        <!-- Bootstrap nav menu template -->
        <ul class="nav justify-content-end" id="navigation">
            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="" role="button" aria-haspopup="true"
                aria-expanded="false">Menu</a>
                <div class="dropdown-menu">
                    <a class="dropdown-item" href="/grouppage.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>">Group Chat</a>
                    <a class = "dropdown-item" href = "/group_resources.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>"> Resources </a>
                    <%
                   if (admin) {
                   %>
                        <a class = "dropdown-item" href = "/admin_settings.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>"> Admin Settings </a>
                   <%
                    }
                   %>

                    <%
                       if (grstyle == 1) {
                    %>
                        <a class = "dropdown-item" href = "/meeting.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>"> Meetings </a>
                    <%
                        }
                    %>
                </div>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="/welcome.jsp?userid=<%=userid%>">Home</a>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="/logout?userid=<%=userid%>">Logout</a>
            </li>

        </ul>
    </nav>
    <!-- End of navigation menu component -->

 <h1 align = "center" style="color:#eae672;font-family: 'Comfortaa', cursive;"> <%=groupformalname%></h1>

             <h2 align = "center" style="color:#eae672;font-family: 'Comfortaa', cursive;"> Study Guide </h2>
             <p align = "center" style = "color:#eae672;font-family: 'Comfortaa', cursive;"> Create a collection of important concepts for your course with your classmates! Scroll to the bottom to save as a condensed cheat sheet PDF </p>

             <div align = "center">
                <button id = "myBtn" class="btn btn-primary" style="height:100%;width:200px;background-color:red;border:none;"> Add New Term </button>
             </div>

            <div id = "outerstuff">
            <div id = "stuff" class="w3-panel" style = "width:100%;height:30%;float:left;order:1;">

                <!-- The Modal -->
                <div id="myModal" class="modal">

                  <!-- Modal content -->
                  <div class="modal-content" style = "font-family: 'Comfortaa', cursive;">
                    <span class="close">&times;</span>

                    <h1 align = "center" style = "font-family: 'Comfortaa', cursive;"> Add a New Concept to Your Group's Study Guide </h1>

                     <form class="form-signin" action="/addconcept" method=post target = "_self" enctype="multipart/form-data">

                        <div class="form-label-group">
                           <input id="conceptname" name="conceptname"class="form-control" placeholder="Name of Concept"  style = "font-family: 'Comfortaa', cursive;maxlength:300" required autofocus>
                        </div>

                        <br>

                        <div class="form-label-group">
                            <input id="conceptdesc" name="conceptdesc"class="form-control" placeholder="Description" style = "height:140px;font-family: 'Comfortaa', cursive;maxlength:5000" required autofocus>
                        </div>

                        <input type="hidden" id="userid" name="userid" value="<%=userid%>" >
                        <input type="hidden" id="id" name="id" value="<%=groupid%>" >
                        <input type="hidden" id="group" name="group" value="<%=thegroup%>" >

                        <h3 style = "font-family: 'Comfortaa', cursive;"> How Important is this Concept? </h3>


                            <input type="radio" id="priority" name="priority" value="1" required style = "font-family: 'Comfortaa', cursive;"> <div class = "square" style = "background-color:red"> </div> High <br>
                            <input type="radio" id="priority" name="priority" value="2" required style = "font-family: 'Comfortaa', cursive;"> <div class = "square" style = "background-color:orange"> </div> Medium <br>
                            <input type="radio" id="priority" name="priority" value="3" required style = "font-family: 'Comfortaa', cursive;"> <div class = "square" style = "background-color:yellow"> </div> Low <br>

                        <h3 style = "font-family: 'Comfortaa', cursive;"> Add Image </h3>
                        <input type="file" name="image" id="image" accept="image/jpg">

                        <button class="btn btn-lg btn-primary btn-block text-uppercase" type="submit"> Add to Guide </button>

                     </form>

                  </div>

                </div>

                <script>
                // Get the modal
                var modal = document.getElementById("myModal");

                // Get the button that opens the modal
                var btn = document.getElementById("myBtn");

                // Get the <span> element that closes the modal
                var span = document.getElementsByClassName("close")[0];

                // When the user clicks the button, open the modal
                btn.onclick = function() {
                  modal.style.display = "block";
                }

                // When the user clicks on <span> (x), close the modal
                span.onclick = function() {
                  modal.style.display = "none";
                }

                // When the user clicks anywhere outside of the modal, close it
                window.onclick = function(event) {
                  if (event.target == modal) {
                    modal.style.display = "none";
                  }
                }
                </script>


        <div align = "center">
        <%
            String findconcepts = "SELECT * FROM open_project_db.studyguide WHERE groupid =" + groupid;
            boolean has = false;

            try (ResultSet resultset = conn.prepareStatement(findconcepts).executeQuery()){

                while (resultset.next()){
                    has = true;
                    //concept name
                    byte[] namebytes = resultset.getBlob("name").getBytes(1, (int) resultset.getBlob("name").length());
                    String cname = new String(namebytes, "UTF-8");

                    //concept description
                    byte[] descbytes = resultset.getBlob("description").getBytes(1, (int) resultset.getBlob("description").length());
                    String cdesc = new String(descbytes, "UTF-8");

                    int p = resultset.getInt("priority");

                    String color = "";
                    if (p == 1) { color = "red";}
                    else if (p == 2) { color = "orange"; }
                    else {color = "yellow";}

                    byte[] imagedata = resultset.getBlob("image").getBytes(1, (int) resultset.getBlob("image").length());
                    byte[] encodedImage = Base64.getEncoder().encode(imagedata);

                    String printimage = new String(encodedImage, "UTF-8");

        %>
            <div style = "border-radius:10px;background-color:#0892d0;min-height:400px;width:60%;border:7px solid white;">
                 <br>
                  <div class = "square" align="left" style = "position:relative;height:35px;width:35px;background-color:<%=color%>;top:2px;left:-40%;"></div>

                    <h3 align = "center" style = "color:#eae672;font-family: 'Comfortaa', cursive;"> <%=cname%> </h3>
                    <p align = "center" style = "color:#eae672;font-family: 'Comfortaa', cursive;"> <%=cdesc%> </p>
                    <%
                        if (imagedata.length != 0) {
                    %>
                       <img src = "data:image/jpeg;base64,<%=printimage%>" align = "center" style="max-width:100%;max-height:100%;"> </img>

                    <%
                        }
                    %>

            </div>
            <br><br>


        <%

                }

                 if (has) {
                     %>
                       <form align = "center" action = "/pdf" method = "post" target = "_self">
                            <input type="hidden" id="userid" name="userid" value="<%=userid%>" >
                            <input type="hidden" id="id" name="id" value="<%=groupid%>" >
                            <input type="hidden" id="group" name="group" value="<%=thegroup%>" >
                            <button id = "pdfBtn" class="btn btn-primary" style="height:100%;width:200px;background-color:#eae672;border:none;"> Create PDF Cheat Sheet </button>
                         </form>
                <%
                                }
             } catch (SQLException e) {
                   throw new ServletException("SQL error", e);

               }

        %>

    </div>


</body>
</html>