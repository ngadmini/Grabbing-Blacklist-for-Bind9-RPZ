#!/usr/bin/env bash
# TAGS;VERSION
#   grab_scp.sh
#   v6.4
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

SOURCED=false && [ "$0" = "${BASH_SOURCE[0]}" ] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(realpath "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")
startTime=$(date +%s)
start=$(date "+DATE: %Y-%m-%d% TIME: %H:%M:%S")
_red="\e[91m"
_ncl="\e[0m"
_tsk="${_red}[4'th] TASKs:${_ncl}"

cd "$_DIR"
test -r "$_DIR"/grab_lib || chmod 644 "$_DIR"/grab_lib
# shellcheck source=/dev/null
source "$_DIR"/grab_lib
trap f_trap EXIT TERM
trap 'printf "\ninterrupted\n"; f_trap; exit' INT

printf "\n${_tsk}\nstarting %s ... %s" "$(basename "$0")" "$start"
[ ! "$UID" -eq 0 ] || f_xcd 10

f_pms   # start syncronizing
f_syn

endTime=$(date +%s)
DIF=$((endTime - startTime))
f_sm11 "$((DIF/60))" "$((DIF%60))s"
exit 0
