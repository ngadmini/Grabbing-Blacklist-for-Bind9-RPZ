#!/usr/bin/env bash
# TAGS
#   grab_build.sh
#   v7.1
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   don't change unless you know what you're doing
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2059 disable=SC2154

T=$(date +%s%N)
umask 027; set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${_DIR}"

readonly _LIB="${_DIR}"/grab_library
if [[ -e ${_LIB} ]]; then
   if [[ $(stat -L -c "%a" "${_LIB}") != 644 ]]; then chmod 644 "${_LIB}"; fi
   source "${_LIB}"; f_trap; f_cnf
else
   printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"; exit 1
fi

printf "\n${_RED}\nstarting ${0##*/} ${_ver} at ${_CYN}\n" "[2'nd] TASKs:" "${_lct}"
[[ ! ${UID} -eq 0 ]] || f_xcd 247

# inspecting required files <categories> first then split txt.adult
ar_cat=(txt.adult txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
ar_spl=(txt.adultaa txt.adultab txt.adultac txt.adultad txt.adultae txt.adultaf \
   txt.adultag txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
declare -A ar_num
ar_num[l_adult]=749999        # the adult category will be devided into this number of lines
ar_num[db_ipv4]=7             # index's position of ipv4 category at aray: ar_(txt|split)
if echo "${ar_num[*]}" | grep "[\.,]" >> /dev/null 2>&1; then f_xcd 252; fi
mapfile -t ar_CAT < <(f_fnd "txt.*")
printf -v miss_v "%s" "$(echo "${ar_cat[@]}" "${ar_CAT[@]}" | f_sed)"

printf "${_inf} splitting ${_CYN} to %'d lines/sub-category:\n" "${ar_cat[0]}" "${ar_num[l_adult]}"
if [[ ${#ar_cat[@]} -eq "${#ar_CAT[@]}" && ${ar_cat[*]} == "${ar_CAT[*]}" ]]; then
   unset -v ar_CAT
   split -l "${ar_num[l_adult]}" "${ar_cat[0]}" "${ar_cat[0]}"
   mv txt.adult /tmp
   mapfile -t ar_txt < <(f_fnd "txt.*")
   printf -v mr_p "%s" "$(echo "${ar_txt[@]}" "${ar_spl[@]}" | f_sed)"
   printf "${_CYN}\n" "$(f_fnd "txt.adult*" | tr '\n' ' ')"
else
   printf "${_err} misMATCH file: ${_CYN}" "${miss_v}"; f_xcd 255 "${ar_cat[*]}"
fi

# inspecting splitted txt.adult & rebuild to rpz-format
printf "${_inf} rewriting all CATEGORIES to RPZ format\n"
if [[ ${#ar_txt[@]} -eq ${#ar_spl[@]} && ${ar_txt[*]} == "${ar_spl[*]}" ]]; then
   f_frm "db.*"; ar_dom=()
   for X in "${!ar_txt[@]}"; do
      ar_dom+=("${ar_txt[X]/txt./db.}")
      if [[ $X -eq ${ar_num[db_ipv4]} ]]; then
         f_ip4 "${ar_dom[X]}" "${ar_txt[X]}"
      else
         f_rpz "${ar_dom[X]}" "${ar_txt[X]}"
      fi
   done
else
   printf "${_err} misMATCH file: ${_CYN}" "${mr_p}"; f_xcd 255 "${ar_spl[*]}"
fi

printf -v ttl "%'d" "$(wc -l "${ar_dom[@]}" | grep "total" | cut -d' ' -f2)"
printf "%45s : %10s entries\n" "TOTAL" "${ttl}"
T="$(($(date +%s%N)-T))"; f_time
exit 0
