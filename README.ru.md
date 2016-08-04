#jRO-phpbb
[[ENG]](/README.md) **[RUS]**

## ВНИМАНИЕ
## ИСПОЛЬЗУЙТЕ НА СВОЙ СТРАХ И РИСК. ПО МОЖЕТ БЫТЬ ПРИЧИНОЙ ПОТЕРИ ДАННЫХ, СИСТЕМНЫХ КРАХОЙ И КРАСНОГЛАЗИЯ.
### РО (только для чтения) система для форумов под управлением phpbb.

## Описание
С помощью jRO-phpbb можно отправлять пользователей в РО посредством системы предупреждений.

## Как `это` работает
* Модератор выдает пользователю `предупреждение`;
* `предупреждение` активирует триггер `phpbb_log__after_insert`, который копирует сие `предупреждение` в таблицу
`phpbb_log_warnings`;
* `JROPHPBB.java` по таймауту опрашивает базу на наличие `новых` предупреждений (за сроком давности от 2х часов)
И на наличие `завершенных` предупреждений;
* получив новые предупреждения, `JROPHPBB.java` завершает текущие РО для пользователя при их наличии. Например, если
у пользователя висит РО на 2 часа, и ему выписали РО на 5 минут и следом на 2 минуты, то активным будет РО на 2 минуты;
* после этого `JROPHPBB.java` вставляет в таблицу `phpbb_rosystem` данные о новом РО, что активирует триггер
`phpbb_rosystem__after_insert`.
Этот триггер удаляет запись о РО группе для пользователя из таблицы `phpbb_user_group` И добавляет группу РО И так же
изменяет его ранг. Это сделано для того, чтобы избежать дублекатов (глюк или ручные правки) и оставить логику на БД;
* событие `phpbb_rosystem__autoremove_readonly` обновляет таблицу `phpbb_rosystem` каждые 30 секунд, изменяя статус РО
на `завершено` для тех РО, которые истекли;
* после этого записи из таблицы `phpbb_rosystem` со статусов `завершенные` обрабатываются `JROPHPBB.java` для изменения
их статуса на `завершено и снято`, в то же время `JROPHPBB.java` удаляет записи о РО группе из таблицы `phpbb_user_group`
и возвращает пользователю ранг по умолчанию.
* событие `phpbb_log__warnings__clean` очищает таблицу `phpbb_log_warnings` 1 раз в час, удаляя записи, которые не
содержат `LOG_USER_WARNING_BODY` в колонке `log_operation`;

Вот и все. Часть логики лежит на программе, часть логики на базе. И все работает весьма шустро.

## Как работать `с`
* Модератор создает предупреждение, которое содержит **строку** `RO`/`LS`/`РО`  (РО - русские "Р" и "О") и время, то есть
`РО:{пробел}XXd{пробел}YYh{пробел}ZZZm` где
`XX` - дни, `YY` - часы, `ZZZ` - минуты `{пробел}` - это пробел :-)

(!) Пробелы **обязательны** (!)

РО на 1 минуту
> РО: 1m

РО на час
> РО: 1h

РО на день и минуту
> РО: 1d 1m

Так же можно добавить текст вида
> Плохой юзер!

> Выдаю тебе РО на сутки и 15 минут сверху!!

> РО: 1d 15m

> Проведи время с пользой.

или

> Спам на форуме

> РО: 14d

чтобы снять РО, надо выдать РО с `нулевым` временем

> Снимаю РО

> РО: 0m

> Извини, промахнулся)

Так же все можно писать в одну строку:
> За спам отправляю в РО: 1d , отдохни сутки!

Можно использоват любые тексты, главное не забыть о наличии как минимум одного пробела в `РО: 1d 2h 3m` сообщении.

Когда активирован режим отладки `debug` и программа находит новые предупреждения, то вы увидите следующий текст:
>Wed Aug 03 18:47:40 UTC 2016|processTheNewWarnings:NEW Read-Only:2:62:0:0:2m:

>Wed Aug 03 18:47:40 UTC 2016|Starting cache purge

>Wed Aug 03 18:47:41 UTC 2016|cache successfully purged via `wget`

где `NEW Read-Only:2:62:0:0:2m:` - 2 - ID кто выдал РО, 62 - кому выдали РО, 0:0:2m = 0 дней, 0 часов и 2 минуты.

Завершенные РО имеют слеющие сообщения в логе:

>Wed Aug 03 18:50:01 UTC 2016|processTheFinishedWarnings:IDS:26|processTheFinishedWarnings:UIDS:62

>Wed Aug 03 18:50:01 UTC 2016|Starting cache purge

>Wed Aug 03 18:50:01 UTC 2016|cache successfully purged via `wget`

Где `26` - это ID РО из таблицы `phpbb_rosystem` и `62` - это ID пользователя, что РО истекло.
Множественные записи разделены зяпятой `,` то есть `26,27` и `62,63`.


## Структура проекта

* `/conf/` - примеры конфигурационного файла

