/**
 * 90-phpbb_posts_log.sql - *OPTIONAL* create table script, where we keep deleted (removed data) posts from forum
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

CREATE TABLE `phpbb_posts_log` (
	`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	`post_id` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`datefrom` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`topic_id` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0',
	`forum_id` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0',
	`poster_id` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0',
	`icon_id` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0',
	`poster_ip` VARCHAR(40) NOT NULL DEFAULT '' COLLATE 'utf8_bin',
	`post_time` INT(11) UNSIGNED NOT NULL DEFAULT '0',
	`post_reported` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
	`enable_bbcode` TINYINT(1) UNSIGNED NOT NULL DEFAULT '1',
	`enable_smilies` TINYINT(1) UNSIGNED NOT NULL DEFAULT '1',
	`enable_magic_url` TINYINT(1) UNSIGNED NOT NULL DEFAULT '1',
	`enable_sig` TINYINT(1) UNSIGNED NOT NULL DEFAULT '1',
	`post_username` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8_bin',
	`post_subject` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
	`post_text` MEDIUMTEXT NOT NULL COLLATE 'utf8_bin',
	`post_checksum` VARCHAR(32) NOT NULL DEFAULT '' COLLATE 'utf8_bin',
	`post_attachment` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
	`bbcode_bitfield` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8_bin',
	`bbcode_uid` VARCHAR(8) NOT NULL DEFAULT '' COLLATE 'utf8_bin',
	`post_postcount` TINYINT(1) UNSIGNED NOT NULL DEFAULT '1',
	`post_edit_time` INT(11) UNSIGNED NOT NULL DEFAULT '0',
	`post_edit_reason` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8_bin',
	`post_edit_user` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0',
	`post_edit_count` SMALLINT(4) UNSIGNED NOT NULL DEFAULT '0',
	`post_edit_locked` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
	`post_visibility` TINYINT(3) NOT NULL DEFAULT '0',
	`post_delete_time` INT(11) UNSIGNED NOT NULL DEFAULT '0',
	`post_delete_reason` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8_bin',
	`post_delete_user` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0',
	`post_created` INT(11) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`),
	INDEX `forum_id` (`forum_id`),
	INDEX `topic_id` (`topic_id`),
	INDEX `poster_ip` (`poster_ip`),
	INDEX `poster_id` (`poster_id`),
	INDEX `tid_post_time` (`topic_id`, `post_time`),
	INDEX `post_username` (`post_username`),
	INDEX `post_visibility` (`post_visibility`),
	INDEX `post_id` (`post_id`)
)
COLLATE='utf8_bin'
ENGINE=InnoDB
AUTO_INCREMENT=1
;