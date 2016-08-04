/**
 * 04-phpbb_log_warnings__clean.sql - event made to keep only LOG_USER_WARNING_BODY records in our table
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

CREATE DEFINER=`YOURMYSQLUSER`@`localhost` EVENT `phpbb_log__warnings__clean`
	ON SCHEDULE
		EVERY 1 HOUR STARTS '1970-01-01 00:00:00'
	ON COMPLETION PRESERVE
	ENABLE
	COMMENT ''
	DO BEGIN
delete from phpbb_log_warnings where log_operation!='LOG_USER_WARNING_BODY';
END