<pre><code>
             ,
         -  /|
        -  / |
      -   /o |
   ~^~ ^~//-'|~^~ ~^~
    ~^~.-->>---. ~^ ~^~
   ~^~ `"""""""` ^~^ ~^
    ~^~ ~^ ~^~^ ~^~^ ~^
    Max Oberberger
    github@oberbergers.de
    https://github.com/chiemseesurfer/git-scripts
</code></pre>


Copyright &copy; 2012-2016 Max Oberberger

This files are free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

* * *


Table of Contents
=================
1. [Introduction]()
2. [System Requirements]()
3. [Installation]()
4. [Using containing scripts]()
5. [References]()
6. [FAQ]()


1.Introduction
===============
If you are using git [1] for source control, then this scripts might be useful
to you.


2. System Requirements
===============
	- Git Version 1.6.x.y or newer (I've tested with 1.7.2.5)
	  debian packages for all scripts:
		* git
		* git-core

	- SVN Version 1.6.X or newer (I've tested with 1.6.12) - required for
	  convert-svn-to-git.sh

	- debian-package git-svn (required for convert-svn-to-git.sh): A 
	  Bidirectional operation between a Subversion repository and git. 
	  It is a simple conduit for changesets between Subversion and 
	  git. It provides a bidirectional flow of changes between a 
	  Subversion and a git repository.


3. Installation
===============
3.1 copy in local folder (root required)
---------------
	You can copy the scripts to /usr/local/bin. If done, the script is
	located in your $PATH and you can execute it by just calling the script.
	For this you need root permissions on your computer. If you don't have
	root permissions, you can use 3.2.
	Example:
	$ sudo cp settings/git-settings.sh /usr/local/bin/
	$ git-settings.sh -h

3.2 change $PATH (no root required)
---------------
	If you don't have root permissions on your client, you can modify your
	$PATH variable.
	clone this repository whereever you want and export your $PATH in your
	bashrc with the path to your cloned directory:
	Example:
	$ cd /tmp/
	$ git clone https://github.com/chiemseesurfer/git-scripts.git
	$ cd git-scripts
	$ pwd
	/tmp/git-scripts
	$ echo "export PATH=$PATH:/tmp/git-scripts" >> ~/.bashrc
	$ export .bashrc


4. Using containing scripts
===============
	Every script has its own helpmenu (use -h or --help). Sometimes if you
	don't know how to use a script, you can have a look at one of these 
	helpmenus.

	I also give you a short explanation how to use my scripts in this
	README-file.

4.1 Using git-settings.sh
---------------
	This script supports you to set all helpful git config settings.
	Called with -c, this script configures some git alias, your editor for
	git commit, colored output, http(s) settings like verify and postbuffer.

	Example:
	$ ./git-settings.sh -c
	++++ set alias:
	++ set alias st = status ..... done
	++ set alias ci = commit ..... done
	++ set alias br = branch ..... done
	++ set alias co = checkout ..... done
	++ set alias df = diff ..... done
	++ set alias he = help ..... done
	++ set alias cl = clone ..... done
	++ set alias nfm = merge --no-ff ..... done
	++ set alias ffm = merge --ff-only ..... done
	++ set alias dcw = diff --color-words ..... done
	++ set alias tree = log --decorate --pretty=oneline --abbrev-commit --all
	--graph ..... done
	++ set merge option = --no-ff ..... done
	++ set http sslverify to false ..... done
	++ set http postbuffer to 52428800000 ..... done

	Which editor do you want to use to modify commit messages? e.g.
	vim,vi,gedit (default = vim).
	editor: vim
	++ set editor = vim ..... done
	++ set color ..... done
	set username and emailadress
	your name (example Max Mustermann): Max Oberberger
	your mailadress (example: max@mustermann.de): max@oberbergers.de
	++ set username and emailadress .....done


4.2 Using split-repo.sh
---------------
	With my split-repo script you can extract a subfolder of a
	git-repository to a complete own git-repository.
	If your Start-Repo is under /tmp/, you need to move to /tmp/
	
	Example:
	Usage: split-repo XYZ ABC

	START      |    END
	----------------------------
	XYZ/       |    XYZ/
	   .git/   |        .git/
	   ABC/    |        XYZ1/
	   XYZ1/   |        XYZ2/
	   XYZ2/   |    ABC/
	           |       .git/


	normal output of this script:
	$ split-repo.sh XYZ ABC
	++ start git clone ..... done
	++ change in new repo  ..... done
	++ git filter-branch --subdirectory-filter ..... done
	++ git reset --hard ..... done
	++ git reflog expire ..... done
	++ git gc --aggressiveCounting objects: 445, done.
	Delta compression using up to 2 threads.
	Compressing objects: 100% (440/440), done.
	Writing objects: 100% (445/445), done.
	Total 445 (delta 276), reused 0 (delta 0)
	 ..... done

4.3 Using convert-svn-to-git.sh
---------------
	This script makes it possible to you to convert a existing
	SVN-Repository to a new Git-Repository.
	You can set three options:
	-p	path to new Git-Repository (default: /tmp)
	-s	http-path to svn-Repository (default: http://127.0.0.1/svn)
	-r	Name of new Git-Repository (default: git-svn-mirror)
	
	Steps of this script:
	1. create local svn-mirror to minimize networktraffic
	2. generate authors-file. Git has a different User-Syntax. This must be
	   changed.
	   Example:
		Git-User: Max Mustermann <max.mustermann@example.com>
		SVN-User: mmustermann <mmustermann>
	3. convert SVN to git

5. References
===============
[1] Git, an source configuration management ("SCM") tool
    http://git-scm.com/

6. FAQ
===============
- **Can not push to remote because of out of memory**  
 If you get an error with out of memory, try to decrease postbuffer setting
 with:

    git config --global http.postbuffer 524288000
