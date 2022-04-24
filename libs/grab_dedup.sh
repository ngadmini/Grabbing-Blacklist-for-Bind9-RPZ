#!/usr/bin/env bash
# TAGS
#   grab_dedup.sh
#   v6.2
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

umask 027
set -Eeu
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
startTime=$(date +%s)
start=$(date "+DATE: %Y-%m-%d TIME: %H:%M:%S")
trap f_trap 0 2 3 15      # cleanUP on exit, interrupt, quit & terminate
export LC_NUMERIC=id_ID.UTF-8
# shellcheck source=/dev/null
source "$_DIR"/grab_lib.sh

[ ! "$UID" -eq 0 ] || f_xcd 10; cd "$_DIR";
printf "\n\x1b[91m[1'st] TASKs:\x1b[0m\nStarting %s ... %s" "$(basename "$0")" "$start"

# these array is predefined and as a blanko.
ar_raw=(txt.adult txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
for y in ${ar_raw[*]}; do
   if ! [ -f "$y" ]; then
      mapfile -t ar_txt < <(find . -maxdepth 1 -type f -name "txt.*" | sed -e "s/\.\///" | sort)
      printf -v miss_v "%s" "$(echo "${ar_raw[@]}" "${ar_txt[@]}" | sed "s/ /\n/g" | sort | uniq -u | tr "\n" " ")"
      f_xcd 17 "$miss_v"
   fi
done

mapfile -t ar_txt < <(find . -maxdepth 1 -type f -name "txt.*" | sed -e "s/\.\///" | sort)
if [ "${#ar_txt[@]}" -eq "${#ar_raw[@]}" ]; then
   # declare tmp files as array
   ar_cat=(); ar_dmn=(); ar_tmp=()
   for B in {0..5}; do
      ar_cat+=("${ar_txt[B]/txt./}"); ar_dmn+=(dmn."${ar_txt[B]/txt./}"); ar_tmp+=(tmr."${ar_txt[B]/txt./}")
   done

   printf "\n[INFO] Eliminating duplicate entries between domain lists\n"
   printf "[INFO] FOUND %s domain lists: \x1b[93m%s\x1b[0m\n" "${#ar_txt[@]}" "${ar_cat[*]}"

   f_dupl "${ar_cat[0]}"   # based on ${ar_cat[0]}
   for C in {2..5}; do
      f_ddup "$C" "${ar_cat[C]}" "${ar_txt[C]}" "${ar_txt[0]}" "${ar_tmp[C]}" 1
      awk 'FILENAME == ARGV[1] && FNR==NR{a[$1];next} !($1 in a)' "${ar_tmp[C]}" "${ar_txt[C]}" \
         | _sort > "${ar_dmn[C]}"
      cp "${ar_dmn[C]}" "${ar_txt[C]}"
      f_do
   done

   # based on ${ar_cat[1]}
   printf "eliminating duplicate entries based on \x1b[93m%s\x1b[0m\t\tdo nothing\n" "${ar_cat[1]^^}"

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

   # based on ${ar_cat[5]}
   printf "eliminating duplicate entries based on \x1b[93m%s\x1b[0m\t\tdo nothing\n" "${ar_cat[5]^^}"
else
   printf -v miss_v "%s" "$(echo "${ar_raw[@]}" "${ar_txt[@]}" | sed "s/ /\n/g" | sort | uniq -u | tr "\n" " ")"
   printf "\n\x1b[91m[ERROR]\x1b[0m due to: FOUND %s of %s domain list:\nNOT require: %s\n" \
      "${#ar_txt[@]}" "${#ar_raw[@]}" "$miss_v"
   printf "[HINTS] remove or move to other direcory: %s" "$miss_v"
   exit 1
fi

# display result
endTime=$(date +%s); DIF=$((endTime - startTime)); unset -v ar_txt
mapfile -t ar_txt < <(find . -maxdepth 1 -type f -name "txt.*" | sed -e "s/\.\///" | sort)
printf "\ndeduplicating domain lists (\x1b[93m%s CATEGORIES\x1b[0m) in summary:\n" "${#ar_txt[@]}"
for P in {0..5}; do
   printf -v dpl "%'d" "$(wc -l < "${ar_txt[P]}")"
   printf "%12s: %9s entries\n" "${ar_cat[P]}" "$dpl"
done
printf -v dpl_ttl "%'d" "$(wc -l "${ar_txt[@]}" | grep "total" | cut -d" " -f3)"
printf "%12s: %9s entries\n" "TOTAL" "$dpl_ttl"
printf "[INFO] Completed \x1b[93mIN %s:%s\x1b[0m\n" "$((DIF/60))" "$((DIF%60))s"
exit 0
