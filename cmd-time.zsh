
################################################################################
#                                                                              #
#        Everything below this line comes with no warranty of any kind.        #
#                     Use these file at your own risk!                         #
#                                                                              #
################################################################################
#                                                                              #
# for output in milliseconds, or even nanoseconds you have to put              #
# somewhere into your .zshrc                                                   #
# typeset -F SECONDS                                                           #
#                                                                              #
# otherwise there will be only zeros as decimal places.                        #
#                                                                              #
################################################################################
_cmd_time_preexec() {
  # check if command is excluded
  if [[ -n "$ZSH_CMD_TIME_EXCLUDE" ]]; then
    cmd="$1"
    for exc in $ZSH_CMD_TIME_EXCLUDE; do
      if [[ "$(echo "$cmd" | grep -c "$exc")" -gt 0 ]]; then
#        echo "Command excluded: $exc"
        return
      fi
    done
  fi
  timer=${timer:-$SECONDS}
  ZSH_CMD_TIME_MSG=${ZSH_CMD_TIME_MSG-"Time: %s"}
  ZSH_CMD_TIME_COLOR=${ZSH_CMD_TIME_COLOR-"cyan"}
  ZSH_CMD_TIME=""
  export ZSH_CMD_TIME
}
_cmd_time_precmd() {
  if [[ $timer ]]; then
    timer_show=$(($SECONDS - $timer))
      export ZSH_CMD_TIME="$timer_show"
      zsh_cmd_time
    unset timer
  fi
}
zsh_cmd_time() {
    if [[ -n "$ZSH_CMD_TIME" ]]; then
# we leave the handling of floating point numbers to bc --> https://www.gnu.org/software/bc/manual/html_mono/bc.html
        h=$(bc <<< "${ZSH_CMD_TIME}/3600")
        m=$(bc <<< "(${ZSH_CMD_TIME}%3600)/60")
        s=$(bc <<< "${ZSH_CMD_TIME}%60")
        if [[ "$ZSH_CMD_TIME" -le 1 ]]; then
             ZSH_CMD_TIME_COLOR="magenta"
             timer_show=$(printf '%.6f'" sec" "$ZSH_CMD_TIME")
        elif [[ "$ZSH_CMD_TIME" -le 60 ]]; then
             ZSH_CMD_TIME_COLOR="green"
             timer_show=$(printf '%.3f'" sec" "$ZSH_CMD_TIME") # "%.nf" defines the number of decimal places,
                                                           # where "n" is an integer. Values above 14 are
                                                           # possible, but not useful, because the
                                                           # computer's internal representation of
                                                           # floating point Numbers has a limited number
                                                           # of bits and as a consequence a limited accuracy.
                                                           # So numbers with floating point cannot be
                                                           # stored as e.g. 3.000000000.... in memory,
                                                           # but as 3.0000000002 or 2.99999998.
                                                           # You can safely ignore everything after
                                                           # the 14th decimal place in a result.
        elif [[ "$ZSH_CMD_TIME" -gt 60 ]] && [[ "$ZSH_CMD_TIME" -le 180 ]]; then
             ZSH_CMD_TIME_COLOR="cyan"
             timer_show=$(printf '%02dm:%02ds' $((m)) $((s)))
        else
            if [[ "$h" -gt 0 ]]; then
                m=$((m%60))
             ZSH_CMD_TIME_COLOR="red"
                 timer_show=$(printf '%dh:%02dm:%02ds' $((h)) $((m)) $((s)))
            else
             ZSH_CMD_TIME_COLOR="yellow"
                 timer_show=$(printf '%02dm:%02ds' $((m)) $((s)))
            fi
        fi
          elapsed=$(echo -e "%F{$ZSH_CMD_TIME_COLOR}$(printf '%s' "${ZSH_CMD_TIME_MSG}"" $timer_show")%f")
          export elapsed
    fi
}
precmd_functions+=(_cmd_time_precmd)
preexec_functions+=(_cmd_time_preexec)
#
# add the following line to your prompt definitions (probably in your .zshrc)
#        RPS1='$elapsed %(?.%F{green}√.%K{red}%F{black} Nope!)%f%k'
