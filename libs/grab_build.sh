#!/usr/bin/env bash
# TAGS
#   grab_build.sh
#   v7.2
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   don't change unless you know what you're doing
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2059,SC2154

T=$(date +%s%N)
umask 027; set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${_DIR}"

readonly _LIB="${_DIR}"/grab_library
if [[ -e ${_LIB} ]]; then
   if [[ $(stat -L -c "%a" "${_LIB}") != 644 ]]; then chmod 644 "${_LIB}"; fi
   source "${_LIB}"; f_trp; f_cnf
else
   printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"; exit 1
fi

f_stt "[2'nd] TASKs:"
# inspecting required files <categories> first then split txt.adult
ar_cat=(txt.adult txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
ar_spl=(txt.adultaa txt.adultab txt.adultac txt.adultad txt.adultae txt.adultaf \
   txt.adultag txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
declare -A ar_num             # numeric value
ar_num[l_adult]=749999        # the adult category will be devided into this number of lines
ar_num[db_ipv4]=7             # index's position of ipv4 category at aray: ar_(txt|split)
if echo "${ar_num[*]}" | _grp "[aA-zZ\.,]" >> /dev/null 2>&1; then f_xcd 252; fi
mapfile -t ar_CAT < <(f_fnd "txt.*")
miss_v=$(echo "${ar_cat[@]}" "${ar_CAT[@]}" | f_sed)

printf "\n${_inf} splitting ${_CYN} to %'d lines/sub-category:" "${ar_cat[0]}" "${ar_num[l_adult]}"
if [[ ${#ar_cat[@]} -eq "${#ar_CAT[@]}" && ${ar_cat[*]} == "${ar_CAT[*]}" ]]; then
   unset -v ar_CAT
   split -l "${ar_num[l_adult]}" "${ar_cat[0]}" "${ar_cat[0]}"
   mv txt.adult /tmp
   mapfile -t ar_txt < <(f_fnd "txt.*")
   mr_p=$(echo "${ar_txt[@]}" "${ar_spl[@]}" | f_sed)
   printf "\n${_CYN}\n" "$(f_fnd "txt.adult*" | tr '\n' ' ')"
else
   f_mis "${miss_v}" "${ar_cat[*]}"
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
   f_mis "${mr_p}" "${ar_spl[*]}"
fi

printf -v _ttl "%'d" "$(wc -l "${ar_dom[@]}" | grep "total" | cut -d' ' -f2)"
printf "%45s : %10s entries\n" "TOTAL" "${_ttl}"
T="$(($(date +%s%N)-T))"; f_tim
exit 0
