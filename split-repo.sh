#!/bin/bash
#
# Max Oberberger (max@oberbergers.de) - Dezember 2011
#
# Version 1.0.3 (16.07.2012)

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
