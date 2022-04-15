#!/usr/bin/env bash
# TAGS
#   grab_cereal.sh
#   v6.2
# AUTHOR
#   ngadimin@warnet-ersa.net
# see README and LICENSE

umask 027
set -Eeu
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
startTime=$(date +%s)
start=$(date "+DATE: %Y-%m-%d% TIME: %H:%M:%S")
trap f_trap EXIT INT TERM       # cleanUP on exit, interrupt & terminate
# shellcheck source=/dev/null
source "$_DIR"/grab_lib.sh

# these array is predefined and as a blanko, to counter part 'ar_zon' array
ar_blanko=(rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf \
      rpz.adultag rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+ )
mapfile -t ar_zon < <(find . -maxdepth 1 -type f -name "rpz.*" | sed -e "s/\.\///" | sort)

cd "$_DIR"; [ ! "$UID" -eq 0 ] || f_excod 10
printf "\n\x1b[91m[3'th] TASKs:\x1b[0m\nStarting %s ... %s\n" "$(basename "$0")" "$start"
printf "[INFO] Incrementing serial of zone files (rpz.* files)\n"
if [ "${#ar_zon[@]}" -eq "${#ar_blanko[@]}" ]; then
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
      f_g4c "$Z"
   done
   printf "[INFO] ALL serial zones incremented to \x1b[93m%s\x1b[0m\n" "$newSERIAL"

elif [ "${#ar_zon[@]}" -gt "${#ar_blanko[@]}" ]; then
     printf "[ERROR] rpz.* files: %s exceeds from %s\n" "${#ar_zon[@]}" "${#ar_blanko[@]}"
     printf "[HINTS] please double-check number of db.* files and rpz.* files\n"
     exit 1
else
   printf "\x1b[91m[ERROR]\x1b[0m Failed due to: \"FOUND %s of %s zones\". %s\n" \
      "${#ar_zon[@]}" "${#ar_blanko[@]}" "Missing zone files:"
   printf -v ms_v "%s" "$(echo "${ar_blanko[@]}" "${ar_zon[@]}" | sed "s/ /\n/g" | sort | uniq -u)"
   printf "%s" "$ms_v" | tr "\n" "," | sed -e "s/,$//g" > /tmp/mr_p
   printf "~ %s\n" "$(cat /tmp/mr_p)"
   printf "[INFO] Trying to get the missing file(s) from origin: %s\n" "$HOST"
   f_cer
fi

endTime=$(date +%s)
DIF=$((endTime - startTime))
printf "[INFO] Completed \x1b[93mIN %s:%s\x1b[0m\n" "$((DIF/60))" "$((DIF%60))s"
exit 0
