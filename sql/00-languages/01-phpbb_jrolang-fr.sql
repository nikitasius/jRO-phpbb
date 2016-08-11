/**
 * 01-phpbb_jrolang-fr.sql - french translation
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
	(1, 'Changé'),
	(2, 'Fini'),
	(3, 'Fini et supprimé'),
	(4, 'Statut inconnu'),
	(5, 'Lire-seulement la table du forum'),
	(6, 'Cacher les colonnes'),
	(7, 'Executant'),
	(8, 'Victime'),
	(9, 'De'),
	(10, 'À'),
	(11, 'Avertissement'),
	(12, 'Statut'),
	(13, 'Réinitialisation'),
	(14, 'Tous les changements sauvegardés dans le LocalStorage (filtres, etc)'),
	(15, 'Cette avertissement étai supprimé de la table `phpbb_log`'),
	(16, 'Jamais'),
	(17, 'Le liste des bans du forum');