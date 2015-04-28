#!/bin/zsh



nl=$'\n' # neat helper



# check if git is installed
# http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
if [[ ! hash git 2>/dev/null ]]; then
	echo >&2 "Git seems to be missing, please install it first. See https://gist.github.com/derhuerst/1b15ff4652a867391f03."
	exit 1
fi

# ask for the installation path
installDir=''
while true; do
	read -e -p 'Where do you want to put the theme folder? > ' -i '~/.config' > installDir
	[[ -d $installDir ]] && break
	echo 'Sorry, This directory does not exist.'$nl
done
installDir=${installDir%/}"/vibrant-zsh-theme"

# clone from GitHub
git clone -q https://github.com/derhuerst/vibrant-zsh-theme.git $installDir
echo "Successfully cloned from GitHub."$nl
installFile=$installDir'/vibrant.zsh-theme'

# put a symlink to ~/.oh-my-zsh/custom
if [[ -d "~/.oh-my-zsh/custom" ]]; then
	ln -s $installFile $ZSH/custom/vibrant.zsh-theme
	echo "Linked the theme file to Oh My ZSH's \`custom\` directory."$nl
fi