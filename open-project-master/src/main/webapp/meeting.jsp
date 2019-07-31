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
    width: 60%;
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

  #prevBtn {
    background-color: #bbbbbb;
  }

  /* Hide all steps by default: */
  .tab {
    display: none;
  }

  /* Make circles that indicate the steps of the form: */
  .step {
    height: 15px;
    width: 15px;
    margin: 0 2px;
    background-color: #bbbbbb;
    border: none;
    border-radius: 50%;
    display: inline-block;
    opacity: 0.5;
  }

  .step.active {
    opacity: 1;
  }

  /* Mark the steps that are finished and valid: */
  .step.finish {
    background-color: #4CAF50;
  }

  #regForm {
    background-color: #ffffff;
    margin: 100px auto;
    font-family: Raleway;
    padding: 40px;
    width: 70%;
    min-width: 300px;
  }

    * {
      box-sizing: border-box;
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

<body onload="buildUI();" style="background-color:#056691">
    <!-- Navigation menu component -->
    <nav>
        <!-- Bootstrap nav menu template -->
        <ul class="nav justify-content-end" id="navigation">
            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="" role="button" aria-haspopup="true"
                aria-expanded="false">Menu</a>
                <div class="dropdown-menu">
                    <a class="dropdown-item" href="/grouppage.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>">Group Chat</a>
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
                        <a class = "dropdown-item" href = "/schedule_meeting.jsp?group=<%=thegroup%>&id=<%=groupid%>&userid=<%=userid%>"> Schedule Meeting </a>
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

            <h1 align = "center" style = "color:#eae672;"> <%=groupformalname%></h1>
            <h2 align = "center" style = "color:#eae672;"> Group Meetings </h2>

             <div align = "center">
                <button id = "myBtn" class="btn btn-primary" style="height:100%;width:200px;border:none;"> Schedule a New Meeting </button>
             </div>

            <!-- The Modal -->
                <div id="myModal" class="modal">

                  <!-- Modal content -->
                  <div class="modal-content">
                    <span class="close">&times;</span>

                    <form id="regForm" action="/#">
                      <h1>Register:</h1>
                      <!-- One "tab" for each step in the form: -->
                      <div class="tab">What days are you available this week?
                        <form id = "choosedays" action = "/#" method = "post" target="_self">
                            <input type="checkbox" name="sunday" value="Sunday"> Sunday <br>
                            <input type="checkbox" name="monday" value="Monday"> Monday <br>
                            <input type="checkbox" name="tuesday" value="Tuesday"> Tuesday <br>
                            <input type="checkbox" name="wednesday" value="Wednesday"> Wednesday <br>
                            <input type="checkbox" name="thursday" value="Thursday"> Thursday <br>
                            <input type="checkbox" name="friday" value="Friday"> Friday <br>
                            <input type="checkbox" name="saturday" value="Saturday"> Saturday <br>
                            <button type="submit" class="btn btn-primary" style="height:50px;width:15%;background-color:#0892d0"> Submit </button>
                        </form>

                      </div>

                      <div class="tab">When Would You Like Group Members to RSVP by?
                        <p><input placeholder="dd" oninput="this.className = ''" name="dd"></p>
                        <p><input placeholder="mm" oninput="this.className = ''" name="nn"></p>
                        <p><input placeholder="yyyy" oninput="this.className = ''" name="yyyy"></p>
                      </div>
                      <div class="tab">Agenda for the meeting:
                        <p><input placeholder="Username..." oninput="this.className = ''" name="uname"></p>
                      </div>
                      <div style="overflow:auto;">
                        <div style="float:right;">
                          <button type="button" id="prevBtn" onclick="nextPrev(-1)">Previous</button>
                          <button type="button" id="nextBtn" onclick="nextPrev(1)">Next</button>
                        </div>
                      </div>
                      <!-- Circles which indicates the steps of the form: -->
                      <div style="text-align:center;margin-top:40px;">
                        <span class="step"></span>
                        <span class="step"></span>
                        <span class="step"></span>
                        <span class="step"></span>
                      </div>
                    </form>

                    <script>
                    var currentTab = 0; // Current tab is set to be the first tab (0)
                    showTab(currentTab); // Display the current tab

                    function showTab(n) {
                      // This function will display the specified tab of the form...
                      var x = document.getElementsByClassName("tab");
                      x[n].style.display = "block";
                      //... and fix the Previous/Next buttons:
                      if (n == 0) {
                        document.getElementById("prevBtn").style.display = "none";
                      } else {
                        document.getElementById("prevBtn").style.display = "inline";
                      }
                      if (n == (x.length - 1)) {
                        document.getElementById("nextBtn").innerHTML = "Submit";
                      } else {
                        document.getElementById("nextBtn").innerHTML = "Next";
                      }
                      //... and run a function that will display the correct step indicator:
                      fixStepIndicator(n)
                    }

                    function nextPrev(n) {
                      // This function will figure out which tab to display
                      var x = document.getElementsByClassName("tab");
                      // Exit the function if any field in the current tab is invalid:
                      if (n == 1 && !validateForm()) return false;
                      // Hide the current tab:
                      x[currentTab].style.display = "none";
                      // Increase or decrease the current tab by 1:
                      currentTab = currentTab + n;
                      // if you have reached the end of the form...
                      if (currentTab >= x.length) {
                        // ... the form gets submitted:
                        document.getElementById("regForm").submit();
                        return false;
                      }
                      // Otherwise, display the correct tab:
                      showTab(currentTab);
                    }

                    function validateForm() {
                      // This function deals with validation of the form fields
                      var x, y, i, valid = true;
                      x = document.getElementsByClassName("tab");
                      y = x[currentTab].getElementsByTagName("input");
                      // A loop that checks every input field in the current tab:
                      for (i = 0; i < y.length; i++) {
                        // If a field is empty...
                        if (y[i].value == "") {
                          // add an "invalid" class to the field:
                          y[i].className += " invalid";
                          // and set the current valid status to false
                          valid = false;
                        }
                      }
                      // If the valid status is true, mark the step as finished and valid:
                      if (valid) {
                        document.getElementsByClassName("step")[currentTab].className += " finish";
                      }
                      return valid; // return the valid status
                    }

                    function fixStepIndicator(n) {
                      // This function removes the "active" class of all steps...
                      var i, x = document.getElementsByClassName("step");
                      for (i = 0; i < x.length; i++) {
                        x[i].className = x[i].className.replace(" active", "");
                      }
                      //... and adds the "active" class on the current step:
                      x[n].className += " active";
                    }
                    </script>


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




</body>
</html>