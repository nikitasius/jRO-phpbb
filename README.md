#jRO-phpbb
**[ENG]** [[RUS]](/README.ru.md)

## WARNING
## USE AT YOUR OWN RISK. SOFTWARE MAY CAUSE DATA LOSS, SYSTEM CRASHES, AND RED EYES.
### Read-only system for phpbb 3.1+ boards.

## Description
jRO-phpbb provide read-only access for a forum members. When you send a warning to the offending user, they are
automatically demoted to read-only status.

## How does `it` work
* moderator create a new `warning`;
* `warning` trigger a `phpbb_log__after_insert` trigger what makes a copy of warning into the table
`phpbb_log_warnings`;
* `JROPHPBB.java` by timeout ask db for `new` warnings (up to 2 hours ago) AND for a `finished` warnings;
* when the `JROPHPBB.java` got the new warnings it executes a script to finish warnings what 'already' exists for user.
For example if user already had a read-only for 2 minute and last
warning gives read-only mode for 1 minute, finally user will have warning of 1 minute from the moment when warning has
beed processed;
* after this `JROPHPBB.java` insert the record about read-only into the `phpbb_rosystem` table, what trigger
`phpbb_rosystem__after_insert` trigger.
This trigger deletes information about the read-only group from the table `phpbb_user_group` AND insert the record about
read-only group for the same user AND set a new rank. It made to avoid a dublicates AND keep this logic on the database
side;
* scheduler `phpbb_rosystem__autoremove_readonly` updates the table `phpbb_rosystem` every 30 seconds to change a status
on `finished` for the records what should be finished;
* after the records from `phpbb_rosystem` with status `finished` processed by `JROPHPBB.java` to change the status on
`finished and removed`, same time `JROPHPBB.java` deletes read-only group from the `phpbb_user_group` table for selected
user and return him a default rank.
* scheduler `phpbb_log__warnings__clean` clean 1 time per hour the table `phpbb_log_warnings` via removing a records
which doesn't contain a `LOG_USER_WARNING_BODY` in a `log_operation` column;

Thats all. Part of the logic is in the program, part on the mysql side (which work pretty fast)

###This system `doesn't move` user into the read-only group, this system `ADD` user into the read-only group. This system `doesn't require` special `permissions` for your moderators they `just` have to `write warnings`.

## How to work `with`
* moderator create a warning for a user which contain **line** `RO`/`LS`/`РО`  (РО - russian letters "R" and "O") and
time i.e. `RO:{space}XXd{space}YYh{space}ZZZm` where is
`XX` - days, `YY` - hours, `ZZZ` - minutes and `{space}` - a space punctuation symbol equal to ` `.

(!) Spaces are **important** (!)

1 minute read-only:
> RO: 1m

1 hour read-only:
> RO: 1h

1 day and 1 minute read-only:
> RO: 1d 1m

You can add a custom text, like:
> Bad, bad user!

> You'll stay in the read-only for 1 day and 15 minutes!

> RO: 1d 15m

> Hope it will teach you.

or
> Spam on the board

> RO: 14d

same time you can remove active read-only by giving a `zero` time:
> removing readonly

> RO: 0m

> sorry mate <3

Or you can write just "`RO:{space_here}`", it's equal to `RO: 0m`

or you can use it directly in line, like:
> Because of spam you got RO: 1d , relax 1 day!

Feel free to write a custom texts, but don't forget - remember about at least 1 space in the `RO: 1d 2h 3m` message.

When a `debug` mode is activated and the program fond the new warning(s), you'll see a following text for each warning:
>Wed Aug 03 18:47:40 UTC 2016|processTheNewWarnings:NEW Read-Only:2:62:0:0:2m:

>Wed Aug 03 18:47:40 UTC 2016|Starting cache purge

>Wed Aug 03 18:47:41 UTC 2016|cache successfully purged via `wget`

where is `NEW Read-Only:2:62:0:0:2m:` - 2 - ID who made the warning, 62 - ID who receive the warning, 0:0:2m =
0 days, 0 hours and 2 minutes.

Finished read-only warning have this message:

>Wed Aug 03 18:50:01 UTC 2016|processTheFinishedWarnings:IDS:26|processTheFinishedWarnings:UIDS:62

>Wed Aug 03 18:50:01 UTC 2016|Starting cache purge

>Wed Aug 03 18:50:01 UTC 2016|cache successfully purged via `wget`

