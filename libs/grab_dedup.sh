#!/usr/bin/env bash
# TAGS
#   grab_dedup.sh
#   v6.5
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2154

startTime=$SECONDS
set -Euo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# START <main script>
[[ -r $_DIR/grab_lib ]] || chmod 644 "$_DIR"/grab_lib
source "$_DIR"/grab_lib
f_trap                      # cleanUP on exit, interrupt & terminate

printf "\n${_ts1}\nstarting %s at %s" "${0##*/}" "$(date)"
cd "$_DIR" || exit
[[ ! $UID -eq 0 ]] || f_xcd 10

# predefined array as a blanko to counter part 'others' array
ar_cat=(txt.adult txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
for y in ${ar_cat[*]}; do
   if ! [[ -e $y ]]; then
      mapfile -t ar_txt < <(f_fnd "txt.*")
      printf -v miss_v "%s" "$(echo "${ar_cat[@]}" "${ar_txt[@]}" | f_sed)"
      f_xcd 17 "$miss_v"
   fi
done

mapfile -t ar_txt < <(f_fnd "txt.*")
if [[ ${ar_txt[*]} == "${ar_cat[*]}" ]]; then
   unset -v ar_cat
   ar_cat=()               # declare temporary files as array
   ar_dmn=()               #
   ar_tmp=()               #
   for B in {0..5}; do
      ar_cat+=("${ar_txt[B]/txt./}")
      ar_dmn+=(dmn."${ar_txt[B]/txt./}")
      ar_tmp+=(tmr."${ar_txt[B]/txt./}")
   done

   printf "\n${_inf} eliminating duplicate entries between CATEGORY%s\n" ""
   printf "${_inf} FOUND %s CATEGORIES: ${_cyn}%s${_ncl}\n" "${#ar_txt[@]}" "${ar_cat[*]}"

   f_dupl "${ar_cat[0]}"   # based on ${ar_cat[0]}
   for C in {2..5}; do
      f_ddup "$C" "${ar_cat[C]}" "${ar_txt[C]}" "${ar_txt[0]}" "${ar_tmp[C]}" 0
      awk 'FILENAME == ARGV[1] && FNR==NR{a[$1];next} !($1 in a)' "${ar_tmp[C]}" "${ar_txt[C]}" \
         | _sort > "${ar_dmn[C]}"
      cp "${ar_dmn[C]}" "${ar_txt[C]}"
      f_do
   done

   printf "eliminating duplicate entries based on ${_cyn}%s${_ncl}\t\tdo nothing\n" "${ar_cat[1]^^}"

   f_dupl "${ar_cat[2]}"   # based on ${ar_cat[2]}
   for D in {3..5}; do
      f_ddup "$D" "${ar_cat[D]}" "${ar_txt[D]}" "${ar_txt[2]}" "${ar_tmp[D]}" 2
      awk 'FILENAME == ARGV[1] && FNR==NR{a[$1];next} !($1 in a)' "${ar_tmp[D]}" "${ar_txt[D]}" \
         | _sort > "${ar_dmn[D]}"
      cp "${ar_dmn[D]}" "${ar_txt[D]}"
      f_do
   done

   f_dupl "${ar_cat[3]}"   # based on ${ar_cat[3]}
   for E in 4 5; do
      f_ddup "$E" "${ar_cat[E]}" "${ar_txt[E]}" "${ar_txt[3]}" "${ar_tmp[E]}" 3
      awk 'FILENAME == ARGV[1] && FNR==NR{a[$1];next} !($1 in a)' "${ar_tmp[E]}" "${ar_txt[E]}" \
         | _sort > "${ar_dmn[E]}"
      cp "${ar_dmn[E]}" "${ar_txt[E]}"
      f_do
   done

   f_dupl "${ar_cat[4]}"   # based on ${ar_cat[4]}
   printf "%11s = deduplicating %s entries\t\t" "STEP 4.5" "${ar_cat[5]}"
   _sort "${ar_txt[5]}" "${ar_txt[4]}" | uniq -d | _sort -u > "${ar_tmp[5]}"
   awk 'FILENAME == ARGV[1] && FNR==NR{a[$1];next} !($1 in a)' "${ar_tmp[5]}" "${ar_txt[5]}" \
      | _sort > "${ar_dmn[5]}"
   cp "${ar_dmn[5]}" "${ar_txt[5]}"
   f_do

   printf "eliminating duplicate entries based on ${_cyn}%s${_ncl}\t\tdo nothing\n" "${ar_cat[5]^^}"

else
   printf -v miss_v "%s" "$(echo "${ar_cat[@]}" "${ar_txt[@]}" | f_sed)"
   printf "\n${_err} due to: FOUND %s of %s domain list:\nNOT require: %s\n" \
      "${#ar_txt[@]}" "${#ar_cat[@]}" "$miss_v"
   printf "${_hnt} remove or move to other direcory: %s" "$miss_v"
   exit 1
fi

# display result
unset -v ar_txt
mapfile -t ar_txt < <(f_fnd "txt.*")
printf "\n${_inf} deduplicating domains (${_cyn}%s all CATEGORIES${_ncl}) in summary:\n" "${#ar_txt[@]}"
for P in {0..5}; do
   printf -v dpl "%'d" "$(wc -l < "${ar_txt[P]}")"
   printf "%12s: %9s entries\n" "${ar_cat[P]}" "$dpl"
done
printf -v dpl_ttl "%'d" "$(wc -l "${ar_txt[@]}" | grep "total" | cut -d" " -f3)"
printf "%12s: %9s entries" "TOTAL" "$dpl_ttl"

runTime=$((SECONDS - startTime))
f_sm11 "$((runTime/60))m" "$((runTime%60))s"
exit 0
