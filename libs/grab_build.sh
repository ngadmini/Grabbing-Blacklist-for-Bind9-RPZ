#!/usr/bin/env bash
# TAGS
#   grab_build.sh
#   v6.6
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2154

startTime=$SECONDS
umask 027
set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

declare -A index             # # don't change unless you know what you're doing
index[l_adult]=749999        # the adult category will be divided into this number of lines
index[l_trust]=399999        # trust+
index[db_ipv4]=7             # index's position ipv4 at at aray: ar_(txt|split)

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
printf "\n${_red}[2'nd] TASKs:${_ncl}\nstarting %s at ${_cyn}%s${_ncl}\n" "${0##*/}" "${_lct}"
cd "$_DIR"; [[ ! $UID -eq 0 ]] || f_xcd 10
if echo "${index[*]}" | grep "[\.,]" >> /dev/null 2>&1; then f_xcd 15; fi

ar_cat=(txt.adult txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
ar_split=(txt.adultaa txt.adultab txt.adultac txt.adultad txt.adultae txt.adultaf \
   txt.adultag txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+aa txt.trust+ab)
mapfile -t ar_CAT < <(f_fnd "txt.*")
printf -v miss_v "%s" "$(echo "${ar_cat[@]}" "${ar_CAT[@]}" | f_sed)"

if [[ ${#ar_cat[@]} -eq "${#ar_CAT[@]}" ]]; then
   if [[ ${ar_cat[*]} == "${ar_CAT[*]}" ]]; then        # inspecting required files
      unset -v ar_CAT                                   # split txt.adult & txt.trust+
      printf "${_inf} splitting ${_cyn}%s${_ncl} to %'d lines/sub-category:\n" "${ar_cat[0]}" "${index[l_adult]}"
      split -l "${index[l_adult]}" "${ar_cat[0]}" "${ar_cat[0]}"
      split -l "${index[l_trust]}" "${ar_cat[5]}" "${ar_cat[5]}"
      mv txt.{adult,trust+} /tmp
      mapfile -t ar_txt < <(f_fnd "txt.*")
      printf -v mr_p "%s" "$(echo "${ar_split[@]}" "${ar_txt[@]}" | f_sed)"
      printf "${_cyn}%s${_ncl}\n" "$(f_fnd "txt.adult*" | tr '\n' ' ')"
      printf "${_inf} splitting ${_cyn}%s${_ncl} to %'d lines/sub-category:\n" "${ar_cat[5]}" "${index[l_trust]}"
      printf "${_cyn}%s${_ncl}\n" "$(f_fnd "txt.trust*" | tr '\n' ' ')"
   else
      printf "${_err} misMATCH file: ${_cyn}%s${_ncl}" "$miss_v"
      f_xcd 19 "${ar_cat[*]}"
   fi
elif [[ ${#ar_CAT[@]} -gt ${#ar_cat[@]} ]]; then
   printf "${_err} misMATCH category: ${_cyn}%s${_ncl}" "$miss_v"
   f_xcd 19 "${ar_cat[*]}"
else
   printf "${_err} missing file(s): ${_cyn}%s${_ncl}" "$miss_v"
   f_xcd 19 "${ar_cat[*]}"
fi

if [[ ${#ar_txt[@]} -eq ${#ar_split[@]} ]]; then        # rebuild to rpz-format
   f_frm "db.*"
   ar_dom=()
   for Y in "${!ar_txt[@]}"; do
      ar_dom+=("${ar_txt[Y]/txt./db.}")
   done

   printf "${_inf} rewriting all CATEGORIES to RPZ format%s\n"
   for X in "${!ar_txt[@]}"; do
      if [[ $X -eq ${index[db_ipv4]} ]]; then
         f_ip4 "${ar_dom[X]}" "${ar_txt[X]}"
      else
         f_rpz "${ar_dom[X]}" "${ar_txt[X]}"
      fi
   done

   printf -v ttl "%'d" "$(wc -l "${ar_dom[@]}" | grep "total" | cut -d' ' -f2)"
   printf "%45s : %10s entries" "TOTAL" "${ttl}"

elif [[ ${#ar_txt[@]} -gt ${#ar_split[@]} ]]; then
   _add='database increasing than before'
   printf "${_err} %s. exceeds from %s files to %s files\n" "$_add" "${#ar_split[@]}" "${#ar_txt[@]}"
   printf "${_hnt} please make adjustments on your:%s\n"
   printf "\t- ${0##*/} at line %'d\n" "$(grep -n "^ar_split" "${0##*/}" | cut -d: -f1)"
   printf "\t- grab_cereal.sh at line %'d\n" "$(grep -n "^ar_rpz" grab_cereal.sh | cut -d: -f1)"
   printf "\t- zone-files [rpz.*]\n"
   printf "\t- bind9-server configurations\n"
   exit 1

else
   printf "${_inf} data base decreasing than before%s\n"
   printf "${_hnt} modify or remove misMATCH file(s) from: ${0##*/} at line %'d" \
      "$(grep -n "^ar_split" "${0##*/}" | cut -d: -f1)"
   f_xcd 17 "$mr_p"
fi

runTime=$((SECONDS - startTime))
f_sm11 "$((runTime/60))m" "$((runTime%60))s"
exit 0
