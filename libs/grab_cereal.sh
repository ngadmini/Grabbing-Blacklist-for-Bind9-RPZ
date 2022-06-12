#!/usr/bin/env bash
# TAGS
#   grab_cereal.sh
#   v7.0
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   don't change unless you know what you're doing
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2059 disable=SC2154

T=$(date +%s%N)
set -Eeuo pipefail; shopt -s lastpipe
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${_DIR}"

readonly _LIB="${_DIR}"/grab_library
if [[ -e ${_LIB} ]]; then
   if [[ $(stat -L -c "%a" "${_LIB}") != 644 ]]; then chmod 644 "${_LIB}"; fi
   source "${_LIB}"; f_trap
else
   printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"; exit 1
fi

printf "\n${_RED}\nstarting ${0##*/} ${_ver} at ${_CYN}" "[3'th] TASKs:" "${_lct}"
[[ ! ${UID} -eq 0 ]] || f_xcd 10

# inspecting zone-files then update it's serial
ar_rpz=(rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf \
   rpz.adultag rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+ )
mapfile -t ar_zon < <(f_fnd "rpz.*")
printf -v miss_v "%s" "$(echo "${ar_rpz[@]}" "${ar_zon[@]}" | f_sed)"

printf "\n${_inf} incrementing serial of zone-files"
if [[ ${#ar_zon[@]} -eq "${#ar_rpz[@]}" ]]; then
   if [[ ${ar_zon[*]} == "${ar_rpz[*]}" ]]; then
      printf "\n${_inf} FOUND: %s zone-files (complete)" "${#ar_zon[@]}"
      for Z in "${ar_zon[@]}"; do
         DATE=$(date +%Y%m%d)
         SERIAL=$(grep "SOA" "$Z" | cut -d \( -f2 | cut -d' ' -f1)
         if [[ ${#SERIAL} -lt ${#DATE} ]]; then
            newSERIAL="${DATE}00"
         else
            SERIAL_date=${SERIAL::-2}                   # slice to [20190104]
            if [[ ${DATE} -eq ${SERIAL_date} ]]; then   # it same day
               SERIAL_num=${SERIAL: -2}                 # give [00-99] times to change
               SERIAL_num=$((10#${SERIAL_num} + 1))     # force decimal increment
               newSERIAL="${DATE}$(printf "%02d" ${SERIAL_num})"
            else
               newSERIAL="${DATE}00"
            fi
         fi
         _sed -i "s/${SERIAL}/${newSERIAL}/" "$Z"
         if [[ $(stat -L -c "%a" "$Z") != 640 ]]; then chmod 640 "$Z"; fi
         f_g4c "$Z"
      done
      printf "\n${_inf} all serial zone-files incremented to ${_CYN}\n" "${newSERIAL}"
   else
      printf "\n${_err} misMATCH file: ${_CYN}" "${miss_v}"; f_xcd 19 "${ar_rpz[*]}"
   fi
elif [[ ${#ar_zon[@]} -gt ${#ar_rpz[@]} ]]; then
   printf "\n${_err} misMATCH file: ${_CYN}" "${miss_v}"; f_xcd 19 "${ar_rpz[*]}"
else
   f_cnf
   printf "\n${_err} missing zone-files: ${_CYN}\n" "${miss_v}"
   ar_miss=(); ar_miss+=("${miss_v}")
   printf "${_inf} trying to get the missing zone-files from origin: %s\n" "${HOST}"
   f_cer "${ar_miss[@]}"
fi

T="$(($(date +%s%N)-T))"; f_time
exit 0
