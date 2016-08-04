/**
 * 02-phpbb_log_warnings.sql - create table script for table where we will store warnings
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

CREATE TABLE `phpbb_log_warnings` (
	`id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT,
	`log_id` MEDIUMINT(8) UNSIGNED NOT NULL,
	`log_type` TINYINT(4) NOT NULL DEFAULT '0',
	`user_id` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0',
	`forum_id` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0',
	`topic_id` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0',
	`reportee_id` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0',
	`log_ip` VARCHAR(40) NOT NULL DEFAULT '' COLLATE 'utf8_bin',
	`log_time` INT(11) UNSIGNED NOT NULL DEFAULT '0',
	`log_operation` TEXT NOT NULL COLLATE 'utf8_bin',
	`log_data` MEDIUMTEXT NOT NULL COLLATE 'utf8_bin',
	PRIMARY KEY (`id`),
	INDEX `log_id` (`log_id`),
	INDEX `user_id_reportee_id` (`user_id`, `reportee_id`)
)
COLLATE='utf8_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1
;
