#!/usr/bin/env bash
# TAGS
#   grab_build.sh v9.7
#   https://github.com/ngadmini
# AUTHOR
#   ngadimin@warnet-ersa.net
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
   curl -sO https://raw.githubusercontent.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/master/libs/grab_library
   response=$?
   if [[ ${response} -ne 0 ]]; then
      printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"
      exit 1
   else
      exec "$0"
   fi
fi

f_stt "[2'nd] TASKs:"
printf "${_pre} %-63s" "check availability configuration file"
f_cnf
[[ ! ${UID} -eq 0 ]] || f_xcd 247

# inspecting required files <categories> first then split txt.adult
ar_cat=(txt.adult txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
ar_spl=(txt.adultaa txt.adultab txt.adultac txt.adultad txt.adultae txt.adultaf \
   txt.adultag txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)

declare -A ar_num   # get index's position of ipv4 category "${ar_spl[7]}"
ar_num[db_ipv4]=$(echo "${ar_spl[*]}" | tr ' ' '\n' | awk '/txt\.ipv4/ {print NR-1}')
_spl=$(((($(wc -l "${ar_cat[0]}" | awk '{print $1}')/7))+1))

printf "${_inf} splitting ${_CYN} to %'d lines/sub-category:" "adult CATEGORY" "${_spl}"
mapfile -t ar_CAT < <(f_fnd "txt.*")
miss_v=$(echo "${ar_cat[@]}" "${ar_CAT[@]}" | f_sed)
if [[ ${#ar_cat[@]} -eq "${#ar_CAT[@]}" && ${ar_cat[*]} == "${ar_CAT[*]}" ]]; then
   split -l "${_spl}" "${ar_cat[0]}" "${ar_cat[0]}"
   mv txt.adult /tmp
   unset -v ar_CAT
   mapfile -t ar_txt < <(f_fnd "txt.*")
   mr_p=$(echo "${ar_txt[@]}" "${ar_spl[@]}" | f_sed)
   printf "\n${_CYN}\n" "$(f_fnd "txt.adult*" | tr '\n' ' ')"
else
   f_mis "${miss_v}" "${ar_cat[*]}"
fi

# inspecting splitted txt.adult & rebuild to rpz-format
printf "${_inf} rewriting all domains to RPZ format-entry\n"
if [[ ${#ar_txt[@]} -eq ${#ar_spl[@]} && ${ar_txt[*]} == "${ar_spl[*]}" ]]; then
   f_frm "db.*"
   ar_dom=()
   for X in "${!ar_txt[@]}"; do
      ar_dom+=("${ar_txt[X]/txt./db.}")
      if [[ ${X} -eq ${ar_num[db_ipv4]} ]]; then
         f_ip4 "${ar_dom[X]}" "${ar_txt[X]}"
      else
         f_rpz "${ar_dom[X]}" "${ar_txt[X]}"
      fi
   done
else
   f_mis "${mr_p}" "${ar_spl[*]}"
fi

# display resume
printf "%45s : %'d entries\n" "TOTAL" "$(wc -l "${ar_dom[@]}" | grep "total" | awk -F' ' '{print $1}')"
printf "%45s : %10s Megabytes\n" "disk-usage" "$(wc -c "${ar_dom[@]}" | grep total | awk -F' ' '{print ($1/1024^2)}')"
T="$(($(date +%s%N)-T))"
f_tim
exit 0
