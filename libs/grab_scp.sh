#!/usr/bin/env bash
# TAGS
#   grab_scp.sh
#   v6.4
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

startTime=$SECONDS
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
SOURCED=false && [[ $0 = "${BASH_SOURCE[0]}" ]] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi

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
trap f_trap 0 1 2 3 6 15   # exit, clean tidy-up, interrupt, quit, abort and terminate
[[ ! $UID -eq 0 ]] || f_xcd 10

f_pms   # start syncronizing
f_syn   #

endTime=$SECONDS
runTime=$((endTime - startTime))
f_sm11 "$((runTime/60))m" "$((runTime%60))s"
exit 0
