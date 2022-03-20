#!/usr/bin/env bash
# TAGS
#   grab_scp.sh
#   v2.2
# AUTHOR
#   ngadimin@warnet-ersa.net
# NOTE
#   passwordless ssh for backUP and sending newDB

PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
trap f_trap EXIT INT TERM    # cleanUP on exit, interrupt & terminate
# shellcheck source=/dev/null
source "$_DIR"/grab_lib.sh

HOST="rpz.warnet-ersa.net"   # tailorized to your environment
f_scp "$HOST"
exit 0
