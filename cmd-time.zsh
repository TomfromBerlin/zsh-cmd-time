################################################################################
#                                                                              #
#        Everything below this line comes with no warranty of any kind.        #
#                     Use these file at your own risk!                         #
# last update: 10/2025                                                         #
################################################################################
#                                                                              #
# This plugin will overwrite your existing RPS1.                               #
# You can avoid that by replacing the RPS1 definition in line 89               #
# For the output of the execution time you have to keep ${cmd_time_elapsed}   #
#                                                                              #
# For the output of decimal places you have to put                             #
#                                                                              #
# typeset -F SECONDS                                                           #
#                                                                              #
# into your .zshrc, otherwise there will be only zeros as decimal places.      #
#                                                                              #
# You also may add the following line to the config-section                    #
# in your .zhrc-file:                                                          #
#             : ${CMD_TIME_EXCLUDE:="^(ls|cd|pwd|clear|exit)$"}                #
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

autoload -Uz is-at-least
if ! is-at-least 5.0.5; then
    print -P "%F{red}Error: zsh-cmd-time requires Zsh >= 5.0.5%f" >&2
    print -P "%F{yellow}(Need EPOCHREALTIME support)%f" >&2
    return 1
fi

# Load hook system
autoload -Uz add-zsh-hook
# Register hooks
if ! add-zsh-hook preexec _cmd_time_preexec; then
    print -P "%F{red}Error: Failed to register preexec hook%f" >&2
    return 1
fi
if ! add-zsh-hook precmd _cmd_time_precmd; then
    print -P "%F{red}Error: Failed to register precmd hook%f" >&2
    return 1
fi

setopt localoptions

# Redraw prompt when terminal size changes
TRAPWINCH() {
    zle && zle -R
    }
_cmd_time_preexec() {
  # check excluded
    typeset -g cmd_time_timer
    [[ -n "$ZSH_CMD_TIME_EXCLUDE" ]] && for exc in $ZSH_CMD_TIME_EXCLUDE; do [ "$(echo "$1" | grep -c "$exc")" -gt 0 ] && RPS1='${vcs_info_msg_0_} %(?.%F{green}√.%K{red}%F{black} Nope!)%f%k' && return; done
    cmd_time_timer=${cmd_time_timer:-$SECONDS}
    cmd_time_timer_show=""
    export cmd_time_timer_show
    }
_cmd_time_precmd() {
    cmd_time_timer_show=""
    [[ $cmd_time_timer ]] && typeset -g cmd_time_timer_show=$(($SECONDS - $cmd_time_timer))
    export cmd_time_timer_show && zsh_cmd_time
    unset cmd_time_timer
    }
zsh_cmd_time() {
    if [[ -n "$cmd_time_timer_show" ]]; then
# we leave the handling of floating point numbers to bc --> https://www.gnu.org/software/bc/manual/html_mono/bc.html
        local h=$(bc <<< "${cmd_time_timer_show}/3600") && local m=$(bc <<< "(${cmd_time_timer_show}%3600)/60") && local s=$(bc <<< "${cmd_time_timer_show}%60")
        if [[ "$cmd_time_timer_show" -le 1 ]]; then ZSH_CMD_TIME_COLOR="magenta" && cmd_time_timer_show=$(printf '%.6f'" sec" "$cmd_time_timer_show")
        elif [[ "$cmd_time_timer_show" -le 60 ]]; then ZSH_CMD_TIME_COLOR="green" && cmd_time_timer_show=$(printf '%.3f'" sec" "$cmd_time_timer_show")
# '%.nf' defines the number of decimal places, where n is an integer. Values
# above 14 are possible, but not useful, because the computer's internal
# representation of floating point numbers has a limited number of bits and as
# a consequence a limited accuracy. So numbers with floating point cannot be
# stored as e.g. 3.0000000000 in memory, but as 3.0000000002 or 2.9999999998.
# Rounding errors are therefore unavoidable and you can safely ignore everything
# after the 14th decimal place in a result.
        elif [[ "$cmd_time_timer_show" -gt 60 ]] && [[ "$cmd_time_timer_show" -le 180 ]]; then ZSH_CMD_TIME_COLOR="cyan" && cmd_time_timer_show=$(printf '%02dm:%02ds' $((m)) $((s)))
        elif [[ "$h" -gt 0 ]]; then m=$((m%60)) && ZSH_CMD_TIME_COLOR="red" && cmd_time_timer_show=$(printf '%02dh:%02dm:%02ds' $((h)) $((m)) $((s))); else ZSH_CMD_TIME_COLOR="yellow" && cmd_time_timer_show=$(printf '%02dm:%02ds' $((m)) $((s)))
        fi
          typeset -g cmd_time_elapsed=$(echo -e "%F{$ZSH_CMD_TIME_COLOR}$(printf '%s' "${ZSH_CMD_TIME_MSG}"" $cmd_time_timer_show")%f")
          export cmd_time_elapsed
          RPS1='${cmd_time_elapsed} ${vcs_info_msg_0_} %(?.%F{green}√.%K{red}%F{black} Nope!)%f%k'
    fi
}
precmd_functions+=(_cmd_time_precmd)
preexec_functions+=(_cmd_time_preexec)

zsh_cmd_time_unload() {
    # Remove hooks
    add-zsh-hook -d preexec _cmd_time_preexec
    add-zsh-hook -d precmd _cmd_time_precmd
    
    # Unset functions
    unfunction _cmd_time_preexec _cmd_time_precmd _cmd_time_format
    unfunction zsh_cmd_time_unload
    
    # Unset variables
    unset CMD_TIME_{THRESHOLD,EXCLUDE,COLOR_FAST,COLOR_MEDIUM,COLOR_SLOW}
    unset CMD_TIME_THRESHOLD_{MEDIUM,SLOW}
    unset _ZSH_CMD_TIME_LOADED
    unset cmd_start_time cmd_time_display
}
