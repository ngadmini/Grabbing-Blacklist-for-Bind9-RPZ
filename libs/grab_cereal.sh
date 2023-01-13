#!/usr/bin/env bash
# TAGS
#   grab_cereal.sh v8.9
# AUTHOR
#   ngadimin@warnet-ersa.net
#   https://github.com/ngadmini
# TL;DR
#   see README and LICENSE

T=$(date +%s%N)
umask 027
set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:${PATH}
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd "${_DIR}"
readonly _LIB="${_DIR}"/grab_library
if [[ -e ${_LIB} ]]; then
   if [[ $(stat -c "%a" "${_LIB}") != 644 ]]; then chmod 644 "${_LIB}"; fi
   source "${_LIB}"
   f_trp
else
   curl -sfO https://raw.githubusercontent.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/master/libs/grab_library
   response=$?
   if [[ ${response} -ne 0 ]]; then
      printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"
      exit 1
   else
      exec "$0"
   fi
fi

f_stt "[3'th] TASKs:"
[[ ! ${UID} -eq 0 ]] || f_xcd 247

# inspecting zone-files then update it's serial
ar_rpz=(rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf \
   rpz.adultag rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+)
mapfile -t ar_zon < <(f_fnd "rpz.*")
miss_v=$(echo "${ar_rpz[@]}" "${ar_zon[@]}" | f_sed)
printf -v mr_p "%s\n%s" "${ar_rpz[*]:0:6}" "${ar_rpz[*]:6:6}"

printf "${_inf} check availability zone-files: "
if [[ ${#ar_zon[@]} -eq "${#ar_rpz[@]}" ]]; then
   if [[ ${ar_zon[*]} == "${ar_rpz[*]}" ]]; then
      printf "FOUND %s zone-files (complete)" "${#ar_zon[@]}"
      printf "\n${_inf} incrementing serial of zone-files:\n${_CYN}" "${mr_p}"
      for Z in "${ar_zon[@]}"; do
         DATE=$(date +%Y%m%d)
         SERIAL=$(grep "SOA" "${Z}" | cut -d \( -f2 | cut -d' ' -f1)
         if [[ ${#SERIAL} -lt ${#DATE} ]]; then
            newSERIAL="${DATE}00"
         else
            SERIAL_date=${SERIAL::-2}                   # slice to [20190104]
            if [[ ${DATE} -eq ${SERIAL_date} ]]; then   # it same day
               SERIAL_num=${SERIAL: -2}                 # give {00..99} times to change
               SERIAL_num=$((10#${SERIAL_num} + 1))     # force decimal increment
               newSERIAL="${DATE}$(printf "%02d" "${SERIAL_num}")"
            else
               newSERIAL="${DATE}00"
            fi
         fi
         _sed -i "s/${SERIAL}/${newSERIAL}/" "${Z}"
         f_sta 640 "${Z}"
         f_g4c "${Z}"
      done
      printf "\n${_inf} all serial zone-files incremented to ${_CYN}\n" "${newSERIAL}"
   else
      f_mis "${miss_v}" "${mr_p}"
   fi
elif [[ ${#ar_zon[@]} -gt ${#ar_rpz[@]} ]]; then
   f_mis "${miss_v}" "${mr_p}"
else
   f_no "${miss_v}"
   f_cnf
   printf "${_inf} trying to get the missing zone-files from origin: %s\n" "${HOST}"
   f_cer "${miss_v}"
fi

T="$(($(date +%s%N)-T))"
f_tim
exit 0
