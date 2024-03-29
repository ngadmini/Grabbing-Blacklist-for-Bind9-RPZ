#!/usr/bin/env bash
# TAGS
#   grab_build.sh v10.4
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
f_cnf; [[ ! ${UID} -eq 0 ]] || f_xcd 247

# inspecting required files
ar_cat=(txt.adult txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
ar_spl=(txt.adultaa txt.adultab txt.adultac txt.adultad txt.adultae txt.adultaf txt.adultag
   txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+aa txt.trust+ab txt.trust+ac)

declare -A ar_num   # get index's position of ipv4 category "${ar_spl[7]}"
ar_num[db_ipv4]=$(echo "${ar_spl[*]}" | tr ' ' '\n' | awk '/txt\.ipv4/ {print NR-1}')
_spl_adult=$((($(awk 'END {print NR}' "${ar_cat[0]}")/7)+1))   # split txt.adult
_spl_trust=$((($(awk 'END {print NR}' "${ar_cat[5]}")/3)+1))   #+      txt.trust+

mapfile -t ar_CAT < <(f_fnd "txt.*")
miss_v=$(echo "${ar_cat[@]}" "${ar_CAT[@]}" | f_sed)
if [[ ${#ar_cat[@]} -eq "${#ar_CAT[@]}" && ${ar_cat[*]} == "${ar_CAT[*]}" ]]; then
   printf "${_inf} splitting ${_CYN} to %'d entries/sub-category:" "adult CATEGORY" "${_spl_adult}"
   split -l "${_spl_adult}" "${ar_cat[0]}" "${ar_cat[0]}"   # it's too big. splitting can reduce
   mv txt.adult /tmp                                        #+  load-time RNDC of bind9-server
   printf "\n${_YLW}\n" "$(f_fnd "txt.adult*" | tr '\n' ' ')"

   printf "${_inf} splitting ${_CYN} to %'d entries/sub-category:" "trust+ CATEGORY" "${_spl_trust}"
   split -l "${_spl_trust}" "${ar_cat[5]}" "${ar_cat[5]}"   # it's too big to
   mv txt.trust+ /tmp
   printf "\n${_YLW}\n" "$(f_fnd "txt.trust*" | tr '\n' ' ')"

   unset -v ar_CAT; mapfile -t ar_txt < <(f_fnd "txt.*")
   mr_p=$(echo "${ar_txt[@]}" "${ar_spl[@]}" | f_sed)
else
   f_mis "${miss_v}" "${ar_cat[*]}"
fi

# build dataBase to rpz-format
printf "${_inf} rewriting all domains to RPZ format-entry\n"
if [[ ${#ar_txt[@]} -eq ${#ar_spl[@]} && ${ar_txt[*]} == "${ar_spl[*]}" ]]; then
   f_frm "db.*";   ar_dom=()
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

# summarize
printf "%45s : %'d entries\n" "TOTAL" "$(awk -v V=$((4*"${#ar_dom[@]}")) 'END {print NR-V}' "${ar_dom[@]}")"
printf "%45s : %10s Megabytes\n" "disk-usage" "$(wc -c "${ar_dom[@]}" | tail -1 | awk -F' ' '{print ($1/1024^2)}')"
f_end
