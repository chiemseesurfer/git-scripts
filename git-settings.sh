#!/bin/bash
#
# Max Oberberger (max@oberbergers.de, Januar 2012)
#
# This script configures all settings to use git on a client
# Last changes (14.02.2012)

### GET PARAMETERS
TEMP=`getopt -o hlcs: --long help,list,config,set-alias: -n 'git-config-settings.sh' -- "$@"`

if [ $? != 0 ];then
	echo "terminating... " >&2
	exit 1
fi

eval set -- "$TEMP"

function helpmenu(){
	echo "Usage:"
	echo
	echo " -h|--help"
	echo "      print this helpmenu"
	echo
	echo " -l|--list"
	echo "      list all settings"
	echo
	echo " -s|--set-alias <COMMAND ALIAS>"
	echo "      set command as alias"
	echo "      example: -s status st"
	echo
	echo " -c|--config"
	echo "      set configuration for git:"
	echo "        * alias"
	echo "        * color"
	echo "        * editor"
	echo "        * mergeOption"
	echo
	echo "         set following alias:"
	echo "         ALIAS |  COMMAND:"
	echo "         -----------------------------------------------------------------"
	echo "         st    |  status"
	echo "         ci    |  commit"
	echo "         br    |  branch"
	echo "         co    |  checkout"
	echo "         df    |  diff"
	echo "         he    |  help"
	echo "         cl    |  clone"
	echo "         nfm   |  merge --no-ff"
	echo "         ffm   |  merge --ff-only"
	echo "         dcw   |  diff --color-words"
	echo "         tree  |  log --decorate --pretty=oneline --abbrev-commit --graph"
}

#############################
### Function to set alias with informative output
#############################
function ConfigureAlias(){
	echo -ne "++ set alias ${1} = ${2} ..... "
	git config --global alias.${1} "${2}"
	echo -e "done"
} ### END OF ConfigureAlias

#############################
### mainfunction to set all needed aliases
#############################
function setAlias(){
	echo -e "++++ set alias:"
	ConfigureAlias "st" "status"
	ConfigureAlias "ci" "commit"
	ConfigureAlias "br" "branch"
	ConfigureAlias "co" "checkout"
	ConfigureAlias "df" "diff"
	ConfigureAlias "he" "help"
	ConfigureAlias "cl" "clone"
	ConfigureAlias "nfm" "merge --no-ff"
	ConfigureAlias "ffm" "merge --ff-only"
	ConfigureAlias "dcw" "diff --color-words"
	ConfigureAlias "tree" "log --decorate --pretty=oneline --abbrev-commit --graph"
} ### END OF setAlias

#############################
### ask / set mergeOption
#############################
function mergeOption(){
	echo -ne "++ set merge option = --no-ff ..... "
	git config --global core.mergeoptions "--no-ff"
	echo -e "done"
} ### END OF mergeOption

#############################
### ask which editor should be used
#############################
function setEditor(){
	echo
	echo -e "Which editor do you want to use to modify commit messages? e.g. vim,vi,gedit (default = vim)."
	echo -ne "editor: "
	read editor
	if [ -z $editor ];then
		editor=vim
	fi
	echo -ne "++ set editor = ${editor} ..... "
	git config --global core.editor ${editor}
	echo -e "done"
} ### END OF setEditor

#############################
### MAIN Function
#############################
function runConfiguration(){
	setAlias
	mergeOption
	setEditor
	echo -ne "++ set color ..... "
	git config --global color.ui auto
	echo -e "done"
	echo "set username and emailadress"
	echo -ne "your name (example Max Mustermann): "
	read name
	echo -ne "your mailadress (example: max@mustermann.de): "
	read email
	echo -ne "++ set username and emailadress ....."
	git config --global user.name ${name}
	git config --global user.email "<${email}>"
	echo -e "done"
} ### END OF runConfiguration

while true; do
	case "$1" in
		-h|--help) helpmenu;exit 1;;
		-l|--list) git config --list; shift 2;break;;
		-c|--config) runConfiguration;shift 2;break;;
		-s|--set-alias) ConfigureAlias ${4} ${2}; shift 2;break;;
		--) shift;;
		*) echo "Please use $0 -h|--help for helpmenu"; exit 1;;
	esac
done
#############################
## END OF git-config-settings.sh
#############################
