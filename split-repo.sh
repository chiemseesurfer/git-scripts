#!/bin/bash
#
# Copyright (c) 2012-2013 Max Oberberger (max@oberbergers.de)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License 
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
######
#
# Version 1.3

function helpmenu {
	echo "Programm: split-repo"
	echo "This program excludes a folder in an existing"
	echo "git-repository to a new git-repository"
	echo
	echo "Usage: split-repo ORIGIN-REPO NEW-REPO"
	echo
	echo "Functionality:"
	echo "START      |    END"
	echo "----------------------------"
	echo "XYZ/       |    XYZ/"
	echo "   .git/   |        .git"
	echo "   ABC/    |        XYZ1/"
	echo "   XYZ1/   |        XYZ2/"
	echo "   XYZ2/   |    ABC/"
	echo "           |       .git/"
	echo
	echo "INFO: The NEW-REPO must be a part of the ORIGIN-REPO"
}



if [ "$#" -le "1" ] || [ "$#" -gt "2" ];then
	helpmenu
fi

ORIGIN_REPO=$1
NEW_REPO=$2

echo -n "++ start git clone"
git clone --no-hardlinks ${ORIGIN_REPO} ${NEW_REPO} 1> /dev/null
echo " ..... done"

echo -n "++ change in new repo "
cd ${NEW_REPO}
echo " ..... done"

echo -n "++ git filter-branch --subdirectory-filter"
git filter-branch --subdirectory-filter ${NEW_REPO} HEAD -- --all 1> /dev/null ### alle anderen Sachen ausser das new-repo markieren, damit es vom Garbage-Collector entfernt wird
echo " ..... done"

### backup reflogs entfernen
echo -n "++ git reset --hard"
git reset --hard 1> /dev/null
echo " ..... done"

echo -n "++ git reflog expire"
git reflog expire --expire=now --all 1> /dev/null
echo " ..... done"

echo -n "++ git gc --aggressive"
git gc --aggressive --prune=now 1> /dev/null
echo " ..... done"
