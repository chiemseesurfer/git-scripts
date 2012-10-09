#!/bin/bash
#
# Max Oberberger (max@oberbergers.de, Januar 2012)
#
# This script converts a svn-Repository into a git-repository
# Last changes (23.09.2012)
#
# Required packages:
#	* git 
#	* git-core
#	* git-svn
#	* svn

if [ $? != 0 ];then
	echo "terminating... " >&2
	exit 1
fi

OS=`uname`


function helpmenu(){
	if [[ $OS == "Darwin" ]] || [[ $OS == "darwin" ]];then
		echo "You are on a OSX-System. The long-options like --help are just on unix-systems available!!"
		echo
	fi
	echo
	echo "This script converts the whole svn-repository into git-repositories"
	echo
	echo "Usage: $0 [Option]"
	echo
	echo "Option:"
	echo "###########################"
	echo
	echo "        -h|--help           print this helpmenu"
	echo
	echo "        -p|--path           specify the path where the new repositories are created"
	echo "                            if path is not set, /tmp will be used as default"
	echo
	echo "        -s|--svn            specify the path where the svn repository is located"
	echo "                            the path has to look like this: http://192.168.22.19/svn"
	echo "                            if path is not set, http://localhost/svn will be used as default"
	echo
	echo "        -r|--repo           specify the name of the new Git-repository which will be created"
	echo "                            if path is not set, git-svn-mirror will be used as default"
	echo
}

#############################################################################################
###########################              MAIN               #################################
#############################################################################################
### GET PARAMETERS
## check if os is a linux or mac system
if [[ $OS == "linux-gnu" ]] || [[ $OS == "linux" ]] || [[ $OS == "Linux" ]] ||[[ $OS == "Linux-gnu" ]];then
	TEMP=`getopt -o hr:p:s: --long repo:,help,path:,svn: -n 'convert-svn-to-git.sh' -- "$@"`
	eval set -- "$TEMP"

	while true; do
		case "$1" in
			-h|--help) helpmenu;exit 1;;
			-p|--path) HELP_PATH=${2};shift 2;; ## Repsitory Path for localhost
			-s|--svn) SVN_PATH=${2};shift 2;; ## Subversion Path of extern Repository
			-r|--repo) REPO_NAME=${2};shift 2;; ## Repsitory Path of new git-Repository 
			--) shift;break;;
			*) helpmenu; exit 1;;
		esac
	done 

elif [[ $OS == "Darwin" ]] || [[ $OS == "darwin" ]];then

	args=`getopt hps $*`
	set -- $args

	for i;do
		case "$i"
		in
			-h) helpmenu;exit 1;;
			-p) HELP_PATH=${3}; shift;;
			-r) REPO_NAME=${3}; shift;;
			-s) SVN_PATH=${3}; shift;;
			--) shift;break;;
			*) echo "Please use $0 -h for helpmenu"; exit 1;;
		esac
	done
fi

#############################################################################################

[ -z ${HELP_PATH} ] && HELP_PATH="/tmp"
[ -z ${SVN_PATH} ] && SVN_PATH="http://127.0.0.1/svn"
[ -z ${REPO_NAME} ] && REPO_NAME="git-svn-mirror"

### URL of local svn mirror
HELP_URL="file://${HELP_PATH}/svn-mirror"
### the author file is needed by git-svn to convert svn-user into git-user
AUTHOR_FILE="${HELP_PATH}/authors-transform.txt"

if ! [ -d ${HELP_PATH} ];then
	mkdir -p ${HELP_PATH}
fi


####################
### create a complete local svn-repository or resync an existing one
####################
function updateLocalSVNRepo(){

	### if the svn-mirror exists, we dont need to create a new one
	if ! [ -d ${HELP_PATH}/svn-mirror ];then

		## create a new local svn mirror
		svnadmin create ${HELP_PATH}/svn-mirror

		## insert needed pre-revprop-change hook
		echo "#!/bin/sh" > ${HELP_PATH}/svn-mirror/hooks/pre-revprop-change
		chmod a+x ${HELP_PATH}/svn-mirror/hooks/pre-revprop-change

		## sync the new local svn-repository with the extern one
		/usr/bin/svnsync init ${URL} ${SVN_URL}
	fi

	## fetch/update all data on local svn-repo
	/usr/bin/svnsync synchronize ${URL}
} ## END OF updateLocalSVNRepo