Where `26` the record ID from `phpbb_rosystem` table and `62` - user ID who have read-only mode finished.
Multiple records separated by `,` i.e `26,27` and `62,63`.


## Project structure

* `/conf/` - here is configuraion file example

* `/compiled/` - here is compiled `JROPHPBB.java`:
`javac -cp .:mysql-connector-java-5.1.39-bin.jar JROPHPBB.java`
* `/compiled/java_7` - compiled for `Java 7` (`1.7.0_65-b17`)
* `/compiled/java_8` - compiled for `Java 8` (`1.8.0_102-b14`)

* `/pages/` - here are `jrophpbbtable.jsp` - an interactive JSP page with read-only users. Working example can be fond
[**here**](http://ru-eve.com/tools/showreadonly.html) and `purgecache.php` - a php script which will purge board's
cache on execution.

* `/sql/` - here are SQL queries for your database. They all well tested and work with MySQL.

* `/sql/00-languages/` - here are translations for the interactive JSP page. `00-phpbbb_jrolang.sql` - used to create a
table where keep the translations.
Translations are in a `01-phpbb_jrolang-XX.sql` files, where `XX` - 2-letters language code, i.e.
`01-phpbb_jrolang-en.sql` - english, `01-phpbb_jrolang-fr.sql` - french or `01-phpbb_jrolang-ru.sql` russian.
At once you can have only 1 translation installed.

* **OPTIONAL** scripts are `90-phpbb_posts_log.sql` and `91-phpbb_posts__before_delete.sql`. They're used to keep a copy
of posts when someone deletes them from database. In case when moderator will delete the post permamently you always
have a backup in the table `phpbb_posts_log`.

* `/src/` - here is source `JROPHPBB.java`. Compatible with Java 7.

## Preparation
### Java (JDK or JRE)
If you prefer to compile all, you need a [**JDK**](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html),
if you prefer to run already compiled class, you need a JRE ([**simple**](http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html)
or the [**server version**](http://www.oracle.com/technetwork/java/javase/downloads/server-jre8-downloads-2133154.html)).
### Libraries
You need a [**Connector/J**](https://dev.mysql.com/downloads/connector/j/). I've used version `mysql-connector-java-5.1.39-bin.jar`.
Installation guide is [here](https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-installing.html).
If you use `java from the box` (i.e. just downloaded and installed), you can copy this jar into `/lib/` folder in your
`jre` AND `jdk` (if you installed JDK).

### Compilation
Enter folder `src`, place inside a file `mysql-connector-java-5.1.39-bin.jar` and execute following command:

    javac -cp mysql-connector-java-5.1.39-bin.jar JROPHPBB.java

If you have JDK8 on your dev machine and JDK7 on server, you can compile for JDK7 using following command:

    javac -source 7 -target 7 -bootclasspath /path/to/jdk7/jre/lib/rt.jar -cp .:mysql-connector-java-5.1.39-bin.jar JROPHPBB.java

or.. just to compile with javac from JDK7 :D

### SQL queries
* Execute a query `00-phpbb_jrolang.sql` from a `/sql/00-languages/00-phpbbb_jrolang.sql`, after from the same folder
`/sql/00-languages/` execute the query what correspond to your language.
* Execute the `/sql/01-phpbb_rosystem.sql`
* Execute the `/sql/02-phpbb_log_warnings.sql`
* Execute the `/sql/03-phpbb_log__after_insert.sql`
* Execute the `/sql/04-phpbb_log_warnings__clean.sql`
* Execute the `/sql/05-phpbb_rosystem__autoremove_readonly.sql`
* **Read**, **EDIT** and execute the `/sql/06-phpbb_rosystem__after_insert.sql`

Here is an **OPTIONAL** queries `/sql/90-phpbb_posts_log.sql` and `/sql/91-phpbb_posts__before_delete.sql` what add a
`post backup` feature to your pbpbb board.

###Web pages
* copy a file `/pages/purgecache.php` in your board's ROOT folder and **rename** it (the file).
* **Read**, **EDIT**, copy a file `/pages/jrophpbbtable.jsp` in your JSP continer's ROOT page folder. Same time you can ignore this step
(if you don't need this page) or you can code this on `PHP` using queries from current JSP table and page as template
(live example can be found [here](http://ru-eve.com/tools/showreadonly.html))

###PHPBB board
* You need to create the `read-only` group if doesn't exists (group what provide read-only access with revoked write)
* You need to create a new rank what will be used for read-only users, i.e. "Have fun in read-only mode" etc.
* Read-only group example can be found in [`/img/`](/img/) directory.

**OPTIONAL** tricks:
* if you use a nginx, you can create the rank with a name `readonlyuserrank`
* after you'll need to build `nginx` with [`ngx_http_substitutions_filter_module`](https://github.com/yaoweibin/ngx_http_substitutions_filter_module/)
module
* create a file in `/conf/` folder with name `subs_phpbbrank`
* add following text into the file `subs_phpbbrank`:

    subs_filter_types text/html;

    `subs_filter 'readonlyuserrank'  '<a href="http://your/boards/adress/jrophpbbtable.jsp" target="_blank" style="color: #FF40FF">Have fun in read-only mode</a>' gi;`


* add in your nginx's configuration file following line: `include subs_phpbbrank;`
* reload your nginx `nginx -s reload`

And each time when `JROPHPBB` place a user inside  the `read-only` group, the user will have a clickable rank linked
with read-only `jrophpbbtable.jsp` on your server.

### Execution
To see the `help` just execute program as:

    java JROPHPBB

Check the file `mysql-connector-java-5.1.39-bin.jar` (or another lib if you use a different version) in the same folder
with compiled `JROPHPBB.class`

To run with configuration file use following command:

    java -cp .:mysql-connector-java-5.1.39-bin.jar JROPHPBB -c /path/to/jrophpbb.conf

To run without configuration file use following command:

    java -cp .:mysql-connector-java-5.1.39-bin.jar JROPHPBB '{database:login~passwd@server:port/phpbb}{purgecache:http://example.com/purgecache.php\wget}{modgroups:2,3}{timeout:30}{rogroup:8}{defrank:0}{debug:true}'

**Linux**: To add output in a log you should to add `2>&1 >> jrophpbb.log`, like

    java -cp .:mysql-connector-java-5.1.39-bin.jar JROPHPBB -c /path/to/jrophpbb.conf 2>&1 >> jrophpbb.log

or

    java -cp .:mysql-connector-java-5.1.39-bin.jar JROPHPBB '{database:login~passwd@server:port/phpbb}{purgecache:http://example.com/purgecache.php\wget}{modgroups:2,3}{timeout:30}{rogroup:8}{defrank:0}{debug:true}' 2>&1 >> jrophpbb.log

in case when there is no configuration file

To maintain this program i use `screen` under debian. Just execute `screen` and after execute command line from the example.
After i click `ctrl`+(`A`+`D`) and it's in background.

##Errors
###URLConnection/certificate error
>javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed:
>unable to find valid certification path to requested target

####Whats happen?
Java didn't found a root certificate in your keystore.
####How to fix?
* Open a website
* Download the root certificate
* Import into your keystore

To import use the following command:

    keytool -importcert -file '/path/to/cert.crt' -keystore '/path/to/jre/lib/security/cacerts' -alias 'aliasForCertificate'

Default password is `changeit`

**OR** just use `wget`/`curl`/`fetch` method to purge cache.

##Why `THIS`?
I was looking for a read-only functional for phpbb boards, like we can see in IPB boards. Unfortuntely i didn't fond a
plugin on official website, so i've create my own `system`.

####Why on Java?
Because i know Java and i don't remember PHP as well to write a plugin.

####Why JSP and not JSF?
Because it's a very small and simple page. I don't love JSF style, but it's useless to create tons of XML for a single
page with table.. Hell, no!

##Help with the project:
* we need your translations, you can use an example from `/sql/00-languages/01-phpbb_jrolang-XX.sql.example` to create
your own (language or *LEET*) and send it me on my email or via `pull` request. The example can be found inside the file
`01-phpbb_jrolang-XX.sql.example`, all what you need to do is to keep GPLv3 licence inside, write your name/nickname,
email (optional) and the translation and your support link (via email in my mailbox, i'll post it below)

* we'll be glad to have a PHP version of our JSP page. There is no problems to install JDK/JRE on server and compile/launch
the programm, but people still can have a difficulties with JSP and Tomcat/Glassfish tuning. Don't forget to add your
license inside. Best choise is [**GPLv3**](https://www.gnu.org/licenses/gpl-3.0.html).

If you liked this project, you can always support following contributors:
* **me** via [PayPal](https://www.paypal.me/nikitasius) for `jRO-phpbb`'s idea and realization
* *for the moment is empty*
* *for the moment is empty*
* ...
* *for the moment is empty*

Cheers, nikitasius.