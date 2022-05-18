#!/usr/bin/env bash
# TAGS
#   grab_build.sh
#   v6.4
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

startTime=$SECONDS
umask 027
SOURCED=false && [[ $0 = "${BASH_SOURCE[0]}" ]] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
_red="\e[91m"
_ylw="\e[93m"
_cyn="\e[96m"
_ncl="\e[0m"
_inf="${_ylw}[INFO]${_ncl}"
_err="${_red}[FAIL]${_ncl}"
_hnt="${_ylw}[HINTS]${_ncl}"
_tsk="${_red}[2'th] TASKs:${_ncl}"

# START <main script>
printf "\n${_tsk}\nstarting %s at %s" "$(basename "$0")" "$(date)"
cd "$_DIR"
test -r "$_DIR"/grab_lib || chmod 644 "$_DIR"/grab_lib
# shellcheck source=/dev/null
source "$_DIR"/grab_lib
trap f_trap 0 1 2 3 6 15   # exit, clean tidy-up, interrupt, quit, abort and terminate
[[ ! $UID -eq 0 ]] || f_xcd 10

# predefined array as a blanko to counter part 'others' array
ar_cat=(txt.adult txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
# split txt.adult into sub-categories to reduce server-load when initiating rndc
ar_split=(txt.adultaa txt.adultab txt.adultac txt.adultad txt.adultae txt.adultaf \
   txt.adultag txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)

for y in ${ar_cat[*]}; do
   if ! [[ -e $y ]]; then
      mapfile -t ar_CAT < <(f_fnd "txt.*")
      _miss="$(echo "${ar_cat[@]}" "${ar_CAT[@]}" | f_sed)"
      printf -v miss_v "%s" "$_miss"
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
      printf "${_inf} rewriting all CATEGORIES to RPZ format %s\n" ":"

      for X in {0..11}; do
         if [[ $X -eq 7 ]]; then
            f_ip4 "${ar_dom[X]}" "${ar_txt[X]}"   # policy: NS-IP Trigger NXDOMAIN Action
         else
            f_rpz "${ar_dom[X]}" "${ar_txt[X]}"   # policy: QNAME Trigger NXDOMAIN Action
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

endTime=$SECONDS
runTime=$((endTime - startTime))
f_sm11 "$((runTime/60))m" "$((runTime%60))s"
exit 0
