#!/usr/bin/env bash
# TAGS
#   grab_scp.sh
#   v6.5
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2154

startTime=$SECONDS
set -Euo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# START <main script>
[[ -r $_DIR/grab_lib ]] || chmod 644 "$_DIR"/grab_lib
source "$_DIR"/grab_lib
f_trap     # cleanUP on exit, interrupt & terminate

printf "\n${_ts4}\nstarting %s at %s" "${0##*/}" "$(date)"
cd "$_DIR" || exit
[[ ! $UID -eq 0 ]] || f_xcd 10

f_pms      # start syncronizing
f_syn      #

runTime=$((SECONDS - startTime))
f_sm11 "$((runTime/60))m" "$((runTime%60))s"
exit 0
