#!/usr/bin/env bash
# TAGS
#   grab_build.sh
#   v6.8
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   don't change unless you know what you're doing
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2154 disable=SC2059

startTime=$SECONDS
umask 027
set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

declare -A ar_num
ar_num[l_adult]=749999        # the adult category will be divided into this number of lines
ar_num[db_ipv4]=7             # index's position of ipv4 category at aray: ar_(txt|split)
ar_cat=(txt.adult txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
ar_spl=(txt.adultaa txt.adultab txt.adultac txt.adultad txt.adultae txt.adultaf \
   txt.adultag txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)

f_src() {   # source, cleanUP on exit, interrupt & terminate
   readonly _LIB="${_DIR}"/grab_library
   if [[ -e ${_LIB} ]]; then
      [[ -r ${_LIB} ]] || chmod 644 "${_LIB}"
      source "${_LIB}"; f_trap
   else
      printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"; exit 1
   fi
}

# <main script>
f_src; f_cnf
printf "\n${_RED}\nstarting ${0##*/} (${_ver}) at ${_CYN}\n" "[2'nd] TASKs:" "${_lct}"
cd "${_DIR}"; [[ ! $UID -eq 0 ]] || f_xcd 10
if echo "${ar_num[*]}" | grep "[\.,]" >> /dev/null 2>&1; then f_xcd 15; fi
mapfile -t ar_CAT < <(f_fnd "txt.*")
printf -v miss_v "%s" "$(echo "${ar_cat[@]}" "${ar_CAT[@]}" | f_sed)"

if [[ ${#ar_cat[@]} -eq "${#ar_CAT[@]}" ]]; then      # inspecting required files
   if [[ ${ar_cat[*]} == "${ar_CAT[*]}" ]]; then      # split txt.adult
      unset -v ar_CAT
      printf "${_inf} splitting ${_CYN} to %'d lines/sub-category:\n" "${ar_cat[0]}" "${ar_num[l_adult]}"
      split -l "${ar_num[l_adult]}" "${ar_cat[0]}" "${ar_cat[0]}"
      mv txt.adult /tmp
      mapfile -t ar_txt < <(f_fnd "txt.*")
      printf -v mr_p "%s" "$(echo "${ar_spl[@]}" "${ar_txt[@]}" | f_sed)"
      printf "${_CYN}\n" "$(f_fnd "txt.adult*" | tr '\n' ' ')"
   else
      printf "${_err} misMATCH file: ${_CYN}" "$miss_v"
      f_xcd 19 "${ar_cat[*]}"
   fi
elif [[ ${#ar_CAT[@]} -gt ${#ar_cat[@]} ]]; then
   printf "${_err} misMATCH category: ${_CYN}" "$miss_v"
   f_xcd 19 "${ar_cat[*]}"
else
   printf "${_err} missing file(s): ${_CYN}" "$miss_v"
   f_xcd 19 "${ar_cat[*]}"
fi

if [[ ${#ar_txt[@]} -eq ${#ar_spl[@]} ]]; then
   f_frm "db.*"
   ar_dom=()
   for Y in "${!ar_txt[@]}"; do
      ar_dom+=("${ar_txt[Y]/txt./db.}")
   done

   printf "${_inf} rewriting all CATEGORIES to RPZ format\n"
   for X in "${!ar_txt[@]}"; do      # rebuild to rpz-format
      if [[ $X -eq ${ar_num[db_ipv4]} ]]; then
         f_ip4 "${ar_dom[X]}" "${ar_txt[X]}"
      else
         f_rpz "${ar_dom[X]}" "${ar_txt[X]}"
      fi
   done

   printf -v ttl "%'d" "$(wc -l "${ar_dom[@]}" | grep "total" | cut -d' ' -f2)"
   printf "%45s : %10s entries" "TOTAL" "${ttl}"

elif [[ ${#ar_txt[@]} -gt ${#ar_spl[@]} ]]; then
   _add='raw-domains increasing than before'
   printf "${_err} %s. exceeds from %s files to %s files\n" "${_add}" "${#ar_spl[@]}" "${#ar_txt[@]}"
   printf "${_hnt} please make adjustments on your:\n"
   printf "\t- ${0##*/} at line %'d\n" "$(grep -n "^ar_spl" "${0##*/}" | cut -d: -f1)"
   printf "\t- grab_cereal.sh at line %'d\n" "$(grep -n "^ar_rpz" grab_cereal.sh | cut -d: -f1)"
   printf "\t- zone-files [rpz.*]\n\t- bind9-server configurations\n"
   exit 1

else
   printf "${_inf} raw-domains decreasing than before\n"
   printf "${_hnt} modify or remove misMATCH file(s) from: ${0##*/} at line %'d" \
      "$(grep -n "^ar_spl" "${0##*/}" | cut -d: -f1)"
   f_xcd 17 "$mr_p"
fi

runTime=$((SECONDS - startTime))
f_sm11 "$((runTime/60))m" "$((runTime%60))s"
exit 0
