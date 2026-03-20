# Standardized $0 handling (See https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html)
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
# Set $0 with use of %x prompt expansion
0="${ZERO:-${${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}:A}}"
local ZERO="$0"
typeset -g CMD_TIME_DIR="${0:A:h}"
# https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
typeset -gA Plugins
Plugins[cmd-time]="${0:h}"

source ${0:A:h}/cmd-time.zsh
