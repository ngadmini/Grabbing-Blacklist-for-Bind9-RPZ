#!/usr/bin/env bash
# TAGS
#   grab_scp.sh
#   v4.2
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

cd "$_DIR"
f_syn "$HOST"
exit 0
