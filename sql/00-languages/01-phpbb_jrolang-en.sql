/**
 * 01-phpbb_jrolang-en.sql - english translation
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
		(!) one translation is available (!)
		(!) new SQL execution removes previous (!)

    i use utf8 encoding. If your forum use another, don't forget to change it!
    jRO-phpbb work was tested and it works well with utf8.
*/

DELETE from `phpbb_jrolang`;
INSERT INTO `phpbb_jrolang` (`id`, `t`) VALUES
	(0, 'Active'),
	(1, 'Overwritten'),
	(2, 'Finished'),
	(3, 'Finished and removed'),
	(4, 'Unknown status'),
	(5, 'Read-only table from the forum'),
	(6, 'Hide cols'),
	(7, 'Subject'),
	(8, 'Object'),
	(9, 'From date'),
	(10, 'Till date'),
	(11, 'Reason'),
	(12, 'Status'),
	(13, 'RESET'),
	(14, 'All page\'s changes are saved into LocalStorage (hidden cols, filtres, etc.)'),
	(15, 'This warning was removed from `phpbb_log` table'),
	(16, 'Never expire');