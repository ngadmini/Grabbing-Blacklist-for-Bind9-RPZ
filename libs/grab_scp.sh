#!/usr/bin/env bash
# TAGS
#   grab_scp.sh
#   v2.2
# AUTHOR
#   ngadimin@warnet-ersa.net
# NOTE
#   passwordless ssh for backUP and sending newDB

SOURCED=false && [ "$0" = "${BASH_SOURCE[0]}" ] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
trap f_trap EXIT INT TERM    # cleanUP on exit, interrupt & terminate
# shellcheck source=/dev/null
source "$_DIR"/grab_lib.sh
HOST="rpz.warnet-ersa.net"   # fqdn or ip-address

cd "$(dirname "${BASH_SOURCE[0]}")"
mapfile -t ar_db < <(find . -maxdepth 1 -type f -name "db.*" | sed -e 's/\.\///' | sort)
mapfile -t ar_rpz < <(find . -maxdepth 1 -type f -name "rpz.*" | sed -e 's/\.\///' | sort)
if [ "${#ar_db[@]}" -eq 11 ] && [ "${#ar_rpz[@]}" -eq 11 ]; then
	f_scp "$HOST"
else
	exit 1
fi
exit 0
