#!/bin/bash -
ROOT=$(cd `dirname $0` && pwd) && echo "Running ${0##*/}"
cd $ROOT

alias ERR_CHK='[[ $? -ne 0 ]] && echo "[${0##/*}:$LINENO] ** ERROR ** - Exiting..." && exit 1'

## initialize good to have aliases - and announce
good_aliases () {
echo $0
}

# find releases (ie. master-XXX)
get_releases () {
echo $0
}

vital_configs () {
	echo configuring in `pwd`
	git config alias.externurl '!git config --get-regexp extern.*.path | cut -d. -f2'
	git config alias.rootpath 'config core.root'

	git config core.root $ROOT
	git config extern.$EXTERN.url $REPO
	git config extern.$EXTERN.path $EXTERN_PATH
}

## locate .extern file with lines such as: <nam> <repo-url> [<path>] matching pattern:
## <name> <repo url> [<path>]
get_externs () {
EXTERN_FILE=.extern
if [ ! -f $EXTERN_FILE ];then exit 0; fi
while read inputline
do
	#echo "$N: $inputline" && N=$((N+1))
	if [[ -z ${inputline} ]] ; then continue;fi
	#if [[ $inputline =~ ^. ]] ;then continue;fi
	EXTERN=`echo $inputline | cut -s -d' ' -f1`
	REPO=`echo $inputline | cut -s -d' ' -f2`
	EXTERN_PATH=`echo $inputline | cut -s -d' ' -f3`
	if [[ -z ${EXTERN} || -z ${REPO} ]] ; then continue;fi
	EXTERN_FOUND=1;
	echo -e "Extern found:\n==========\n- \tName:\t$EXTERN\n- \tRepo:\t$REPO\n- \tPath:\t$EXTERN_PATH\n"
	if [[ -z ${EXTERN_PATH} ]]; then EXTERN_PATH=$EXTERN;fi
	
	#append ROOT to EXTERN_PATH
	EXTERN_PATH=$ROOT/$EXTERN_PATH
	
	## create a clone from the extern(s)
	if [ -d $EXTERN_PATH/.git ]; then
		echo -e "Note: A git repo found in $EXTERN_PATH. Aborting clone operation."
	else
		cmd="git clone $REPO $EXTERN_PATH"
		echo $cmd && $cmd
	fi
	
	# vital configs
	vital_configs
	cd $EXTERN_PATH
	vital_configs
	
	break;## TODO remove to support multiple externs.

done < $EXTERN_FILE

if [[ -z $EXTERN_FOUND ]] ; then echo "$0 *** No externs found ***"; exit 1; fi

}

## Aliases to manage externs
extern_aliases () {
	
	echo Configurig aliases in `pwd`
	git config alias.mybranch '!f() { b=$(git symbolic-ref HEAD) && echo  ${b##refs/heads/};}; f '
	git config alias.extern '!git config --get-regexp extern.*.url | cut -d. -f2'
	git config alias.rootpath 'config core.root'
		
	# the aliases ...
	cmd=push
	git config alias.m$cmd '!cd `git rootpath` && git push origin `git mybranch` && cd `git extern` && git push origin `git mybranch`'
	cmd=pull
	git config alias.m$cmd '!cd `git rootpath` && git pull origin `git mybranch` && cd `git extern` && git pull origin `git mybranch`'

	cmd=commit
	git config alias.m$cmd '!cd `git rootpath` && git commit && cd `git extern` && git $cmd'
	cmd=branch
	git config alias.m$cmd '!cd `git rootpath` && git branch && cd `git extern` && git $cmd'
	cmd=rebase
	git config alias.m$cmd '!cd `git rootpath` && git rebase && cd `git extern` && git $cmd'
	cmd=merge
	git config alias.m$cmd '!cd `git rootpath` && git merge && cd `git extern` && git $cmd'
}

get_externs || $ERR_CHK
# good_aliases || $ERR_CHK
cd $ROOT
extern_aliases
cd $EXTERN_PATH
extern_aliases
cd $ROOT




