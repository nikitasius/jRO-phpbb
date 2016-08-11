/**
 * 01-phpbb_jrolang-ru.sql - russian translation
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
	(0, 'Активно'),
	(1, 'Перезаписано'),
	(2, 'Завершено'),
	(3, 'Завершено и снято'),
	(4, 'неизвестный статус'),
	(5, 'Таблица РО форума'),
	(6, 'Скрытие столбцов'),
	(7, 'Кто выдал'),
	(8, 'Кому выдали'),
	(9, 'Дата начала'),
	(10, 'Дата окончания'),
	(11, 'Причина'),
	(12, 'Статус'),
	(13, 'СБРОС'),
	(14, 'Изменения стуктуры страницы сохраняются в LocalStorage (скрытые столбцы, значения фильтра и т.д.)'),
	(15, 'Запись о данном предупреждении была удалена из таблицы `phpbb_log`'),
	(16, 'Бесконечно'),
	(17, 'Таблица банов форума');