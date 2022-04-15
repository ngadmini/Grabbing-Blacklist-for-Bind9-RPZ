#!/usr/bin/env bash
# TAGS
#   grab_scp.sh
#   v6.2
# AUTHOR
#   ngadimin@warnet-ersa.net
# see README and LICENSE

SOURCED=false && [ "$0" = "${BASH_SOURCE[0]}" ] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
startTime=$(date +%s)
# shellcheck disable=SC2034
start=$(date "+DATE: %Y-%m-%d TIME: %H:%M:%S")
trap f_trap EXIT INT TERM    # cleanUP on exit, interrupt & terminate
# shellcheck source=/dev/null
source "$_DIR"/grab_lib.sh

_ssh -o BatchMode=yes "$HOST" /bin/true  >> /dev/null 2>&1 || f_excod 7 "$HOST"
cd "$_DIR"
f_syn
endTime=$(date +%s)
DIF=$((endTime - startTime))
printf "[INFO] Completed \x1b[93mIN %s:%s\x1b[0m\n" "$((DIF/60))" "$((DIF%60))s"
exit 0