####################
### convert svn user-format into git user-format
### the authors are static and I don't know if the file exists or not
####################
function generateAuthorsFile(){
	cd ${HELP_PATH}/svn-mirror

	svn log -q | awk -F '|' '/^r/ {sub("^ ", "", $2); sub(" $", "", $2); print $2" = "$2" <"$2">"}' | sort -u > ${AUTHOR_FILE}
} ### END OF generateAuthorsFile

####################
### convert svn branches into git branches
####################
function gitConvertRefs(){

	. $(git --exec-path)/git-sh-setup
	svn_prefix='svn/'

	convert_ref(){
		echo -n "converting: $1 to: $2 ..." 
		git update-ref $2 $1
		git update-ref -d $1
		echo "done"
	}

	get_refs(){
		git for-each-ref $1 --format='%(refname)'
	}

	echo 'Converting svn tags' 
	get_refs refs/remotes/${svn_prefix}tags | while read svn_tag
	do
		new_ref=$(echo $svn_tag | sed -e "s|remotes/$svn_prefix||")
		gitConvertRefs $svn_tag $new_ref
	done

	echo "Converting svn branches" 
	get_refs refs/remotes/${svn_prefix} | while read svn_branch
	do
		new_ref=$(echo $svn_branch | sed -e "s|remotes/$svn_prefix|heads/|")
		gitConvertRefs $svn_branch $new_ref
	done
} ### END OF gitConvertRefs

####################
### convert svn tags into git tags
####################
function gitFixTags(){

	. $(git --exec-path)/git-sh-setup
	get_tree(){ git rev-parse $1^{tree}; }

	git for-each-ref refs/tags --format='%(refname)' | while read tag
	do
		sha1=$(git rev-parse $tag)
		tree=$(get_tree $tag )
		new=$sha1
		while true
		do
			parent=$(git rev-parse $new^)
			git rev-parse $new^2 > /dev/null 2>&1 && break
			parent_tree=$(get_tree $parent)
			[ "$parent_tree" != "$tree" ] && break
			new=$parent
		done
		[ "$sha1" = "$new" ] && break
		echo -n "Found new commit for tag ${tag#refs/tags/}: " $(git rev-parse --short $new)", resetting..." 
		git update-ref $tag $new
		echo 'done'
	done
} ### END of gitFixTags

####################
### convert the whole local svn repository into git
### convert svn branches/tags into git branches/tags
####################
function convertSVNToGit(){

	### if authors file does not exist, we have to create it
	if ! [ -e ${AUTHOR_FILE} ];then
		generateAuthorsFile
	fi

	## sometimes nothing in svn is changed and we don't need a complete full git-repository 
	if ! [ -d ${HELP_PATH}/${REPO_NAME} ];then
		## create the repo-name
		mkdir -p ${HELP_PATH}/${REPO_NAME}
		## clone the snv-mirror as a git-repo
		/usr/lib/git-core/git-svn clone ${URL} -A ${AUTHOR_FILE} ${HELP_PATH}/${REPO_NAME} --prefix=svn/ --follow-parent --no-metadata --stdlayout
		## stdlayout means with tag, branch and trunk structure
		## prefix is used by gitConvertRefs and gitFixTags
		## follow-parent is important to recognize the full history
		## -A locates the authors-file

		### go into the repository and convert all svn tags and branches into git tags and branches
		cd ${HELP_PATH}/${REPO_NAME}
		## convert svn tags/branches into git compatible one
		gitConvertRefs
		## fix the rest of the tags
		gitFixTags 
	else
		### if the repository already exist, we just need the last changes....
		cd ${HELP_PATH}/${REPO_NAME}
		/usr/lib/git-core/git-svn fetch

		### be sure, that we haven't forgotten a branch or tag (maybe one was created the last days)
		gitConvertRefs
		gitFixTags
	fi
} ### END OF convertSvnToGit

####################
### check if we have enough disk-space remaining 
####################
function check_device_size(){
	cd ${HELP_PATH}

	if [[ $OS == "Darwin" ]] || [[ $OS == "darwin" ]];then
		DEVICE_SIZE=`/bin/df -h .|/usr/bin/tail -n 1|/usr/bin/awk {'print $(NF-5)'}|cut -dG -f1`
	else
		DEVICE_SIZE=`/bin/df -h .|/usr/bin/tail -n 1|/usr/bin/awk {'print $(NF-2)'}|cut -dG -f1`
	fi

	limit=10
	if [[ $DEVICE_SIZE < $limit ]];then
		echo "not enough space left! < ${limit}GB"
		echo "exit program"
		exit 1
	fi
} ### END OF check_device_size

check_device_size

updateLocalSVNRepo

convertSVNToGit

#############################
## END OF convert-svn-to-git.sh
#############################
