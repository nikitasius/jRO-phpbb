/**
 * 91-phpbb_posts__before_delete.sql - *OPTIONAL* trigger, made to copy the post's nody before deleting (removed data).
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

CREATE DEFINER=`YOURMYSQLUSER`@`localhost` TRIGGER `phpbb_posts__before_delete` BEFORE DELETE ON `phpbb_posts` FOR EACH ROW BEGIN
insert into phpbb_posts_log (post_id,topic_id,forum_id,poster_id,icon_id,poster_ip,post_time,post_reported,enable_bbcode,enable_smilies,enable_magic_url,enable_sig,post_username,post_subject,post_text,post_checksum,post_attachment,bbcode_bitfield,bbcode_uid,post_postcount,post_edit_time,post_edit_reason,post_edit_user,post_edit_count,post_edit_locked,post_visibility,post_delete_time,post_delete_reason,post_delete_user,post_created)
values(OLD.post_id,OLD.topic_id,OLD.forum_id,OLD.poster_id,OLD.icon_id,OLD.poster_ip,OLD.post_time,OLD.post_reported,OLD.enable_bbcode,OLD.enable_smilies,OLD.enable_magic_url,OLD.enable_sig,OLD.post_username,OLD.post_subject,OLD.post_text,OLD.post_checksum,OLD.post_attachment,OLD.bbcode_bitfield,OLD.bbcode_uid,OLD.post_postcount,OLD.post_edit_time,OLD.post_edit_reason,OLD.post_edit_user,OLD.post_edit_count,OLD.post_edit_locked,OLD.post_visibility,OLD.post_delete_time,OLD.post_delete_reason,OLD.post_delete_user,OLD.post_created);
END