<%--
   jbanphpbbtable.jsp - interactive page that display active bans
    Copyright (C) 2016  Nikita S. <nikita@saraeff.net>

    This file is part of jRO-phpbb.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.util.HashMap" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" trimDirectiveWhitespaces="true" session="false" %>
<%
    class JBANTable {
        final String dbLogin = "MYSQL_PHPBB_USERNAME", dbPassw = "MYSQL_PHPBB_PASSWD", dbDb = "MYSQL_PHPBB_DATABASE", dbHost = "MYSQL_SERVER", dbPort = "MYSQL_POST";
        final String dbLine = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbDb;

        private boolean showRecords = true;
        private final JspWriter out;

        /*
        I've added some comments for people who can port this page on PHP using PHPBB login credentials from config file
         */
        private HashMap<Integer, String> dict = new HashMap<Integer, String>(); // here we keep a translations

        final String
                FORUM_URI = "http://example.com/forum", //REPLACE,   `//example.com/forum` in case if you work on HTTP&HTTPS
                FORUM_NAME = "My Example Forum", //REPLACE with your board's title
                ROPAGEPATH = "/tools/showbanlist.html"; //REPLACE with your `related path` for this page, i.e.  for `example.com/bantable.htm` you need to replace with `/bantable.htm`

        private String queries[] = {
                ("select b.ban_id,\n" +
                        "b.ban_userid  as 'b.bannedid', u1.username as 'b.bannedusername',\n" +
                        "FROM_UNIXTIME(b.ban_start) as 'b.bannedfromdate',\n" +
                        "if(b.ban_end=0,'{{neverexpire}}',b.ban_end) as 'b.bannedtodate',\n" +
                        "l.user_id as 'b.bannedbyid', u2.username 'b.bannedbyusername', b.ban_reason\n" +
                        "from phpbb_banlist b,  phpbb_log l, phpbb_users u1, phpbb_users u2\n" +
                        "where u1.user_id=b.ban_userid\n" +
                        "and l.reportee_id=b.ban_userid\n" +
                        "and l.log_operation='LOG_BAN_USER'\n" +
                        "and u2.user_id=l.user_id\n" +
                        "order by b.ban_id desc\n" +
                        "limit 5000;")//5000 last records will be diplayed.
        };

        JBANTable(JspWriter out) {
            this.out = out;
        }

        private boolean loadMySQLDriver() {
            try {
                Class.forName("com.mysql.jdbc.Driver").newInstance();
                DriverManager.registerDriver((Driver) Class.forName("com.mysql.jdbc.Driver").newInstance());
                return true;
            } catch (ClassNotFoundException | InstantiationException | IllegalAccessException | SQLException e) {
                showRecords = false;
                return false;
            }
        }

        /**
         * Replaces some symbols when finding it
         * @param line
         * @return corrected string
         */
        private String replaceChars(String line) {
            return line
                    .replace("<", "&lt;")
                    .replace(">", "&gt")
                    .replace("\"", "&quot;")
                    .replace("«", "&laquo;")
                    .replace("»", "&raquo;")
                    .replace("\n", "<br>");
        }

        private void printError(Exception e) {
            System.err.println(Calendar.getInstance().getTime() + "|" + Thread.currentThread().getStackTrace()[1].toString() + "\n");
            e.printStackTrace();
        }

        /**
         * Loading ditionary. Simple query to `phpbb_jrolang` table.
         * Writes result (`id`:`t`) into HashMap and `id` is a key
         * It mean `key=id` from `phpbb_jrolang` table.
         */
        private void loadDict() {
            try (Connection conn = DriverManager.getConnection(this.dbLine, this.dbLogin, this.dbPassw);
                 Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("select * from phpbb_jrolang;")) {
                while (rs.next()) {
                    this.dict.put(new Integer(rs.getInt("id")), new String(rs.getString("t")));
                }
            } catch (SQLException e) {
                printError(e);
                this.showRecords = false;
                return;
            }
        }

        private void printInfo(String x) {
            System.out.println(Calendar.getInstance().getTime() + "|" + x);
        }

        /**
         * writes a read-only history from board. Simple query[0] from a query array, `getString("columnName")` just get some String data by colum names as `columnName`.
         * While we have rows, we are filling `sb` with same text fragment and replacing {parts} with column values.
         * once `while` is finished, we are inserting result into the page.
         */
        private void getBannedUsersList() {
            if (!this.showRecords) return;
            StringBuilder sb = new StringBuilder();
            try {
                try (Connection conn = DriverManager.getConnection(this.dbLine, this.dbLogin, this.dbPassw);
                     Statement st = conn.createStatement();
                     ResultSet rs = st.executeQuery(this.queries[0])) {
                    while (rs.next()) {
                        sb.append(("<tr>\n" +
                                        "    <td>{{id}}</td>\n" +
                                        "    <td><a href=\"" + FORUM_URI + "/memberlist.php?mode=viewprofile&u={{userby}}\" target=\"_blank\">{{banby}}</a></td>\n" +
                                        "    <td><a href=\"" + FORUM_URI + "/memberlist.php?mode=viewprofile&u={{userto}}\" target=\"_blank\">{{banto}}</a></td>\n" +
                                        "    <td>{{banfromdate}}</td>\n" +
                                        "    <td>{{bantodate}}</td>\n" +
                                        "    <td>{{banreason}}</td>\n" +
                                        "</tr>")
                                        .replace("{{id}}", rs.getString("b.ban_id"))
                                        .replace("{{userby}}", rs.getString("b.bannedbyid"))
                                        .replace("{{userto}}", rs.getString("b.bannedid"))
                                        .replace("{{banby}}", replaceChars(rs.getString("b.bannedbyusername")))
                                        .replace("{{banto}}", replaceChars(rs.getString("b.bannedusername")))
                                        .replace("{{banfromdate}}", rs.getString("b.bannedfromdate"))
                                        .replace("{{bantodate}}", rs.getString("b.bannedtodate"))
                                        .replace("{{neverexpire}}", this.dict.get(16))
                                        .replace("{{banreason}}", rs.getString("b.ban_reason"))
                        );
                    }
                }
                out.println(sb);
            } catch (SQLException | IOException e) {
                printError(e);
                return;
            }
        }
    }
    JBANTable rvm = new JBANTable(out);
    try {
        rvm.loadMySQLDriver();
        rvm.loadDict();
    } catch (Throwable t) {
        System.err.println(Calendar.getInstance().getTime() + "|" + Thread.currentThread().getStackTrace()[1].toString());
        t.printStackTrace();
        rvm.showRecords = false;
        return;
    }
    /*
    below is html code.
    `rvm.dict.get(0)` mean element with key=0 from hashmap what equal row with `id=0` `from phpbb_jrolang`
    `rvm.FORUM_URI` - just a simple access to variable `FORUM_URI`.
     */
