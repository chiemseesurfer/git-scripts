#!/bin/bash
#
# Max Oberberger (github@oberbergers.de, Januar 2012)
#
# This script configures all settings to use git on a client
# Last changes (25.02.2013)
set -u

if [ $? != 0 ];then
	echo "terminating... " >&2
	exit 1
fi

# ignorecase for uname - switch all lowercase to uppercase
OST=`uname | tr -s [:upper:] [:lower:]`

function helpmenu(){
	if [[ $OST == "darwin" ]];then
		echo "You are on a OSX-System. The long-options like --help are just on unix-systems available!!"
		echo
	fi
	echo "Usage: $0 [Option]"
	echo
	echo "Option:"
	echo "###########################"
	echo
	echo " -h|--help"
	echo "      print this helpmenu"
	echo
	echo " -l|--list"
	echo "      list all existing global git settings"
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
	echo "         tree  |  log --decorate --pretty=oneline --abbrev-commit --graph --all"
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
	ConfigureAlias "tree" "log --decorate --pretty=oneline --abbrev-commit --graph --all"
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
### set http sslverify to false
#############################
function httpSettings(){
	echo -ne "++ set http sslverify to false ..... "
	git config --global http.sslverify false
	echo -e "done"
	echo -ne "++ set http postbuffer to 52428800000 ..... "
	git config --global http.postbuffer 52428800000
	echo -e "done"
} ### END OF httpVerify

#############################
### set pack settings to handle memory usage
#############################
function packSettings(){
    echo -ne "++ set pack windowMemory 200m ..... "
    git config --global pack.windowMemory "200m"
	echo -e "done"
    echo -ne "++ set pack Size Limit 200m ..... "
    git config --global pack.SizeLimit "200m"
	echo -e "done"
    echo -ne "++ set pack threads 2 ..... "
    git config --global pack.threads "2"
	echo -e "done"
} ### END OF packSettings

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
	httpSettings
    packSettings
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
	git config --global user.name "${name}"
	git config --global user.email "<${email}>"
	echo -e "done"
} ### END OF runConfiguration

#############################################################################################
###########################              MAIN               #################################
#############################################################################################
### GET PARAMETERS
## check if os is a linux or mac system
if [[ $OST == "linux-gnu" ]] || [[ $OST == "linux" ]];then
	TEMP=`getopt -o hlcs: --long help,list,config,set-alias: -n 'git-settings.sh' -- "$@"`
	eval set -- "$TEMP"

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
elif [[ $OST == "darwin" ]];then
	args=`getopt hlcs $*`
	set -- $args

	for i;do
		case "$i"
		in
			-h) helpmenu;exit 1;;
			-l) git config --list; shift;;
			-c) runConfiguration; shift;;
			-s) ConfigureAlias ${4} ${3}; shift;;
			--) shift;break;;
			*) echo "Please use $0 -h for helpmenu"; exit 1;;
		esac
	done
fi
#############################
## END OF git-config-settings.sh
#############################
