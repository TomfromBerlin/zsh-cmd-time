# Standardized $0 handling
# (See https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html)
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
# Set $0 with a new trik - use of %x prompt expansion
0="${ZERO:-${${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}:A}}"
local ZERO="$0"
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html#indicator
if [[ ${zsh_loaded_plugins[-1]} != */zsh-cmd-time && -z ${fpath[(r)${0:h}]} ]] {
    fpath+=( "${0:h}" )
}
source ${0:A:h}/cmd-time.zsh
