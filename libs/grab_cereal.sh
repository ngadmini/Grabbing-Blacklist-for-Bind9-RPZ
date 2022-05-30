#!/usr/bin/env bash
# TAGS
#   grab_cereal.sh
#   v6.6
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2154

startTime=$(date +%s%N)
set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

f_src() {
   readonly _LIB="$_DIR"/grab_library
   if [[ -e ${_LIB} ]]; then
      [[ -r ${_LIB} ]] || chmod 644 "${_LIB}"
      source "${_LIB}"
      f_trap                 # cleanUP on exit, interrupt & terminate
   else
      printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"
      exit 1
   fi
}

# START <main script>
f_src; f_cnf
printf "\n${_red}[3'th] TASKs:${_ncl}\nstarting %s at ${_cyn}%s${_ncl}" "${0##*/}" "${_lct}"
cd "$_DIR"; [[ ! $UID -eq 0 ]] || f_xcd 10

ar_miss=()
ar_rpz=(rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf \
   rpz.adultag rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+aa rpz.trust+ab )
mapfile -t ar_zon < <(f_fnd "rpz.*")
printf -v miss_v "%s" "$(echo "${ar_rpz[@]}" "${ar_zon[@]}" | f_sed)"

printf "\n${_inf} incrementing serial of zone-files%s"
# inspecting file consistency && update serial zones
if [[ ${#ar_zon[@]} -eq "${#ar_rpz[@]}" ]]; then
   if [[ ${ar_zon[*]} == "${ar_rpz[*]}" ]]; then
      printf "\n${_inf} FOUND:\t%s zone-files (complete)" "${#ar_zon[@]}"
      for Z in "${ar_zon[@]}"; do
         DATE=$(date +%Y%m%d)
         SERIAL=$(grep "SOA" "$Z" | cut -d \( -f2 | cut -d" " -f1)
         if [[ ${#SERIAL} -lt ${#DATE} ]]; then
            newSERIAL="${DATE}00"
         else
            SERIAL_date=${SERIAL::-2}                   # slice to [20190104]
            if [[ $DATE -eq $SERIAL_date ]]; then       # it same day
               SERIAL_num=${SERIAL: -2}                 # give [00-99] times to change
               SERIAL_num=$((10#$SERIAL_num + 1))       # force decimal increment
               newSERIAL="${DATE}$(printf "%02d" $SERIAL_num)"
            else
               newSERIAL="${DATE}00"
            fi
         fi
         _sed -i -e 's/'"$SERIAL"'/'"$newSERIAL"'/g' "$Z"
         f_g4c "$Z"
      done
      f_pms
      printf "\n${_inf} all serial zone-files incremented to ${_cyn}%s${_ncl}" "$newSERIAL"
   else
      printf "\n${_err} misMATCH file: ${_cyn}%s${_ncl}" "$miss_v"
      f_xcd 19 "${ar_zon[*]}"
   fi
elif [[ ${#ar_zon[@]} -gt ${#ar_rpz[@]} ]]; then
   printf "${_err} zone-files exceeds from %s to %s" "${#ar_rpz[@]}" "${#ar_zon[@]}"
   f_xcd 17 "$miss_v"
else
   printf "${_err} missing zone-files:\n\t%s\n" "$miss_v"
   ar_miss+=("$miss_v")
   printf "${_inf} trying to get the missing zone-files from origin: %s\n" "${HOST}"
   f_cer "${ar_miss[@]}"
fi

endTime=$(date +%s%N)
runTime=$(($((endTime - startTime))/1000000))
printf "\n${_inf} completed ${_cyn}IN %'dms${_ncl}\n" "$runTime"
exit 0
