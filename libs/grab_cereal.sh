#!/usr/bin/env bash
# TAGS
#   grab_cereal.sh
#   v6.3
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

umask 027
SOURCED=false && [ "$0" = "${BASH_SOURCE[0]}" ] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(realpath "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")
startTime=$(date +%s)
start=$(date "+DATE: %Y-%m-%d% TIME: %H:%M:%S")

printf "\n\x1b[91m[3'th] TASKs:\x1b[0m\nStarting %s ... %s" "$(basename "$0")" "$start"
[ ! "$UID" -eq 0 ] || f_xcd 10; printf "\x1b[92m%s\x1b[0m\n" "isOK"
cd "$_DIR"; test -r "$_DIR"/grab_lib || chmod 644 "$_DIR"/grab_lib
# shellcheck source=/dev/null
source "$_DIR"/grab_lib; trap f_trap EXIT TERM; trap 'printf "\ninterrupted\n"; f_trap; exit' INT

# predefined array as a blanko to counter part 'ar_zon' array
ar_miss=()
ar_rpz=(rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf \
      rpz.adultag rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+ )
mapfile -t ar_zon < <(find . -maxdepth 1 -type f -name "rpz.*" | sed -e "s/\.\///" | sort)

printf "\n[INFO] Incrementing serial of zone files (rpz.* files)\n"
if [ "${#ar_zon[@]}" -eq "${#ar_rpz[@]}" ]; then
   printf "[INFO] FOUND:\t%s complete\n" "${#ar_zon[@]}"
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
      f_g4c "$Z"; chmod 640 "$Z"
   done
   printf "[INFO] ALL serial zones incremented to \x1b[93m%s\x1b[0m\n" "$newSERIAL"

elif [ "${#ar_zon[@]}" -gt "${#ar_rpz[@]}" ]; then
     printf "[ERROR] rpz.* files: %s exceeds from %s\n" "${#ar_zon[@]}" "${#ar_rpz[@]}"
     printf "[HINTS] please double-check number of db.* files and rpz.* files\n"
     exit 1

else
   printf "\x1b[91m[ERROR]\x1b[0m Failed due to: \"FOUND %s of %s zones\". %s\n" \
      "${#ar_zon[@]}" "${#ar_rpz[@]}" "Missing zone files:"
   printf -v miss "%s" "$(echo "${ar_rpz[@]}" "${ar_zon[@]}" | sed "s/ /\n/g" | sort | uniq -u | tr "\n" " ")"
   printf "~ %s\n" "$miss"
   ar_miss+=("$miss")
   printf "[INFO] Trying to get the missing file(s) from origin: %s\n" "$HOST"
   f_cer "${ar_miss[@]}"
fi

endTime=$(date +%s)
DIF=$((endTime - startTime))
printf "[INFO] Completed \x1b[93mIN %s:%s\x1b[0m\n" "$((DIF/60))" "$((DIF%60))s"
exit 0
