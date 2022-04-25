#!/usr/bin/env bash
# TAGS
#   grab_scp.sh
#   v6.2
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

umask 027; set -Eeuo pipefail
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
startTime=$(date +%s); start=$(date "+DATE: %Y-%m-%d TIME: %H:%M:%S")
trap f_trap 0 2 3 15      # cleanUP on exit, interrupt, quit & terminate
# shellcheck source=/dev/null
source "$_DIR"/grab_lib.sh

cd "$_DIR"; [ ! "$UID" -eq 0 ] || f_xcd 10
printf "\n\x1b[91m[4'th] TASKs:\x1b[0m\nStarting %s ... %s" "$(basename "$0")" "$start"
f_syn; endTime=$(date +%s); DIF=$((endTime - startTime))
printf "[INFO] Completed \x1b[93mIN %s:%s\x1b[0m\n" "$((DIF/60))" "$((DIF%60))s"
exit 0
