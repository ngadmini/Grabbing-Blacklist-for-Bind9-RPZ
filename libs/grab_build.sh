#!/usr/bin/env bash
# TAGS;VERSION
#   grab_build.sh
#   v6.4
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

umask 027
SOURCED=false && [ "$0" = "${BASH_SOURCE[0]}" ] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(realpath "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")
startTime=$(date +%s)
start=$(date "+DATE: %Y-%m-%d TIME: %H:%M:%S")

cd "$_DIR"
test -r "$_DIR"/grab_lib || chmod 644 "$_DIR"/grab_lib
# shellcheck source=/dev/null
source "$_DIR"/grab_lib
trap f_trap EXIT TERM
trap 'printf "\ninterrupted\n"; f_trap; exit' INT

printf "\n\e[91m[2'nd] TASKs:\e[0m\nStarting %s ... %s" "$(basename "$0")" "$start"
[ ! "$UID" -eq 0 ] || f_xcd 10

# predefined array as a blanko to counter part 'others' array
ar_raw=(txt.adult txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
# split txt.adult into sub-categories to reduce server-load when initiating rndc
ar_split=(txt.adultaa txt.adultab txt.adultac txt.adultad txt.adultae txt.adultaf \
   txt.adultag txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)

for y in ${ar_raw[*]}; do
   if ! [ -e "$y" ]; then
      mapfile -t ar_RAW < <(find . -maxdepth 1 -type f -name "txt.*" | _sed -e "s/\.\///" | sort)
      _miss="$(echo "${ar_raw[@]}" "${ar_RAW[@]}" | _sed "s/ /\n/g" | sort | uniq -u | tr "\n" " ")"
      printf -v miss_v "%s" "$_miss"
      f_xcd 17 "$miss_v"
   fi
done

mapfile -t ar_RAW < <(find . -maxdepth 1 -type f -name "txt.*" | _sed -e "s/\.\///" | sort)
if [ "${#ar_raw[@]}" -eq "${#ar_RAW[@]}" ]; then
   unset -v ar_RAW
   printf "\n\e[93m[INFO]\e[0m Splitting adult category to 750.000 lines/sub-category\n"
   split -l 750000 txt.adult txt.adult
   mv txt.adult /tmp
   mapfile -t ar_txt < <(find . -maxdepth 1 -type f -name "txt.*" | _sed -e "s/\.\///" | sort)

   if [ "${#ar_txt[@]}" -eq "${#ar_split[@]}" ]; then
      ar_cat=()   # declare temporary files as array
      ar_dom=()   #
      for Y in {0..11}; do
         ar_cat+=("${ar_txt[Y]/txt./}")
         ar_dom+=("${ar_txt[Y]/txt./db.}")
      done

      find . -maxdepth 1 -type f -name "db.*" -print0 | xargs -0 -r rm
      printf "\e[93m[INFO]\e[0m Rewriting all domain lists to RPZ format :\n\e[36m%s\e[0m\n" "${ar_cat[*]}"

      for X in {0..11}; do
         if [ "$X" -eq 7 ]; then
            # policy: NS-IP Trigger NXDOMAIN Action
            f_ip4 "${ar_dom[X]}" "${ar_txt[X]}" "${ar_cat[X]}"
         else
            # policy: QNAME Trigger NXDOMAIN Action
            f_rpz "${ar_dom[X]}" "${ar_txt[X]}" "${ar_cat[X]}"
         fi
      done

      printf -v ttl "%'d" "$(wc -l "${ar_dom[@]}" | grep "total" | cut -d" " -f2)"
      printf "%41s : %10s entries\n" "TOTAL" "$ttl"

   elif [ "${#ar_txt[@]}" -gt "${#ar_split[@]}" ]; then
      printf "\e[91m[ERROR]\e[0m database growth, can produce db.* files: %s exceeds from %s\n" \
         "${#ar_txt[@]}" "${#ar_split[@]}"
      printf "\e[93m[HINTS]\e[0m please make adjustments to your rpz.* files and your bind9-server config\n"
      exit 1
   else
      _add="database shrunk than expected. can only create"
      printf "\e[91m[ERROR]\e[0m due to: %s %s of %s db.* files:\n" "$_add" \
         "${#ar_txt[@]}" "${#ar_split[@]}"
      exit 1
   fi
else
   printf "\n\e[91m[ERROR]\e[0m due to: FOUND %s domain list:\n\t%s\n" "${#ar_RAW[@]}" "${ar_RAW[*]}"
   printf "\e[93m[HINTS]\e[0m expected %s domains list: \n\t%s\n" "${#ar_raw[@]}" "${ar_raw[*]}"
   exit 1
fi

endTime=$(date +%s)
DIF=$((endTime - startTime))
printf "\e[93m[INFO]\e[0m Completed \e[36mIN %s:%s\e[0m\n" "$((DIF/60))" "$((DIF%60))s"
exit 0
