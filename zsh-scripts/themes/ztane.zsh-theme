#
# Fuuuuck this mess needs clear up and proper annoation.
# Pulling my last hair.
# -Mikko
#
# http://zsh.sourceforge.net/Intro/intro_14.html
#
# http://www.dawoodfall.net/index.php/custom-zsh-prompts
#

# Load modular prompt panel system
source "${0:A:h}/../config/panel-config.zsh"
source "${0:A:h}/../lib/prompt-panels.zsh"

# The string here is not actually used.. no idea
PROMPT='%{$fg_bold[green]%}%p %{$fg[cyan]%}%c%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}'

#
# Set a special prompt if you are on a server identified by /etc/server-status file
# This is useful e.g. setting a warning message on production servers
#
if [[ -e /etc/server-status ]]
then
    SERVER_STATUS_ENABLED=1
fi

PROMPT_HOSTNAME=$(hostname)

#
# Setup prompt bg color by a server.
#
function prompt_bg_color_by_server {

}

function setup_prompt {

    # Right side of the prompt
    # Something
    # Bold [
    # Some PROMPT_USER_COLOR
    # %n user
    # PROMPT_HOSTNAME in special PROMPT_HOST_COLOR
    RPROMPT=$(echo -ne "%{\033[A%}%{\033[1;37m%}%B[%{\033[${PROMPT_USER_COLOR:-1;33}m%}%n%{\033[0m%}%B@%{\033[${PROMPT_HOST_COLOR:-1;33}m%}$PROMPT_HOSTNAME%b%B][%{\033[1;32m%}%*%b%B]%{\033[B%}")

    # Left side of the prompt
    # Start bold mode
    # Show git prompt info
    # New line
    # Show the current folder
    PROMPT=$(echo -ne '%B$(git_prompt_info)\n%{\033[0m%}%B[%{\033[36m%}%~%b%B]%# ')

    # Initialize and execute modular prompt panels
    init_prompt_panels
    setup_prompt_panels
}

if [[ -x /usr/bin/hostname-filter ]]
then
    PROMPT_HOSTNAME=$(/usr/bin/hostname-filter)
fi

setup_prompt


#
# Git repo indicator integration
#
ZSH_THEME_GIT_PROMPT_PREFIX="[%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[white]%}]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}✘"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✔"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="%{$fg[yellow]%}↓"    # Large down arrow
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="%{$fg[yellow]%}↑"     # Large up arrow
ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE="%{$fg[red]%}⮃"  # Up arrow left of down arrow
ZSH_THEME_GIT_PROMPT_PRECOMMIT_OK=""                        # nothing if all fine
ZSH_THEME_GIT_PROMPT_PRECOMMIT_WARN="%{$fg[yellow]%}?%{$reset_color%}"  # no config
ZSH_THEME_GIT_PROMPT_PRECOMMIT_FAIL="%{$fg[red]%}%B!%b%{$reset_color%}"  # config exists but not installed
