#!/usr/bin/env bash
# TAGS;VERSION
#   grab_cereal.sh
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
start=$(date "+DATE: %Y-%m-%d TIME: %H:%M:%S")
_red="\e[91m"
_ylw="\e[93m"
_ncl="\e[0m"
_inf="${_ylw}[INFO]${_ncl}"
_err="${_red}[ERROR]${_ncl}"
_hnt="${_ylw}[HINTS]${_ncl}"
_tsk="${_red}[3'th] TASKs:${_ncl}"

cd "$_DIR"
test -r "$_DIR"/grab_lib || chmod 644 "$_DIR"/grab_lib
# shellcheck source=/dev/null
source "$_DIR"/grab_lib
trap f_trap EXIT TERM
trap 'printf "\ninterrupted\n"; f_trap; exit' INT

printf "\n${_tsk}\nstarting %s ... %s" "$(basename "$0")" "$start"
[ ! "$UID" -eq 0 ] || f_xcd 10

# predefined array as a blanko to counter part 'ar_zon' array
ar_miss=()
ar_rpz=(rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf \
      rpz.adultag rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+ )
mapfile -t ar_zon < <(find . -maxdepth 1 -type f -name "rpz.*" | _sed -e "s/\.\///" | sort)

printf "\n${_inf} incrementing serial of zone files (rpz.* files)%s\n" ""
if [ "${#ar_zon[@]}" -eq "${#ar_rpz[@]}" ]; then
   printf "${_inf} FOUND:\t%s complete\n" "${#ar_zon[@]}"
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
      _sed -i -e 's/'"$SERIAL"'/'"$newSERIAL"'/g' "$Z"
      f_g4c "$Z"
      find . -type f -name "$Z" -not -perm 640 -exec chmod -R 640 {} \;
   done
   printf "${_inf} all serial zones incremented to \e[96m%s\e[0m" "$newSERIAL"

elif [ "${#ar_zon[@]}" -gt "${#ar_rpz[@]}" ]; then
     printf "${_err} rpz.* files: %s exceeds from %s\n" "${#ar_zon[@]}" "${#ar_rpz[@]}"
     printf "${_hnt} please double-check number of db.* files and rpz.* files%s\n" ""
     exit 1

else
   printf "${_err} failed due to: \"FOUND %s of %s zones\". %s\n" \
      "${#ar_zon[@]}" "${#ar_rpz[@]}" "Missing zone files:"
   _miss="$(echo "${ar_rpz[@]}" "${ar_zon[@]}" | _sed "s/ /\n/g" | sort | uniq -u | tr "\n" " ")"
   printf -v miss_v "%s" "$_miss"
   printf "~ %s\n" "$miss_v"
   ar_miss+=("$miss_v")
   printf "${_inf} trying to get the missing file(s) from origin: %s\n" "$HOST"
   f_cer "${ar_miss[@]}"
fi

endTime=$(date +%s)
DIF=$((endTime - startTime))
f_sm11 "$((DIF/60))" "$((DIF%60))s"
exit 0
