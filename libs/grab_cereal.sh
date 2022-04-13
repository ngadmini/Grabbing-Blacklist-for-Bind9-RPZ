#!/usr/bin/env bash
# TAGS
#   grab_cereal.sh
#   v5.2
# AUTHOR
#   ngadimin@warnet-ersa.net

SOURCED=false && [ "$0" = "${BASH_SOURCE[0]}" ] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
trap f_trap EXIT INT TERM    # cleanUP on exit, interrupt & terminate
# shellcheck source=/dev/null
source "$_DIR"/grab_lib.sh
HOST="rpz.warnet-ersa.net"      # fqdn or ip-address

cd "$_DIR"
printf "\n\x1b[91m[3'th] TASKs:\x1b[0m\n[INFO] incrementing serial of zone files (rpz.* files)\n"
mapfile -t ar_zon < <(find . -maxdepth 1 -type f -name "rpz.*" | sed -e "s/\.\///" | sort)
if [ "${#ar_zon[@]}" -eq 11 ]; then
   printf "[INFO] found:\t%s complete\n" "${#ar_zon[@]}"
   for Z in "${ar_zon[@]}"; do
      DATE=$(date +%Y%m%d)
      SERIAL=$(grep "SOA" "$Z" | cut -d \( -f2 | cut -d" " -f1)
      if [ ${#SERIAL} -lt ${#DATE} ]; then
         newSERIAL="${DATE}00"
      else
         SERIAL_date=${SERIAL::-2}                   # slice to [20190104]
         if [ "$DATE" -eq "$SERIAL_date" ]; then     # same day
            SERIAL_num=${SERIAL: -2}                 # give [00-99] times to change
            SERIAL_num=$((10#$SERIAL_num + 1))       # force decimal increment
            newSERIAL="${DATE}$(printf "%02d" $SERIAL_num)"
         else
            newSERIAL="${DATE}00"
         fi
      fi
      sed -i -e 's/'"$SERIAL"'/'"$newSERIAL"'/g' "$Z"
   done
   printf "[INFO] all serial zones incremented to \x1b[93m%s\x1b[0m\n" "$newSERIAL"

else
   ar_rpz=(rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf \
      rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+ )
   printf "\x1b[91m[ERROR]\x1b[0m Failed due to: \"FOUND %s of 11 zones\". %s\n" \
      "${#ar_zon[@]}" "Missing zone files:"
   printf -v ms_v "%s" "$(echo "${ar_rpz[@]}" "${ar_zon[@]}" | sed "s/ /\n/g" | sort | uniq -u)"
   printf "%s" "$ms_v" | tr "\n" "," | sed -e "s/,$//g" > /tmp/mr_p
   printf "~ %s\n" "$(cat /tmp/mr_p)"
   printf "[INFO] Trying to get the missing file(s) from origin: %s\n" "$HOST"
   f_cer "$HOST"
fi
exit 0
