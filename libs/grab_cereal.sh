#!/usr/bin/env bash
# TAGS
#   grab_cereal.sh
#   v4.2
# AUTHOR
#   ngadimin@warnet-ersa.net

SOURCED=false && [ "$0" = "${BASH_SOURCE[0]}" ] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd "$_DIR"
printf "\n\x1b[91m[3'th] TASK:\x1b[0m\nIncrementing serial of zone files (rpz.* files)\n"
mapfile -t ar_zon < <(find . -maxdepth 1 -type f -name "rpz.*" | sed -e 's/\.\///' | sort)
if [ "${#ar_zon[@]}" -eq 11 ]; then
   printf "FOUND:\t%s complete\n" "${#ar_zon[@]}"
   for Z in "${ar_zon[@]}"; do
      DATE=$(date +%Y%m%d)
      SERIAL=$(grep "SOA" "$Z" | cut -d \( -f2 | cut -d' ' -f1)
      if [ ${#SERIAL} -lt ${#DATE} ]; then
         newSERIAL="${DATE}00"
      else
         SERIAL_date=${SERIAL::-2}                   # slice to [20190104]
         if [ "$DATE" -eq "$SERIAL_date" ]; then     # same day
            SERIAL_num=${SERIAL: -2}                 # give [00-99] times to change
            SERIAL_num=$((10#$SERIAL_num + 1))       # force decimal increment
            newSERIAL="${DATE}$(printf '%02d' $SERIAL_num)"
         else
            newSERIAL="${DATE}00"
         fi
      fi
      sed -i -e 's/'"$SERIAL"'/'"$newSERIAL"'/g' "$Z"
   done
   printf "all serial zones incremented to \x1b[93m%s\x1b[0m\n" "$newSERIAL"

else
   HOST="rpz.warnet-ersa.net"   # fqdn or ip-address
   ar_rpz=(rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf \
            rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+ )
   printf "\x1b[91m[Error]\x1b[0m Failed due to: \"FOUND %s of 11 zones\". Missing zones files:\n" "${#ar_zon[@]}"
   printf -v ms_v "%s" "$(echo "${ar_rpz[@]}" "${ar_zon[@]}" | sed "s/ /\n/g" | sort | uniq -u)"
   printf "%s" "$ms_v" | tr '\n' ',' | sed -e 's/,$//g' > /tmp/mr_p
   printf "~ %s\n" "$(cat /tmp/mr_p)"
   printf "\x1b[32m[Info]\x1b[0m Trying to get the missing file(s) from origin: %s\n" "$HOST"
   if ping -w 1 "$HOST" >> /dev/null 2>&1; then
      miss="$(cat /tmp/mr_p)"
      # passwordless ssh
      if ! scp -qr root@$HOST:/etc/bind/zones-rpz/"{$miss}" "$_DIR" >> /dev/null 2>&1; then
         printf "\x1b[32m[Info]\x1b[0m One or more zones files are missing. %s\n" "You should create:"
         printf "~ %s\n\x1b[91m[Error]\x1b[0m %s\n" "$miss" "Incomplete TASK"
         exit 1
      else
         printf "\x1b[32m[Info]\x1b[0m Successfully copied:\n~ %s\n" "$miss"
         printf "\x1b[32m[Info]\x1b[0m Retry running TASK again\n"
         exec "$0"
      fi
   else
      printf "HOST = \x1b[93m%s\x1b[0m if that address is correct, maybe DOWN\n%s\n" "$HOST" "Incomplete TASK"
      exit 1
   fi
   rm /tmp/mr_p
fi
unset -v ar_{zon,rpz}
exit 0
