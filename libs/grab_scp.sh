#!/usr/bin/env bash
# TAGS
#   grab_scp.sh
#   v6.4
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

startTime=$SECONDS
SOURCED=false && [[ $0 = "${BASH_SOURCE[0]}" ]] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi

PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
_red="\e[91m"
_ncl="\e[0m"
_tsk="${_red}[4'th] TASKs:${_ncl}"

# START <main script>
printf "\n${_tsk}\nstarting %s at %s" "$(basename "$0")" "$(date)"
cd "$_DIR"
test -r "$_DIR"/grab_lib || chmod 644 "$_DIR"/grab_lib
# shellcheck source=/dev/null
source "$_DIR"/grab_lib
f_trap                      # cleanUP on exit, interrupt & terminate
[[ ! $UID -eq 0 ]] || f_xcd 10

f_pms   # start syncronizing
f_syn   #

runTime=$((SECONDS - startTime))
f_sm11 "$((runTime/60))m" "$((runTime%60))s"
exit 0
