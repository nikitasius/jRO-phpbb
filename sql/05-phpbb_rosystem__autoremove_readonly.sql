/**
 * 05-phpbb_rosystem__autoremove_readonly.sql - removes read-only status for user when time is finished
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

CREATE DEFINER=`YOURMYSQLUSER`@`localhost` EVENT `phpbb_rosystem__autoremove_readonly`
	ON SCHEDULE
		EVERY 30 SECOND STARTS '1970-01-01 00:00:00'
	ON COMPLETION PRESERVE
	ENABLE
	COMMENT ''
	DO BEGIN
update phpbb_rosystem set isactive=3 where date_to<=UNIX_TIMESTAMP() and isactive not in (2, 3, 4);
END