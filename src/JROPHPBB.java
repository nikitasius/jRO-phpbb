/**
 * JROPHPBB.java - console application what provide read-only functionality for phpbb forum
 * Copyright (C) 2016  Nikita S. <nikita@saraeff.net>
 * <p>
 * This file is part of jRO-phpbb.
 * <p>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * <p>
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * <p>
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import java.io.*;
import java.net.URL;
import java.net.URLConnection;
import java.sql.*;
import java.util.Calendar;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class JROPHPBB implements Runnable {
    private boolean debug = false;
    private String dbLogin, dbPassw, dbDb, dbHost, dbPort, dbLine;
    private String purgeCacheURI, roGroup, modGroups, defRank;
    private final String[] args;
    private int purgeCacheMethod = -1, checkTimeout = 30;

    private final Pattern pReadOnlyCommand = Pattern.compile("(РО|RO|LS): {0,}(\\d{1,2}d)? {0,}(\\d{1,2}h)? {0,}(\\d{1,3}m)?");//(РО|RO|LS): {0,}(\d{1,2}d)? {0,}(\d{1,2}h)? {0,}(\d{1,3}m)?
    private final Pattern pPurgeCacheUri = Pattern.compile("^http[s]{0,1}:\\/\\/(.*?)\\/(.*?)$", Pattern.CASE_INSENSITIVE); //^http[s]{0,1}:\/\/(.*?)\/(.*?)$
    private Matcher mPurgeCacheUri, mReadOnlyCommand;

    private JROPHPBB(String[] args) {
        this.args = args;
    }

    @Override
    public void run() {
        printInfo("Program started");
        if (loadConfiguration()) {
            if (loadDriver()) {
                processTheWarnings();
            }
        } else printError("Cannot load configuration. Exiting..");
    }

    private boolean loadDriver() {
        try {
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            DriverManager.registerDriver((Driver) Class.forName("com.mysql.jdbc.Driver").newInstance());
            printInfo("MySQL driver is successfully loaded");
            return true;
        } catch (Exception e) {
            printError(e, "Problems are appeared during loading the MySQL driver. Exiting..");
            return false;
        }
    }

    private boolean loadConfiguration() {
        printInfo("Loading configuration");
        StringBuilder sbArgsToParse = new StringBuilder();
        if (this.args[0].equals("-c") && this.args[1] != null) {
            try (BufferedReader brConfigReader = new BufferedReader(new FileReader(new File(this.args[1])))) {
                for (String lineConfig; (lineConfig = brConfigReader.readLine()) != null; ) {
                    sbArgsToParse.append("{").append(lineConfig).append("}");
                }
            } catch (IOException e) {
                printError(e, "IOException during opening a configuration file `" + args[1] + "`");
                return false;
            }
        } else {
            sbArgsToParse.append(this.args[0]);
        }

        Matcher mDatabase = Pattern.compile("\\{database:(.+?)~(.+?)@(.+?):(\\d+)\\/(.*?)\\}", Pattern.CASE_INSENSITIVE).matcher(sbArgsToParse.toString());  //  \{database:(.+?)~(.+?)@(.+?):(\d+)\/(.*?)\}
        Matcher mPurgeCache = Pattern.compile("\\{purgecache:(.*?)\\\\(.+?)\\}", Pattern.CASE_INSENSITIVE).matcher(sbArgsToParse.toString());                //  \{purgecache:(.*?)\\(.+?)}
        Matcher mModgroups = Pattern.compile("\\{modgroups:(.+?)\\}", Pattern.CASE_INSENSITIVE).matcher(sbArgsToParse.toString());                           //  \{modgroups:(.+?)\}
        Matcher mTimeout = Pattern.compile("\\{timeout:(\\d+)\\}", Pattern.CASE_INSENSITIVE).matcher(sbArgsToParse.toString());                              //  \{timeout:(\d+)\}
        Matcher mROGroup = Pattern.compile("\\{rogroup:(\\d+)\\}", Pattern.CASE_INSENSITIVE).matcher(sbArgsToParse.toString());                              //  \{rogroup:(\d+)\}
        Matcher mDefRank = Pattern.compile("\\{defrank:(\\d+)\\}", Pattern.CASE_INSENSITIVE).matcher(sbArgsToParse.toString());                              //  \{defrank:(\d+)\}
        Matcher mDebug = Pattern.compile("\\{debug:(true|false)\\}", Pattern.CASE_INSENSITIVE).matcher(sbArgsToParse.toString());                            //  \{debug:(true|false)\}

        StringBuilder sbError = new StringBuilder();

        if (!mDatabase.find()) {
            sbError.append("Wrong `database` arguments syntax!\n");
        }
        if (!mPurgeCache.find()) {
            sbError.append("Wrong `purgecache` arguments syntax!\n");
        }
        if (!mModgroups.find()) {
            sbError.append("Wrong `modgroups` arguments syntax!\n");
        }
        if (!mROGroup.find()) {
            sbError.append("Wrong `rogroup` arguments syntax!\n");
        }
        if (!mDefRank.find()) {
            sbError.append("Wrong `defrank` arguments syntax!\n");
        }

        if (sbError.length() > 0) {
            printError(sbError.toString());
            return false;
        }

        if (!mTimeout.find()) {
            printInfo("Timeout is not found, program will use a default value = " + this.checkTimeout + " seconds\n");
        } else this.checkTimeout = Integer.valueOf(mTimeout.group(1));

        if (!mDebug.find()) {
            printInfo("Debug value is not found, program will use a default value = `true`\n");
        } else this.debug = Boolean.valueOf(mDebug.group(1));

        this.dbLogin = mDatabase.group(1);
        this.dbPassw = mDatabase.group(2);
        this.dbHost = mDatabase.group(3);
        this.dbPort = mDatabase.group(4);
        this.dbDb = mDatabase.group(5);
        this.dbLine = "jdbc:mysql://" + this.dbHost + ":" + this.dbPort + "/" + this.dbDb;
        this.modGroups = mModgroups.group(1);
        this.roGroup = mROGroup.group(1);
        this.defRank = mDefRank.group(1);
        this.purgeCacheURI = mPurgeCache.group(1);
        switch (mPurgeCache.group(2).toUpperCase()) {
            case "URLCON":
                this.purgeCacheMethod = 0;
                break;
            case "WGET":
                this.purgeCacheMethod = 1;
                break;
            case "CURL":
                this.purgeCacheMethod = 2;
                break;
            case "FETCH":
                this.purgeCacheMethod = 3;
                break;
            default:
                printInfo("Cache purge method is not specified. Cache won't will be purged automatically, you should to do it manually OR change arguments/configuration file.");
                break;
        }
        printInfo("Timeout is `" + this.checkTimeout + "` second(s); moderators' groupIDs are `" + this.modGroups + "`; default rankId is `" + this.defRank + "`; read-only groupId is `" + this.roGroup
                + "`; cache will be purged " + (this.purgeCacheMethod >= 0 && this.purgeCacheMethod <= 3 ?
                "automatically via page `" + mPurgeCache.group(1) + "` using `" + mPurgeCache.group(2) + "`" : "manually"));
        printInfo("Configuration is successfully loaded, loading a MySQL JDBC driver");
        return true;
    }

    private void processTheWarnings() {
        try {
            printInfo("Processing the warnings");
            int handleNewWarningsInt, handleFinishedWarningsInt;
            while ((
                    ((handleNewWarningsInt = processTheNewWarnings()) != -1 && (handleNewWarningsInt == 0 || purgeCacheExecute()))
                            && ((handleFinishedWarningsInt = processTheFinishedWarnings()) != -1 && (handleFinishedWarningsInt == 0 || purgeCacheExecute()))
            )) {
                Thread.sleep(this.checkTimeout * 1000);
            }
        } catch (InterruptedException e) {
            printError(e, "Error is appeared during a `Thread.sleep()` execution for " + this.checkTimeout * 1000 + " seconds. Exiting..");
        }
    }

    private void printError(Exception e, String x) {
        System.err.println((x.length() > 0 ? x + "\n" : "") + Calendar.getInstance().getTime() + "|" + Thread.currentThread().getStackTrace()[1].toString() + "\n");
        e.printStackTrace();
    }

    private void printError(Exception e) {
        System.err.println(Calendar.getInstance().getTime() + "|" + Thread.currentThread().getStackTrace()[1].toString() + "\n");
        e.printStackTrace();

    }

    private void printError(String x) {
        System.err.println((x.length() > 0 ? x + "\n" : "") + Calendar.getInstance().getTime() + "|" + Thread.currentThread().getStackTrace()[1].toString() + "\n");
    }

    private void printInfo(String x) {
        System.out.println(Calendar.getInstance().getTime() + "|" + x);
    }

    private int processTheNewWarnings() {
        String queries[] = {
                "select l.* from phpbb_log l where l.log_type=3 and l.log_operation='LOG_USER_WARNING_BODY' and l.log_id not in (select logid from phpbb_rosystem) and l.user_id in (select user_id from phpbb_user_group where group_id in ({{modgroups}})) and l.reportee_id not in (select user_id from phpbb_user_group where group_id in ({{modgroups}})) and l.log_time>=(UNIX_TIMESTAMP()-7200);"
                , "insert into phpbb_rosystem (logid, date_from, date_to,userby, userto, isactive) values({{log_id}}, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()+{{dayz}}*86400+{{hours}}*3600+{{minutes}}*60,{{user_id}},{{reportee_id}},1);"
                , "update phpbb_rosystem set isactive=2 where userto={{reportee_id}} and isactive=1;"
        };
        try (Connection connWarningsNew = DriverManager.getConnection(dbLine, dbLogin, dbPassw);
             Statement stWarningsNew = connWarningsNew.createStatement();
             ResultSet rsWarningsNew = stWarningsNew.executeQuery(queries[0]
                             .replace("{{modgroups}}", this.modGroups)
             )) {
            boolean fondNewWarnings = false;
            while (rsWarningsNew.next()) {

                this.mReadOnlyCommand = this.pReadOnlyCommand.matcher(rsWarningsNew.getString("log_data"));
                if (this.mReadOnlyCommand.find()) {
                    if (this.mReadOnlyCommand.group(1) != null) {
                        fondNewWarnings = true;
                        try (Connection connUpdate = DriverManager.getConnection(this.dbLine, this.dbLogin, this.dbPassw);
                             Statement stUpdateWarnings = connUpdate.createStatement()) {
                            stUpdateWarnings.executeUpdate(queries[2]
                                            .replace("{{log_id}}", rsWarningsNew.getString("log_id"))
                                            .replace("{{reportee_id}}", rsWarningsNew.getString("reportee_id"))
                            );

                            stUpdateWarnings.executeUpdate(queries[1]
                                            .replace("{{log_id}}", rsWarningsNew.getString("log_id"))
                                            .replace("{{dayz}}", (this.mReadOnlyCommand.group(2) != null ? this.mReadOnlyCommand.group(2).replace("d", "") : "0"))
                                            .replace("{{hours}}", (this.mReadOnlyCommand.group(3) != null ? this.mReadOnlyCommand.group(3).replace("h", "") : "0"))
                                            .replace("{{minutes}}", (this.mReadOnlyCommand.group(4) != null ? this.mReadOnlyCommand.group(4).replace("m", "") : "0"))
                                            .replace("{{user_id}}", rsWarningsNew.getString("user_id"))
                                            .replace("{{reportee_id}}", rsWarningsNew.getString("reportee_id"))
                            );

                            if (this.debug)
                                printInfo("processTheNewWarnings:NEW Read-Only:" + rsWarningsNew.getString("user_id") + ":" + rsWarningsNew.getString("reportee_id") + ":" +
                                        (this.mReadOnlyCommand.group(2) != null ? this.mReadOnlyCommand.group(2) : "0") + ":" +
                                        (this.mReadOnlyCommand.group(3) != null ? this.mReadOnlyCommand.group(3) : "0") + ":" +
                                        (this.mReadOnlyCommand.group(4) != null ? this.mReadOnlyCommand.group(4) : "0") + ":");
                        }
                    }
                }
            }
            return (fondNewWarnings ? 1 : 0);
        } catch (SQLException e) {
            printError(e, "SQLError is appeared during working with DB. Exiting..");
            return -1;
        }
    }

    private int processTheFinishedWarnings() {
        String queries[] = {
                "select group_concat(id) as 'ids', group_concat(distinct(userto)) as 'uids' from phpbb_rosystem where isactive=3;"
                , "update phpbb_rosystem set isactive=4 where id in ({{ids}});"
                , "delete from phpbb_user_group where group_id={{rogroup}} and user_id in ({{uids}});"
                , "update phpbb_users set user_rank={{defrank}} where user_id in ({{uids}});"
        };
        try {
            try (Connection connWarningsFinished = DriverManager.getConnection(dbLine, dbLogin, dbPassw);
                 Statement stWarningsFinished = connWarningsFinished.createStatement();
                 ResultSet rsWarningsFinished = stWarningsFinished.executeQuery(queries[0])) {
                if ((rsWarningsFinished.next()) && (rsWarningsFinished.getString("ids") != null)) {
                    if (this.debug) {
                        printInfo(
                                "processTheFinishedWarnings:IDS:" + rsWarningsFinished.getString("ids") + "|processTheFinishedWarnings:UIDS:" + rsWarningsFinished.getString("uids"));
                    }
                    try (Statement stUpd = connWarningsFinished.createStatement()) {
                        stUpd.executeUpdate(queries[1].replace("{{ids}}", rsWarningsFinished.getString("ids")));
                        stUpd.executeUpdate(queries[2]
                                .replace("{{rogroup}}", this.roGroup)
                                .replace("{{uids}}", rsWarningsFinished.getString("uids")));
                        stUpd.executeUpdate(queries[3]
                                .replace("{{defrank}}", this.defRank)
                                .replace("{{uids}}", rsWarningsFinished.getString("uids")));
                    }
                    return 1;
                } else return 0;
            }
        } catch (SQLException e) {
            printError(e, "SQLError is appeared during working with DB. Exiting..");
            return -1;
        }
    }

    private boolean purgeCacheExecute() {
        printInfo("Starting a cache purge");
        switch (this.purgeCacheMethod) {
            case 0:
                return purgeCacheViaURLCon();
            case 1:
                return purgeCacheViaWget();
            case 2:
                return purgeCacheViaCurl();
            case 3:
                return purgeCacheViaFetch();
            default:
                printInfo("Cache purge method is not specified. Cache isn't purged. Purge it manually."); //probably someone will do it manually or have his own way
                return true;
        }
    }

    private boolean purgeCacheViaWget() {
        try {
            Runtime.getRuntime().exec(new String[]{"sh", "-c", "wget -q '{{purge_cache_uri}}' -O '/dev/null'".replace("{{purge_cache_uri}}", this.purgeCacheURI)});
            if (this.debug) printInfo("Cache successfully purged via `wget`");
            return true;
        } catch (IOException e) {
            printError(e, "Cannot execute `sh -c \"wget -q '{{purge_cache_uri}}' -O '/dev/null'`\"".replace("{{purge_cache_uri}}", this.purgeCacheURI));
            return false;
        }
    }

    private boolean purgeCacheViaCurl() {
        try {
            Runtime.getRuntime().exec(new String[]{"sh", "-c", "curl '{{purge_cache_uri}}' > '/dev/null' 2>&1".replace("{{purge_cache_uri}}", this.purgeCacheURI)});
            if (this.debug) printInfo("Cache successfully purged via `curl`");
            return true;
        } catch (Exception e) {
            printError(e, "Cannot execute `sh -c \"curl '{{purge_cache_uri}}' > '/dev/null' 2>&1`\"".replace("{{purge_cache_uri}}", this.purgeCacheURI));
            return false;
        }
    }

    private boolean purgeCacheViaFetch() {
        try {
            Runtime.getRuntime().exec(new String[]{"sh", "-c", "fetch '{{purge_cache_uri}}' -o '/dev/null' 2>&1".replace("{{purge_cache_uri}}", this.purgeCacheURI)});
            if (this.debug) printInfo("Cache successfully purged via `fetch`");
            return true;
        } catch (Exception e) {
            printError(e, "Cannot execute `sh -c \"fetch -o '/dev/null' '{{purge_cache_uri}}' 2>&1\"".replace("{{purge_cache_uri}}", this.purgeCacheURI));
            return false;
        }
    }

    private boolean purgeCacheViaURLCon() {
        URL pageUri;
        URLConnection urlConn;
        this.mPurgeCacheUri = this.pPurgeCacheUri.matcher(this.purgeCacheURI);
        try {
            if (this.mPurgeCacheUri.find()) {
                pageUri = new URL(this.purgeCacheURI);
                printInfo(this.purgeCacheURI);
                printInfo(this.mPurgeCacheUri.group(1));
                urlConn = pageUri.openConnection();
                urlConn.setRequestProperty("Host", this.mPurgeCacheUri.group(1));
                urlConn.setRequestProperty("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
                urlConn.setRequestProperty("User-Agent", "jRO-phpbb (" + System.getProperty("os.name") + System.getProperty("os.version") + ")");
                urlConn.getInputStream().close();   //request a page jsut to purge the cache
                if (this.debug) printInfo("Cache successfully purged via `URLConnection`");
                return true;
            } else return false;
        } catch (Exception e) {
            printError(e, "An error is appeared during connecting via URLConnection. Solve the problem OR use alternative methods. Exiting..");
            return false;
        }
    }

    public static void main(String[] args) {
        System.out.println(
                new StringBuilder().append("JROPHPBB  Copyright (C) 2016  Nikita S. <nikita@saraeff.net>")
                        .append("This program comes with ABSOLUTELY NO WARRANTY.\n")
                        .append("This is free software, and you are welcome to redistribute it\n")
                        .append("under certain conditions; read GPLv3+ for details\n")
                        .append("License: GPLv3+\n\n")
                        .append("Read-only (`IPB like`) system for PHPBB boards (https://github.com/nikitasius/jRO-phpbb)\n\n"));
        if (args == null || args.length == 0) {
            System.out.print(
                    new StringBuilder()
                            .append("\nUsage: java JROPHPBB '{database:login~passwd@server:port/phpbb}{purgecache:http://example.com/purgecache.php\\wget}{modgroups:2,3}{timeout:30}{rogroup:8}{defrank:0}{debug:true}'")
                            .append("\n{database:login~passwd@server:port/phpbb}" +
                                    "\n\t`login` - mysql username" +
                                    "\n\t`passwd` - mysql password" +
                                    "\n\t`server` - server adress or IP" +
                                    "\n\t`port` - mysql port (default 3306)" +
                                    "\n\t`phpbb` - database name")
                            .append("\n{purgecache:http://example.com/purgecache.php\\wget}" +
                                    "\n\t`http://example.com/purgecache.php` - a link to php file, accesible from server to execute the cache purging" +
                                    "\n\t`wget`/`curl`/`fetch`/`urlcon` - name of specified tool to be called via `sh -c` OR use `urlcon`(URLConnection) for internal connections without external tools")
                            .append("\n{modgroups:4,5,6}" +
                                    "\n\t`4,5,6` - all warning are made by this groups WILL be processed with jRO-phpbb and NEVER against this groups, if you have single group with ID 5, you should to replace `4,5,6` with `5`")
                            .append("\n{timeout:30}" +
                                    "\n\t`30` - timeout between checking warnings in DB (in seconds)")
                            .append("\n{rogroup:8}" +
                                    "\n\t`8` - readonly group ID on PHPBB forum")
                            .append("\n{defrank:0}" +
                                    "\n\t`0` - default user rank ID (NOT the read-only rank!)")
                            .append("\n{debug:true}" +
                                    "\n\t`true`/`false` - show (true) or not (false) console output\n\n")
            );
            System.exit(0);
        } else try {
            new Thread(new JROPHPBB(args)).start();
        } catch (Throwable t) {
            System.err.println(Calendar.getInstance().getTime() + "|" + Thread.currentThread().getStackTrace()[1].toString());
            t.printStackTrace();
        }
    }
}