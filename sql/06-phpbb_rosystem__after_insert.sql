/**
 * 06-phpbb_rosystem__after_insert.sql - trigger what activates read-only status for user
    Copyright (C) 2016  Nikita S. <nikita@saraeff.net>

    This file is part of jRO-phpbb.

    This program is free software: you can redistribute it a    nd/or modify
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
    READ commented text. 8 - an example, read-only group ID. 4 - an example, read-only rank ID.
 */

CREATE DEFINER=`YOURMYSQLUSER`@`localhost` TRIGGER `phpbb_rosystem__after_insert` AFTER INSERT ON `phpbb_rosystem` FOR EACH ROW BEGIN
delete from phpbb_user_group where group_id=8 and user_id=NEW.userto; /* 8 - current readonly group ID, replace it. */
insert into phpbb_user_group (group_id, user_id, group_leader, user_pending) values (8, NEW.userto, 0, 0); /* 8 - readonly group ID, replace it. */
update phpbb_users set user_rank=4 where user_id=NEW.userto;  /* 4 - readonly rank ID, replace it. */
END