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

cd "$_DIR"
test -r "$_DIR"/grab_lib || chmod 644 "$_DIR"/grab_lib
# shellcheck source=/dev/null
source "$_DIR"/grab_lib
trap f_trap EXIT TERM
trap 'printf "\ninterrupted\n"; f_trap; exit' INT

printf "\n\e[91m[3'th] TASKs:\e[0m\nStarting %s ... %s" "$(basename "$0")" "$start"
[ ! "$UID" -eq 0 ] || f_xcd 10

find . -regextype posix-extended -regex "^.*(db|rpz).*" -not -perm 640 -exec chmod -R 640 {} \;
f_syn   # start syncronizing

endTime=$(date +%s)
DIF=$((endTime - startTime))
printf "\e[93m[INFO]\e[0m Completed \e[93mIN %s:%s\e[0m\n" "$((DIF/60))" "$((DIF%60))s"
exit 0
