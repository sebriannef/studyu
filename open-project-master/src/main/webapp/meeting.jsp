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
                <button id = "myBtn" class="btn btn-primary" style="height:100%;width:250px;border:none;" onclick="window.location.href = '/schedule-meeting.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>&mid=<%=mtgid%>';"> Schedule a new meeting for the week </button>
             </div>


             <div class = "w3-panel" style="width:100%;overflow-y:scroll;overflow-x:hidden;" align="center">

                <%

                    String getmtgs =  "SELECT * from open_project_db.meetings WHERE groupid = " + groupid + " AND mtgagenda != \"0\";";

                    try(ResultSet resultset = conn.prepareStatement(getmtgs).executeQuery()) {

                         while (resultset.next()) {

                            int creatr = resultset.getInt("creatorid");
                            int specmtg = resultset.getInt("id");
                            String confirmtime = resultset.getString("confirmed");

                            String creator = "";

                            String getname =  "SELECT * from open_project_db.users WHERE id = " + creatr;

                            try(ResultSet rr = conn.prepareStatement(getname).executeQuery()) {
                                while( rr.next()){
                                    creator = rr.getString("first_name") + " " + rr.getString("last_name");
                                }
                            }
                            catch (SQLException e) {
                                throw new ServletException("SQL error", e);
                            }


                         %>

                            <form action = "/rsvp" method =post target = "_self">

                                <div style = "background-color:#0892d0;border: 5px solid white;border-radius:8px;width:70%;height=20%" align = "center">
                                    <p style="color:white;font-family: 'Comfortaa', cursive;font-size:19pt"> created by <%=creator%> </p>
                                    <p style="color:#eae672;font-family: 'Comfortaa', cursive;font-size:22pt"> Agenda: <%=resultset.getString("mtgagenda")%> </p>

                                  <%

                                        String[] days = {"sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"};
                                        HashMap<String, String> options = new HashMap<String, String>();
                                        ArrayList<String> timestodisplay = new ArrayList<String>();
                                        HashSet<String> people = new HashSet<String>();
                                        HashMap<String, HashSet<String>> usertimes = new HashMap<String, HashSet<String>>();


                                        for (int b = 0; b < 7; b++) { //get all of the people that have rsvped for the meeting
                                            String string = resultset.getString(days[b]);

                                             if (!string.equals("0")){ //if someone is available on that day

                                                   String[] dts1 = string.split(","); //split at all the different repsonses for that day
                                                   for (int c = 0; c < dts1.length; c++) {
                                                        people.add(dts1[c].split("\\@")[0]);
                                                   }

                                              }


                                        }


                                        for (int i = 0; i < 7; i++) {
                                           //for each day, get all of the times and parse through it
                                           String daystring = resultset.getString(days[i]);
                                           //HashMap<String, HashSet<String>> usertimes = new HashMap<String, HashSet<String>>();

                                            if (!daystring.equals("0")){ //if someone is available on that day

                                                 String[] dts = daystring.split(","); //split at all the different repsonses for that day

                                                    HashSet<String> nodupes = new HashSet<String>(); //put it in a hashset to remove the dupes

                                                    //once you get each entry, you need to extract the time and then add those to the hashset
                                                    for (int m = 0; m < dts.length; m++) {

                                                        String[] temp = dts[m].split("\\@");

                                                        //check to see if the user is already in the hashmap
                                                        //if they are, then you need to get their set of times for that day and add this time
                                                        //if they are not, then you need to create a new hashset with that time and add that element to the hashmap

                                                        if (usertimes.containsKey(temp[0])) {
                                                            usertimes.get(temp[0]).add(temp[1]);
                                                        }
                                                        else {
                                                            HashSet<String> ut = new HashSet<String>();
                                                            ut.add(temp[1]);
                                                            usertimes.put(temp[0], ut);
                                                        }
                                                        nodupes.add(temp[1]); //keep track of all the unique times among all users
                                                    }

                                                 String times = ""; //compile all the unique times into one string

                                                 for (String d: nodupes) {
                                                    int total = 0;
                                                    for (Map.Entry member : usertimes.entrySet()) {
                                                          @SuppressWarnings("unchecked")
                                                          HashSet<String> vals = (HashSet<String>)member.getValue();
                                                          if (vals.contains(d.toString())){
                                                            total++;
                                                          }

                                                     }
                                                     //now check to see if all the users that have rsvped can make that time
                                                     if (total== people.size()){
                                                        timestodisplay.add(days[i] + "@" + d);
                                                     }


                                                  } //end of inner for




                                              } //end of if

                                          } //end of for 7

                                          if (timestodisplay.size() == 0) {

                                                %>

                                                    <h3 style="color:white;font-family: 'Comfortaa', cursive;"> No one has time in common. Try next week. </h3>


                                                <%


                                          }


                                        else {

                                        if (!confirmtime.equals("0")) {
                                            String[] split2 = confirmtime.split(" ");

                                           %>
                                               <h3 style="color:#eae672;font-family: 'Comfortaa', cursive;font-weight:bold;"> Confirmed for <%=split2[0]%> <%=split2[2]%> at <%=split2[1]%> </h3>
                                           <%
                                        }
                                        else {


                                             for (String entry : timestodisplay) {


                                                String[] tims = entry.split("@");
                                                 log("tims:" + Integer.toString(tims.length));
                                                //for (int k = 0; k < tims.length; k++) {

                                                 %>
                                                      <input id = "tiempo" name = "tiempo" type="checkbox" value="<%=tims[0]%>$<%=tims[1]%>"><label for="checkbox" style = "color:white;"> <%=tims[0]%> at <%=tims[1]%></label><br>

                                                  <%
                                                 //} //end of inner for

                                                }//end of outter for





                                        %>
                                    <input type="hidden" id="mtgid" name="mtgid" value="<%=resultset.getInt("id")%>" >
                                    <input type="hidden" id="userid" name="userid" value="<%=userid%>" >
                                    <input type="hidden" id="id" name="id" value="<%=groupid%>" >
                                    <input type="hidden" id="group" name="group" value="<%=thegroup%>" >
                                      <%


                                    if (Integer.parseInt(userid) != creatr) {

                                            if (people.contains(userid)){
                                        %>
                                            <h3 style="color:#eae672;font-family: 'Comfortaa', cursive;"> You already RSVPed for this meeting </h3>

                                        <%
                                            }

                                            else {

                                         %>

                                            <button class="btn btn-primary" type = "submit" style="width=50%;background-color:#eae672"> RSVP!</button>

                                        <%
                                        }
                                      }

                                     }


                                      if (Integer.parseInt(userid) == creatr) {
                                     %>
                                        <a href = "/meetingadmin.jsp?creatorid=<%=creatr%>&groupid=<%=groupid%>&mtgid=<%=specmtg%>"><button class="btn btn-primary" type = "button" style="width=50%;background-color:#eae672"> Meeting Settings </button></a>

                                     <%

                                     }


                                    %>
                                    <br><br>



                                </div>

                            </form>

                            <br><br>


                         <%
                         }
                         } //end of while


                    } //end of try

                     catch (SQLException e) {
                          throw new ServletException("SQL error", e);

                     }
                %>

             </div>




</body>
</html>