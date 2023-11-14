################################################################################
#                                                                              #
#        Everything below this line comes with no warranty of any kind.        #
#                     Use these file at your own risk!                         #
# last update: 07/2023                                                         #
################################################################################
#                                                                              #
# This plugin will overwrite your existing RPS1.                               #
# You can avoid that by replacing the RPS1 definition in line 36 and           #
# line 60 with your own.                                                       #
# For the output of the execution time you have to keep ${elapsed} in line 60. #
#                                                                              #
# for the output of decimal places you have to put                             #
#                                                                              #
# typeset -F SECONDS                                                           #
#                                                                              #
# into your .zshrc, otherwise there will be only zeros as decimal places.      #
#                                                                              #
################################################################################
# Standardized $0 handling (See https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html)
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
# Set $0 with use of %x prompt expansion
0="${ZERO:-${${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}:A}}"
local ZERO="$0"
typeset -g CMD_TIME_DIR="${0:A:h}"
# https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
typeset -gA Plugins
Plugins[cmd-time]="${0:h}"
# Redraw prompt when terminal size changes
TRAPWINCH() {
    zle && zle -R
    }
_cmd_time_preexec() {
  # check excluded
    [[ -n "$ZSH_CMD_TIME_EXCLUDE" ]] && for exc in $ZSH_CMD_TIME_EXCLUDE; do [ "$(echo "$1" | grep -c "$exc")" -gt 0 ] && RPS1='${vcs_info_msg_0_} %(?.%F{green}√.%K{red}%F{black} Nope!)%f%k' && return; done
    timer=${timer:-$SECONDS}
    timer_show=""
    export timer_show
    }
_cmd_time_precmd() {
    timer_show=""
    [[ $timer ]] && timer_show=$(($SECONDS - $timer))
    export timer_show && zsh_cmd_time
    unset timer
    }
zsh_cmd_time() {
    if [[ -n "$timer_show" ]]; then
# we leave the handling of floating point numbers to bc --> https://www.gnu.org/software/bc/manual/html_mono/bc.html
        h=$(bc <<< "${timer_show}/3600") && m=$(bc <<< "(${timer_show}%3600)/60") && s=$(bc <<< "${timer_show}%60")
        if [[ "$timer_show" -le 1 ]]; then ZSH_CMD_TIME_COLOR="magenta" && timer_show=$(printf '%.6f'" sec" "$timer_show")
        elif [[ "$timer_show" -le 60 ]]; then ZSH_CMD_TIME_COLOR="green" && timer_show=$(printf '%.3f'" sec" "$timer_show")
# '%.nf' defines the number of decimal places, where n is an integer. Values
# above 14 are possible, but not useful, because the computer's internal
# representation of floating point numbers has a limited number of bits and as
# a consequence a limited accuracy. So numbers with floating point cannot be
# stored as e.g. 3.0000000000 in memory, but as 3.0000000002 or 2.9999999998.
# Rounding errors are therefore unavoidable and you can safely ignore everything
# after the 14th decimal place in a result.
        elif [[ "$timer_show" -gt 60 ]] && [[ "$timer_show" -le 180 ]]; then ZSH_CMD_TIME_COLOR="cyan" && timer_show=$(printf '%02dm:%02ds' $((m)) $((s)))
        elif [[ "$h" -gt 0 ]]; then m=$((m%60)) && ZSH_CMD_TIME_COLOR="red" && timer_show=$(printf '%02dh:%02dm:%02ds' $((h)) $((m)) $((s))); else ZSH_CMD_TIME_COLOR="yellow" && timer_show=$(printf '%02dm:%02ds' $((m)) $((s)))
        fi
          elapsed=$(echo -e "%F{$ZSH_CMD_TIME_COLOR}$(printf '%s' "${ZSH_CMD_TIME_MSG}"" $timer_show")%f")
          export elapsed
          RPS1='${elapsed} ${vcs_info_msg_0_} %(?.%F{green}√.%K{red}%F{black} Nope!)%f%k'
    fi
}
precmd_functions+=(_cmd_time_precmd)
preexec_functions+=(_cmd_time_preexec)
#
