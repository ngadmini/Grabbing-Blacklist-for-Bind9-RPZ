#!/usr/bin/env bash
# TAGS
#   grab_build.sh
#   v3.2
# AUTHOR
#   ngadimin@warnet-ersa.net

SOURCED=false && [ "$0" = "${BASH_SOURCE[0]}" ] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export LC_NUMERIC=id_ID.UTF-8
startTime=$(date +%s)
trap f_trap EXIT INT TERM   # cleanUP on exit, interrupt & terminate
# shellcheck source=/dev/null
source "$_DIR"/grab_lib.sh

cd "$_DIR"
printf "\n\x1b[91m[2'nd] TASK:\x1b[0m\nSplitting adult category to 750.000 lines/sub-category\n"
[ -f "txt.adult" ] || f_excod 17 "txt.adult"; split -l 750000 txt.adult txt.adult; mv txt.adult /tmp
mapfile -t ar_txt < <(find . -maxdepth 1 -type f -name "txt.*" | sed -e 's/\.\///' | sort)
if [ "${#ar_txt[@]}" -eq 11 ]; then
   ar_cat=(); ar_dom=()
   for Y in {0..10}; do
      ar_cat+=("${ar_txt[Y]/txt./}")
      ar_dom+=("${ar_txt[Y]/txt./db.}")
   done
   find . -maxdepth 1 -type f -name "db.*" -print0 | xargs -0 -r rm
   printf "Rewriting all domain lists to RPZ format :\n\x1b[93m%s\x1b[0m\n" "${ar_cat[*]}"
   for X in {0..10}; do
      if [ "$X" -eq 6 ]; then
         # policy: NS-IP Trigger NXDOMAIN Action
         f_ip4 "${ar_dom[X]}" "${ar_txt[X]}" "${ar_cat[X]}"
      else
         # policy: QNAME Trigger NXDOMAIN Action
         f_rpz "${ar_dom[X]}" "${ar_txt[X]}" "${ar_cat[X]}"
      fi
   done
   printf -v ttl "%'d" "$(wc -l "${ar_dom[@]}" | grep "total" | cut -d' ' -f2)"
   printf "%41s : %10s entries\n" "TOTAL" "$ttl"
else
   printf "\n\x1b[91mFAILED due to:\x1b[0m just FOUND %s of 11 domain list:\n\t%s\n" "${#ar_txt[@]}" "${ar_txt[*]}"
   exit 1
fi

endTime=$(date +%s)
DIF=$((endTime - startTime))
printf "completed \x1b[93mIN %s:%s\x1b[0m\n" "$((DIF/60))" "$((DIF%60))s"
exit 0