%>
<html>
<head>
    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.5/css/bootstrap.min.css">

    <!-- Optional theme -->
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.5/css/bootstrap-theme.min.css">
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/datatables/1.10.8/css/dataTables.bootstrap.min.css">

    <!-- Latest compiled and minified JavaScript -->
    <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.5/js/bootstrap.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/datatables/1.10.8/js/jquery.dataTables.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/datatables/1.10.8/js/dataTables.bootstrap.min.js"></script>
</head>
<body>
<h3 align="center"><%=rvm.dict.get(5)%> <a href="<%=rvm.FORUM_URI%>" target="_blank">&nbsp;<%=rvm.FORUM_NAME%>
</a></h3>

<div align="center">
    <%=rvm.dict.get(6)%>: <a class="toggle-vis" data-column="1">[<%=rvm.dict.get(7)%>]</a> -
    <a class="toggle-vis" data-column="2">[<%=rvm.dict.get(8)%>]</a> -
    <a class="toggle-vis" data-column="3">[<%=rvm.dict.get(9)%>]</a> -
    <a class="toggle-vis" data-column="4">[<%=rvm.dict.get(10)%>]</a> -
    <a class="toggle-vis" data-column="5">[<%=rvm.dict.get(11)%>]</a> - -
    <a onclick="resetTable();"><strong><%=rvm.dict.get(13)%>
    </strong></a>
</div>
<p style="font-size: small" align="center">(!) <%=rvm.dict.get(14)%> (!)</p>
<table id="jrophpbb-banned-users-table" class="table table-striped table-bordered" cellspacing="0" width="100%">
    <thead>
    <tr>
        <th>#</th>
        <th><%=rvm.dict.get(7)%>
        </th>
        <th><%=rvm.dict.get(8)%>
        </th>
        <th><%=rvm.dict.get(9)%>
        </th>
        <th><%=rvm.dict.get(10)%>
        </th>
        <th><%=rvm.dict.get(11)%>
        </th>
    </tr>
    </thead>
    <tfoot>
    <tr>
        <th>#</th>
        <th><%=rvm.dict.get(7)%>
        </th>
        <th><%=rvm.dict.get(8)%>
        </th>
        <th><%=rvm.dict.get(9)%>
        </th>
        <th><%=rvm.dict.get(10)%>
        </th>
        <th><%=rvm.dict.get(11)%>
        </th>
    </tr>
    </tfoot>

    <tbody>
    <%rvm.getBannedUsersList();%>
    </tbody>
</table>

<script type="text/javascript">
    $(document).ready(function () {
        var table = $('#jrophpbb-banned-users-table').DataTable({
            "bPaginate": true,
            "bLengthChange": true,
            "bFilter": true,
            "bSort": true,
            "bInfo": true,
            "bProcessing": true,
            "bStateSave": true,
            "bAutoWidth": true,
            "order": [
                [0, "desc"]
            ]
        });
        $('a.toggle-vis').on('click', function (e) {
            e.preventDefault();

            // Get the column API object
            var column = table.column($(this).attr('data-column'));

            // Toggle the visibility
            column.visible(!column.visible());
        });
    });
    function resetTable() {
        localStorage.removeItem('DataTables_jrophpbb-banned-users-table_<%=rvm.ROPAGEPATH%>');
        location.reload();
    }
</script>
</body>
</html>