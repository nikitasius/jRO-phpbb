/**
 * 01-phpbb_rosystem.sql - create table script for ro-system
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
    i use utf8 encoding. If your forum use another, don't forget to change it!
    jRO-phpbb work was tested and it works well with utf8.
*/

CREATE TABLE `phpbb_rosystem` (
	`id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT,
	`logid` MEDIUMINT(8) UNSIGNED NOT NULL,
	`date_from` INT(10) UNSIGNED NOT NULL,
	`date_to` INT(10) UNSIGNED NOT NULL,
	`userby` MEDIUMINT(8) UNSIGNED NOT NULL,
	`userto` MEDIUMINT(8) UNSIGNED NOT NULL,
	`isactive` TINYINT(3) UNSIGNED NOT NULL,
	PRIMARY KEY (`id`)
)
COLLATE='utf8_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1
;
