#!/usr/bin/env bash
# TAGS
#   grab_build.sh
#   v6.5
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2154

startTime=$SECONDS
umask 027
set -Euo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

f_src() {
   readonly _LIB="$_DIR"/grab_lib
   if [[ -e ${_LIB} ]]; then
      [[ -r ${_LIB} ]] || chmod 644 "${_LIB}"
      source "${_LIB}"
      f_trap                 # cleanUP on exit, interrupt & terminate
   else
      printf "%s noFOUND\n" "${_LIB##*/}"
      exit
   fi
}

# START <main script>
f_src

printf "\n${_red}[2'nd] TASKs:${_ncl}\nstarting %s at %s" "${0##*/}" "$(date)"
cd "$_DIR" || exit
[[ ! $UID -eq 0 ]] || f_xcd 10

# predefined array as a blanko to counter part 'others' array
ar_cat=(txt.adult txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
# split txt.adult into sub-categories to reduce server-load when initiating rndc
ar_split=(txt.adultaa txt.adultab txt.adultac txt.adultad txt.adultae txt.adultaf \
   txt.adultag txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)

for y in ${ar_cat[*]}; do
   if ! [[ -e $y ]]; then
      mapfile -t ar_CAT < <(f_fnd "txt.*")
      printf -v miss_v "%s" "$(echo "${ar_cat[@]}" "${ar_CAT[@]}" | f_sed)"
      f_xcd 17 "$miss_v"
   fi
done

mapfile -t ar_CAT < <(f_fnd "txt.*")
if [[ ${ar_cat[*]} == "${ar_CAT[*]}" ]]; then
   unset -v ar_CAT
   printf "\n${_inf} splitting ${_cyn}%s${_ncl} to 750.000 lines/sub-category %s\n" "${ar_cat[0]}" ":"
   split -l 750000 txt.adult txt.adult
   mv txt.adult /tmp
   mapfile -t ar_txt < <(f_fnd "txt.*")
   printf "${_cyn}%s${_ncl}\n" "${ar_txt[*]:0:7}"

   if [[ ${#ar_txt[@]} -eq ${#ar_split[@]} ]]; then
      unset -v ar_cat
      ar_dom=()                                   # declare temporary files as array
      for Y in {0..11}; do
         ar_dom+=("${ar_txt[Y]/txt./db.}")
      done

      f_frm "db.*"                                # remove previously db.* if any
      printf "${_inf} rewriting all CATEGORIES to RPZ format%s\n" " "

      for X in {0..11}; do                        # build dBASE in rpz format
         if [[ $X -eq 7 ]]; then
            f_ip4 "${ar_dom[X]}" "${ar_txt[X]}"
         else
            f_rpz "${ar_dom[X]}" "${ar_txt[X]}"
         fi
      done

      printf -v ttl "%'d" "$(wc -l "${ar_dom[@]}" | grep "total" | cut -d" " -f2)"
      printf "%45s : %10s entries" "TOTAL" "$ttl"

   elif [[ ${#ar_txt[@]} -gt ${#ar_split[@]} ]]; then
      printf "${_err} database grows than expected. can produce: %s db.* files exceeds from %s\n" \
         "${#ar_txt[@]}" "${#ar_split[@]}"
      printf "${_hnt} please make adjustments on your:%s\n" ""
      printf "\t- $(basename "$0") at line %s\n" "$(grep -n "^ar_split" "$0" | cut -d':' -f1)"
      printf "\t- grab_cereal.sh at line %s\n" "$(grep -n "^ar_rpz" grab_cereal.sh | cut -d':' -f1)"
      printf "\t- zone-files [rpz.*]\n"
      printf "\t- bind9-server configurations\n"
      exit 1
   else
      _add="database shrunk than expected. can only create"
      printf "${_err} due to: %s %s of %s db.* files:\n" "$_add" \
         "${#ar_txt[@]}" "${#ar_split[@]}"
      exit 1
   fi
else
   printf "\n${_err} due to: FOUND %s domain list:\n\t%s\n" "${#ar_CAT[@]}" "${ar_CAT[*]}"
   printf "${_hnt} expected %s domains list: \n\t%s\n" "${#ar_cat[@]}" "${ar_cat[*]}"
   exit 1
fi

runTime=$((SECONDS - startTime))
f_sm11 "$((runTime/60))m" "$((runTime%60))s"
exit 0
