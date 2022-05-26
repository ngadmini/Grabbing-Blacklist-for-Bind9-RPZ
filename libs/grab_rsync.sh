#!/usr/bin/env bash
# TAGS
#   grab_rsync.sh
#   v6.6
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2154

startTime=$SECONDS
set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

f_src() {
   readonly _LIB="$_DIR"/grab_library
   if [[ -e ${_LIB} ]]; then
      [[ -r ${_LIB} ]] || chmod 644 "${_LIB}"
      source "${_LIB}"
      f_trap                 # cleanUP on exit, interrupt & terminate
   else
      printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"
      exit
   fi
}

# START <main script>
f_src
f_cnf
printf "\n${_red}[4'th] TASKs:${_ncl}\nstarting %s at ${_cyn}%s${_ncl}\n" "${0##*/}" "${_lct}"
cd "$_DIR"
[[ ! $UID -eq 0 ]] || f_xcd 10

f_pms
f_syn      # syncronizing

runTime=$((SECONDS - startTime))
f_sm11 "$((runTime/60))m" "$((runTime%60))s"
exit 0
