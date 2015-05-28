# Vibrant ZSH theme
# Jannis R <mail@jannisr.de>
# https://github.com/derhuerst/vibrant-zsh-theme



# Characters

# Indicator for a POSIX privileged user.
vibrant_privileged_user='\u26a1' # `⚡`
#vibrant_privileged_user='\u2605' # `★`
#vibrant_privileged_user='\u2654' # `♔`
#vibrant_privileged_user='\u2691' # `⚑`
#vibrant_privileged_user='\u01c3' # `ǃ`
#vibrant_privileged_user='\u2691' # `‼`

# Indicator for background jobs.
vibrant_jobs='\u2699' # `⚙`
#vibrant_jobs='\u2026' # `…`

# Git: Indicator for untracked changes.
vibrant_git_untracked='\u2732' # `✲`
#vibrant_git_untracked='\u2605' # `★`

# Git: Indicator for unstaged changes.
vibrant_git_unstaged='\u00b1' # `±`

# Git: Indicator for staged changes.
vibrant_git_staged='\u2191' # `↑`
#vibrant_git_staged='\u2708' # `✈`

# Git: Symbol in front of the current branch.
vibrant_git_branch='\u2442' # `⑂
#vibrant_git_branch='\u2443' # `⑃`
#vibrant_git_branch='\u2325' # `⌥`

# Git: Symbol in front of the current tag.
vibrant_git_tag='\u27a6' # `➦`
#vibrant_git_tag='\u27ad' # `➭`
#vibrant_git_tag='\u270e' # `✎`

# Git: Symbol in front of the current commit.
vibrant_git_commit='\u25e6' # `◦`
#vibrant_git_commit='\u237f' # `⍿`
#vibrant_git_commit='\u21f4' # `⇴`

# Prompt symbol if the last command ran *successfully*.
vibrant_prompt_ok='\u2794' # `➔`
#vibrant_prompt_ok='\u27a4' # `➤`
#vibrant_prompt_ok='\u2666' # `♦`
#vibrant_prompt_ok='\u2022' # `•`
#vibrant_prompt_ok='\u2713' # `✓`

# Prompt symbol if the last command ran *with errors*.
vibrant_prompt_error='\u2794' # `➔`
#vibrant_prompt_error='\u27a4' # `➤`
#vibrant_prompt_error='\u2666' # `♦`
#vibrant_prompt_error='\u2022' # `•`
#vibrant_prompt_error='\u2717' # `✗`
#vibrant_prompt_error='\u2718' # `✘`
#vibrant_prompt_error='\u26a0' # `⚠`



# Segments
# Each segment draws and hides itself if nothing needs to be shown.

# prints status information
vibrant_print_status() {
	local chunks
	chunks=()

	# Check if the current user is POSIX privileged.
	[[ $UID -eq 0 ]] && chunks+="%{%F{yellow}%}$vibrant_privileged_user"

	# Check if there are background jobs.
	[[ $(jobs -l | wc -l) -gt 0 ]] && chunks+="%{%F{blue}%}$vibrant_jobs"

	[[ -n "$chunks" ]] && print -n "${(j: :)chunks} "
}

# prints user and hostname
vibrant_print_login() {
	local chunks
	chunks=()

	# Check if the current user is non-default.
	if [[ $USER != $DEFAULT_USER || -n $SSH_CONNECTION ]]; then
		if [[ $UID -eq 0 ]]; then
			chunks+="%{%F{red}%}%n"
		else
			chunks+="%{%F{yellow}%}%n"
		fi
	fi

	 # Check if connected via SSH.
	[[ -n $SSH_CONNECTION ]] && chunks+="%{%F{white}%}@%{%F{cyan}%}%m"

	[[ -n "$chunks" ]] && print -n "${(j::)chunks} "
}

# prints the current and its parent directory
# todo: shorten long directory names *in their middle*
vibrant_print_cwd() {
	print -n "%{%F{white}%}%2~ "
}

# prints the git status
vibrant_print_git() {
	local chunks gitStatus untracked unstaged staged branch

	chunks=()

	gitStatus=$(git status --porcelain --ignore-submodules -b 2> /dev/null)
	[[ -z $gitStatus ]] && return # exit if git threw an error

	untracked=$(echo $gitStatus | grep '^\?' | wc -l | bc)
	[[ $untracked -gt 0 ]] && chunks+="%{%F{red}%}$vibrant_git_untracked$untracked"

	unstaged=$(echo $gitStatus | grep '^.[A-Z]' | wc -l | bc)
	[[ $unstaged -gt 0 ]] && chunks+="%{%F{red}%}$vibrant_git_unstaged$unstaged"

	staged=$(echo $gitStatus | grep '^[A-Z]' | wc -l | bc)
	[[ $staged -gt 0 ]] && chunks+="%{%F{yellow}%}$vibrant_git_staged$staged"

	# Check if we've checked out a branch.
	ref=$(git symbolic-ref --short -q HEAD 2> /dev/null)
	if [[ -z $ref ]]; then
		# Check if we've checked out a tag.
		ref=$(git describe --tag 2> /dev/null)
		if [[ -z $ref ]]; then
			# Print the current commit.
			ref=$(git rev-parse --short HEAD)
			chunks+="%{%F{blue}%}$vibrant_git_commit$ref "
		else
			# Print the current tag.
			chunks+="%{%F{blue}%}$vibrant_git_tag$ref "
		fi
	else
		# Print the current ref.
		chunks+="%{%F{blue}%}$vibrant_git_branch$ref "
	fi

	[[ -n "$chunks" ]] && print -n "${(j::)chunks} "
}

# prints the prompt symbol
vibrant_print_prompt() {
	if [[ $vibrant_last_exit_code -eq 0 ]]; then
		print -n "%{%F{green}%}$vibrant_prompt_ok"
	else
		print -n "%{%F{red}%}$vibrant_prompt_error"
	fi
	print -n "%{%F{white}%} "
}



# print all segments
vibrant_print() {
	vibrant_last_exit_code=$?
	vibrant_print_status
	vibrant_print_login
	vibrant_print_cwd
	vibrant_print_git
	vibrant_print_prompt
}
PROMPT='$(vibrant_print)'
