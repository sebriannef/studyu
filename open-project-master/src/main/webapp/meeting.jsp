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

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title> Schedule Meeting | StudyU: Study Group Finder </title>
    <link rel="stylesheet" href="/css/main.css">

    <!-- jQuery CDN Link -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

    <!-- Bootstrap 4 Link -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
    <link rel="shortcut icon" type = "image/png" href = "img/favicon.png">


    <!-- Font Awesome Icons link -->
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.1/css/all.css">


    <script src="/js/navigation-loader.js"></script>
                    <link rel="stylesheet" type="text/css" href="//fonts.googleapis.com/css?family=Comfortaa" />



    <style>

     body {
                                font-family: 'Comfortaa', cursive;
                            }

        ::-webkit-scrollbar {
                width: 0px;
                background: transparent; /* make scrollbar transparent */
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
                        <a class = "dropdown-item" href = "/meeting.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>"> Schedule Meeting </a>
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

    <%

    int mtgid = 0;

     String mtgq = "SELECT * FROM open_project_db.meetings";
            try(ResultSet rs = conn.prepareStatement(mtgq).executeQuery()) {

                if(rs.next()) {
                    rs.last();
                    mtgid = rs.getInt("id") + 1;
                }

            } catch (SQLException e) {
                throw new ServletException("SQL error", e);

            }


            log("in jsp: " + Integer.toString(mtgid));
    %>

            <h1 align = "center" style = "color:#eae672;font-family: 'Comfortaa', cursive;"> <%=groupformalname%></h1>
            <h2 align = "center" style = "color:#eae672;font-family: 'Comfortaa', cursive;"> Group Meetings </h2>

             <div align = "center">
                <button id = "myBtn" class="btn btn-primary" style="height:100%;width:200px;border:none;" onclick="window.location.href = '/schedule-meeting.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>&mid=<%=mtgid%>';"> Schedule a New Meeting </button>
             </div>


             <div class = "w3-panel" style="width:100%;overflow-y:scroll;overflow-x:hidden;position:fixed;" align="center">

                <%

                    String getmtgs =  "SELECT * from open_project_db.meetings WHERE groupid = " + groupid + " AND mtgagenda != \"0\";";

                    try(ResultSet resultset = conn.prepareStatement(getmtgs).executeQuery()) {

                         while (resultset.next()) {

                         %>

                            <form action = "/rsvp" method =post target = "_self">

                                <div style = "border: 5px solid #eae862;border-radius:8px;width:70%;height=20%" align = "center">
                                    <h3 style="color:#eae862;font-family: 'Comfortaa', cursive;"> <%=resultset.getString("mtgagenda")%> </h3>

                                    <%

                                    String[] days = {"sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"};

                                    for (int i = 0; i < 7; i++) { //for each day, get all of the times and parse through it
                                     String daystring = resultset.getString(days[i]);

                                        if (!daystring.equals("0")){

                                             String[] dts = daystring.split(",");

                                               for (int j = 0; j< dts.length; j++){

                                         %>
                                               <input id = "tiempo" name = "tiempo" type="checkbox" value="<%=days[i]%>$<%=dts[j]%>"><label for="checkbox" style = "color:white;"> <%=days[i]%> at <%=dts[j]%></label><br>

                                          <%
                                      }
                                   }
                               }
                                %>
                                <input type="hidden" id="mtgid" name="mtgid" value="<%=resultset.getInt("id")%>" >
                                <input type="hidden" id="userid" name="userid" value="<%=userid%>" >
                                <input type="hidden" id="id" name="id" value="<%=groupid%>" >
                                <input type="hidden" id="group" name="group" value="<%=thegroup%>" >
                                <button class="btn btn-primary" type = "submit" style="width=50%;"> RSVP!</button>
                                <br><br>



                                </div>

                            </form>


                         <%
                         }


                    }
                %>

             </div>




</body>
</html>