* `/compiled/` - скомпилированные `JROPHPBB.java`:
`javac -cp .:mysql-connector-java-5.1.39-bin.jar JROPHPBB.java`
* `/compiled/java_7` - для `Java 7` (`1.7.0_65-b17`)
* `/compiled/java_8` - для `Java 8` (`1.8.0_102-b14`)

* `/pages/` - здесь `jrophpbbtable.jsp` - JSP страница, которая выводит список заРОшенных пользователей.
Рабочий пример расположен [**здесь**](http://ru-eve.com/tools/showreadonly.html) и `purgecache.php` - скрипт на php,
который запускает очистку кеша борды в при выполнении.

* `/sql/` - тут лежат SQL скрипты для базы. Они протектированы и работают на MySQL.

* `/sql/00-languages/` - тут лежат переводы для JSP страницы. `00-phpbbb_jrolang.sql` - нужен для создания таблицы для
переводов. Сами переводы в файлах `01-phpbb_jrolang-XX.sql`, где `XX` - 2-х буквенный код языка, например
`01-phpbb_jrolang-en.sql` - английский, `01-phpbb_jrolang-fr.sql` - французский или `01-phpbb_jrolang-ru.sql` русский.
Одновременно может быть активен только один перевод.

* **НЕОБЯЗАТЕЛЬНЫЕ** скрипты, это `90-phpbb_posts_log.sql` и `91-phpbb_posts__before_delete.sql`. Их цель, это дубликация
постов в таблицу `phpbb_posts_log`, которые удаляются навсегда модераторами на форуме.

* `/src/` - здесь лежит исходник `JROPHPBB.java`. Совместим с Java 7.

## Подготовка
### Java (JDK или JRE)
Если вы хотите сами все скомпилировать, вам нужна [**JDK**](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html),
Если вы хотите использовать уже скомпилированный вариант, то вам нужна JRE ([**simple**](http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html)
или [**серверная версия**](http://www.oracle.com/technetwork/java/javase/downloads/server-jre8-downloads-2133154.html)).
### Библиотеки
Для работы нужен [**Connector/J**](https://dev.mysql.com/downloads/connector/j/). I've used version `mysql-connector-java-5.1.39-bin.jar`.
Гид по настройке [тут](https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-installing.html).
Если же вы используете Джаву `из коробки` (то бишь скачали и поставили), то можете просто скопировать библиотеку в  `/lib/`
вашей `jre` И `jdk` (если у вас стоит JDK).

### Компиляция
Открыть папку `src`, и положить туда файл `mysql-connector-java-5.1.39-bin.jar` затем запустить:

    javac -cp mysql-connector-java-5.1.39-bin.jar JROPHPBB.java

Если у вас JDK8 на рабочем компе и JDK7 на сервере, вы можете скомпилировать под JDK7 следующей командой:

    javac -source 7 -target 7 -bootclasspath /путь/до/jdk7/jre/lib/rt.jar -cp .:mysql-connector-java-5.1.39-bin.jar JROPHPBB.java

или.. просто использовать javac от JDK7 :D

### SQL запросы
* Выполнить `00-phpbbb_jrolang.sql` из `/sql/00-languages/00-phpbb_jrolang.sql`, и, затем, из той же папки
`/sql/00-languages/` выполнить скрипт, которые соотвествует выбранному вами языку.
* Выполнить `/sql/01-phpbb_rosystem.sql`
* Выполнить `/sql/02-phpbb_log_warnings.sql`
* Выполнить `/sql/03-phpbb_log__after_insert.sql`
* Выполнить `/sql/04-phpbb_log_warnings__clean.sql`
* Выполнить `/sql/05-phpbb_rosystem__autoremove_readonly.sql`
* **Прочитать**, **ОТРЕДАКТИРОВАТЬ** и выполнить `/sql/06-phpbb_rosystem__after_insert.sql`

Так же тут  **НЕОБЯЗАТЕЛЬНЫЕ** скрипты `/sql/90-phpbb_posts_log.sql` и `/sql/91-phpbb_posts__before_delete.sql` которые
добавляют автоматический бекап удаленных из базы постов.

###Web страницы
* скопировать файл `/pages/purgecache.php` в корень форума и **переименовать** его.
* **Прочитать**, **ОТРЕДАКТИРОВАТЬ** и скопировать файл `/pages/jrophpbbtable.jsp` в корень страниц вашего JSP-контейнера. В то же время этот шаг можно
пропустить (если вам не нужна такая табличка) или вы можете переписать сею страницу на `PHP` используя JSP страницу
как образец (живой пример [тут](http://ru-eve.com/tools/showreadonly.html))

###PHPBB форум
* Вам надо создать `read-only` группу если она еще не создана (группа, которая не дает писать на форуме)
* Так же вам надо создать звание для заРОшенных пользователей, например "Я сижу в РО" или типо этого

**НЕОБЯЗАТЕЛЬНЫЕ** фишки:
* если вы используете nginx, вы можете создать звание с текстом `readonlyuserrank`
* далее вам надо собрать `nginx` с модулем [`ngx_http_substitutions_filter_module`](https://github.com/yaoweibin/ngx_http_substitutions_filter_module/)
* создать файл `subs_phpbbrank` в папке `/conf/`
* добавить следующие строки в файл `subs_phpbbrank`:

    subs_filter_types text/html;

    `subs_filter 'readonlyuserrank'  '<a href="http://ваш/форум/jrophpbbtable.jsp" target="_blank" style="color: #FF40FF">Я сижу в РО</a>' gi;`


* добавить в конфиг nginx следующую строчку: `include subs_phpbbrank;`
* перезагрузить nginx `nginx -s reload`

Теперь каждый раз, когда `JROPHPBB` помещает пользователя в РО, то он (пользователь) получает кликабельное розовое знвание
ссылка на которм ведет на страницу `jrophpbbtable.jsp` вашего сервера.

### Выполнение
Для просмотра справки достаточно выполнить:

    java JROPHPBB

Проверить файл `mysql-connector-java-5.1.39-bin.jar` (или другая версия, если вы ее используете) в папке с
компилированным `JROPHPBB.class`

Для запуска с конфигурационным файлом ипользовать:

    java -cp .:mysql-connector-java-5.1.39-bin.jar JROPHPBB -c /путь/до/jrophpbb.conf

Для запуска с параметрами использовать:

    java -cp .:mysql-connector-java-5.1.39-bin.jar JROPHPBB '{database:login~passwd@server:port/phpbb}{purgecache:http://example.com/purgecache.php\wget}{modgroups:2,3}{timeout:30}{rogroup:8}{defrank:0}{debug:true}'

**Linux**: для вывода программы в файл достаточно добавить `2>&1 >> jrophpbb.log`, например

    java -cp .:mysql-connector-java-5.1.39-bin.jar JROPHPBB -c /путь/до/jrophpbb.conf 2>&1 >> jrophpbb.log

или

    java -cp .:mysql-connector-java-5.1.39-bin.jar JROPHPBB '{database:login~passwd@server:port/phpbb}{purgecache:http://example.com/purgecache.php\wget}{modgroups:2,3}{timeout:30}{rogroup:8}{defrank:0}{debug:true}' 2>&1 >> jrophpbb.log

в случае запуска с параметрами

Для работы я использую `screen` под debian. Всего лишь выполнить `screen` и затем запустить программу из списка.
Следом прожать `ctrl`+(`A`+`D`) и процесс работает в фоне.

##Ошибки
###URLConnection/certificate error
>javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed:
>unable to find valid certification path to requested target

####Что случилось?
Java не нашла корневого сертификата в хранилще (keystore).
####Как исправить?
* Открыть сайт
* Скачать корневой сертификат
* Импортировать его в хралинище (keystore)

Импорт осуществляется следующей командой:

    keytool -importcert -file '/путь/до/cert.crt' -keystore '/путь/до/jre/lib/security/cacerts' -alias 'алиасДляСертификата'

Пароль по умолчанию `changeit`

**ИЛИ** просто использовать `wget`/`curl`/`fetch` как способ для очистки кеша.

##Зачем `ЭТО` создано?
Я искал плагин для phpbb для управления РО, которые был бы имел схожий принцип с форумами от IPB. Но такого плагина я не нашел,
поэтому и написал свою `систему`.

####Почему на Java?
Потому, что я знаю Java и недостаточно помню PHP, чтобы написать плагин.

####Почму JSP, а не JSF?
Это очень маленькая страница. Я не люблю стиль (теги) JSF, но даже если и использовать JSF для создания такой простой
страницы и добавлять еще и пачку XML файлой.. К черту!

##Помощь проекту:
* нам нужны переводы, вы можете взять пример из файла `/sql/00-languages/01-phpbb_jrolang-XX.sql.example` чтобы создать
ваш собственный перевод (на другой язык или *LEET* стиль) и отправить мне на почту или как `pull` запрос. Пример внутри
файла `01-phpbb_jrolang-XX.sql.example`, все что вам нужно, это сохранить GPLv3 лицензию внутри, указать ваше имя или ник,
email (по желанию) и сам перевод, и конечно же, способ, как вам можно отправить пожертвование (это скиньте мне на почту).

* так же будем рады иметь PHP вариант нашей JSP страницы. Не проблема поставить JDK/JRE на сервер и затем
скомпилировать/запустить программу, но вот настройка JSP и Tomcat/Glassfish может быть трудна для большинства пользователей.
Не забудьте добавить ваше лицензию в программу. Оптимальный выбор -  [**GPLv3**](https://www.gnu.org/licenses/gpl-3.0.html).

Если вам понравился данный проект, то вы всегда можете поддержать копейкой лиц, которые внесли свой вклад в развитие проекта:
* **меня** через [PayPal](https://www.paypal.me/nikitasius) или WM (`R251592375912`|`Z740010249352`) за идею и реализацию`jRO-phpbb`
* *место вакантно*
* *место вакантно*
* ...
* *место вакантно*

Удачи вам, nikitasius.