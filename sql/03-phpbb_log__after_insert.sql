/**
 * 03-phpbb_log__after_insert.sql - trigger what dublicate records from phpbb_log table
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
 */

/*
    replace `YOURMYSQLUSER` with your current mysql user.
 */

CREATE DEFINER=`YOURMYSQLUSER`@`localhost` TRIGGER `phpbb_log__after_insert` AFTER INSERT ON `phpbb_log` FOR EACH ROW BEGIN
insert into phpbb_log_warnings (log_id, log_type, user_id, forum_id, topic_id, reportee_id, log_ip, log_time, log_operation, log_data) values (NEW.log_id, NEW.log_type, NEW.user_id, NEW.forum_id, NEW.topic_id, NEW.reportee_id, NEW.log_ip, NEW.log_time, NEW.log_operation, NEW.log_data);
END