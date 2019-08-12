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

<%@ page import="java.util.*" %>
<%@ page import="com.google.gson.Gson"%>
<%@ page import="com.google.gson.JsonObject"%>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Map"%>
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
    <title> Settings | StudyU: Study Group Finder</title>
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
                </style>
</head>

<body onload="addLoginOrLogoutLinkToNavigation();" style="background-color:#056691">

    <% String userid = request.getParameter("creatorid");
       String groupid = request.getParameter("groupid");
       String thegroup = request.getParameter("thegroup");
       String mtgid = request.getParameter("mtgid");


        Connection conn;

                   String url = System.getProperty("cloudsql");
                           try {
                               conn = DriverManager.getConnection(url);
                           } catch (SQLException e) {
                               throw new ServletException("Unable to connect to Cloud SQL", e);
                           }


       String isadmin = "SELECT * FROM open_project_db.groups WHERE id = \"" + groupid + "\"\n";
            String adminnumber = "";
             try (ResultSet rss = conn.prepareStatement(isadmin).executeQuery()){

                    if (rss.next()) {
                          adminnumber = Integer.toString(rss.getInt("admin"));
                    }
              } catch (SQLException e) {
                    throw new ServletException("SQL error", e);
              }

         String findusername = "SELECT * FROM open_project_db.users WHERE id = " + userid;

                    try(ResultSet rs = conn.prepareStatement(findusername).executeQuery()) {
                        while (rs.next()) {
                        //check to see if the user is actually logged in
                        //if theyre not, then take them to the login page
                       if (rs.getString("loggedin").equals("0") || !(rs.getString("ip").equals(request.getRemoteAddr()))) {
                        %>
                            <jsp:forward page="/oops"/>
                        <%
                       }
                        }
                     } catch (SQLException e) {
                       throw new ServletException("SQL error", e);

                    }

                    //now find the group info to display

                    String findthegroup = "SELECT * FROM open_project_db.groups WHERE id = " + groupid;
                    String gname = "";
                    String gcourse = "";
                    int gsize = 0;
                    int gmax = 0;
                    String gprofessor = "";
                    String gschool = "";
                    int gstyle = 0;
                    String gdescription = "";
                    int gadmin = 0;
                    //int grstyle = 0;

                    try(ResultSet finding = conn.prepareStatement(findthegroup).executeQuery()) {
                        while (finding.next()) {

                            Blob b = finding.getBlob("name");
                            byte[] bdata = b.getBytes(1, (int) b.length());

                            gname = new String(bdata, "UTF-8");

                            gcourse = finding.getString("course");
                            gsize = finding.getInt("size");
                            gmax = finding.getInt("max_size");
                            gprofessor = finding.getString("professor");
                            gschool = finding.getString("school");
                            gstyle = finding.getInt("style");

                            Blob blah = finding.getBlob("description");
                            byte[] ddata = blah.getBytes(1, (int) blah.length());
                            gdescription = new String(ddata, "UTF-8");

                            gadmin = finding.getInt("admin");

                        }
                     } catch (SQLException e) {
                       throw new ServletException("SQL error", e);

                    }


    %>
    <!-- Navigation menu component -->
    <nav>
        <!-- Bootstrap nav menu template -->
        <ul class="nav justify-content-end" id="navigation">
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true"
              aria-expanded="false">Menu</a>
                  <div class="dropdown-menu">
                      <a class="dropdown-item" href="/grouppage.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>">Group Chat</a>
                      <a class="dropdown-item" href="/group_resources.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>">Resources</a>
                      <%
                      if (userid.equals(adminnumber)) {
                      %>
                            <a class = "dropdown-item" href = "/admin_settings.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>"> Admin Settings </a>
                      <%
                        }
                      %>

                     <%
                        if (gstyle == 1) {
                     %>
                          <a class = "dropdown-item" href = "/meeting.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>"> Schedule Meeting </a>
                     <%
                        }
                     %>
                     <a class = "dropdown-item" href = "/studyguide.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>"> Group Study Guide </a>
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
    <br>
    <h1 align="center" style="color:#eae672;"> Manage Your Meeting </h1>
    <br><br>
     <h2 align="center" style="color:white;"> Confirm the Time </h2>
        <br>

    <div class="form-container" align="center" style="height:50%;">

            <%


                HashMap<String, Integer> usertimes = new HashMap<String, Integer>();
                String findtimes = "SELECT * FROM open_project_db.meetings WHERE id = "+ mtgid;
                String[] days = {"sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"};

                try(ResultSet resultset = conn.prepareStatement(findtimes).executeQuery()) {

                    while (resultset.next()) {
                        log("\n\n\n\n result set has next");
                        for (int i = 0; i < 7; i++) {
                            //for each day, get all of the times and parse through it
                            String daystring = resultset.getString(days[i]);

                            if (!daystring.equals("0")){ //if someone is available on that day

                                 String[] dts = daystring.split(","); //split at all the different repsonses for that day

                                  for (int m = 0; m < dts.length; m++) {

                                        String[] dtssplit = dts[m].split("\\@");

                                        String formattedtime = dtssplit[0] + " at " + dtssplit[1];
                                        log ("\n\n\n" + dtssplit[1]);

                                       if (!usertimes.keySet().contains(days[i] + " " + dtssplit[1])){
                                            log("\n\n\n new");
                                            usertimes.put(days[i] + " " + dtssplit[1], 1);

                                       }

                                       else {
                                            log("\n\n\n update");
                                            Integer vote = usertimes.get(days[i] + " " + dtssplit[1]) + 1;
                                            usertimes.replace(days[i] + " " + dtssplit[1], vote);
                                       }

                                    }


                              }


                         }

                    } //end of while result set.next

                    log(Integer.toString(usertimes.size()));

                    %>

                        <form action = "/confirmmtg" method = "post" target="_self">

                        <div>
                    <%

                            for (Map.Entry entry : usertimes.entrySet()){

                                    String[] extractTime = entry.getKey().toString().split(" ");


                                    %>
                                         <input type="radio" name="choice" value="<%=entry.getKey()%>" required> &nbsp <label for="radio" style = "color:#eae672;font-size:20pt;font-family: 'Comfortaa', cursive;">   <%=entry.getValue()%> votes for <%=extractTime[0]%> at <%=extractTime[1]%></label><br>
                                     <%


                             }


                      %>

                        </div>

                         <button class="btn btn-primary" type = "submit" style="width:500px;font-size:22pt;background-color:#eae672"> Confirm meeting </button>
                            <input type="hidden" id="mtgid" name="mtgid" value="<%=mtgid%>" >
                            <input type="hidden" id="userid" name="userid" value="<%=userid%>" >
                            <input type="hidden" id="id" name="id" value="<%=groupid%>" >
                            <input type="hidden" id="group" name="group" value="<%=thegroup%>" >
                        </form>

                        <form action = "/deletemtg" method = "post" target="_self">
                            <input type="hidden" id="mtgid" name="mtgid" value="<%=mtgid%>" >
                            <input type="hidden" id="userid" name="userid" value="<%=userid%>" >
                            <input type="hidden" id="id" name="id" value="<%=groupid%>" >
                            <input type="hidden" id="group" name="group" value="<%=thegroup%>" >
                            <button class="btn btn-primary" type = "submit" style="width:500px;font-size:22pt;background-color:red"> Delete meeting </button>
                        </form>

                      <%


              }
              catch (SQLException e) {
                                        throw new ServletException("SQL error", e);

               }

              %>

    </div>



</body>

</html>