#!/usr/bin/env bash
# TAGS
#   grab_cereal.sh
#   v6.4
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

startTime=$(date +%s%N)
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
_tsk="${_red}[3'th] TASKs:${_ncl}"

# START <main script>
printf "\n${_tsk}\nstarting %s at %s" "$(basename "$0")" "$(date)"
cd "$_DIR"
test -r "$_DIR"/grab_lib || chmod 644 "$_DIR"/grab_lib
# shellcheck source=/dev/null
source "$_DIR"/grab_lib
trap f_trap 0 1 2 3 6 15   # exit, clean tidy-up, interrupt, quit, abort and terminate
[[ ! $UID -eq 0 ]] || f_xcd 10

# predefined array as a blanko to counter part 'ar_zon' array
ar_miss=()
ar_rpz=(rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf \
      rpz.adultag rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+ )
mapfile -t ar_zon < <(f_fnd "rpz.*")

printf "\n${_inf} incrementing serial of zone-files (rpz.* files)%s\n" ""
if [[ ${#ar_zon[@]} -eq "${#ar_rpz[@]}" ]]; then
   if [[ ${ar_zon[*]} == "${ar_rpz[*]}" ]]; then
      printf "${_inf} FOUND:\t%s zone-files (complete)\n" "${#ar_zon[@]}"
      for Z in "${ar_zon[@]}"; do
         DATE=$(date +%Y%m%d)
         SERIAL=$(grep "SOA" "$Z" | cut -d \( -f2 | cut -d" " -f1)
         if [[ ${#SERIAL} -lt ${#DATE} ]]; then
            newSERIAL="${DATE}00"
         else
            SERIAL_date=${SERIAL::-2}                   # slice to [20190104]
            if [[ $DATE -eq $SERIAL_date ]]; then       # same day
               SERIAL_num=${SERIAL: -2}                 # give [00-99] times to change
               SERIAL_num=$((10#$SERIAL_num + 1))       # force decimal increment
               newSERIAL="${DATE}$(printf "%02d" $SERIAL_num)"
            else
               newSERIAL="${DATE}00"
            fi
         fi
         _sed -i -e 's/'"$SERIAL"'/'"$newSERIAL"'/g' "$Z"
         f_g4c "$Z"
      done
      f_pms
      printf "${_inf} all serial zones incremented to \e[96m%s\e[0m" "$newSERIAL"
   else
      printf "${_err} problem with file name. please check name of zone-files, it's must be:%s\n" ""
      printf "${ar_rpz[*]}%s\n" ""
      exit 1
   fi

elif [[ ${#ar_zon[@]} -gt ${#ar_rpz[@]} ]]; then
     printf "${_err} rpz.* files: %s exceeds from %s\n" "${#ar_zon[@]}" "${#ar_rpz[@]}"
     printf "${_hnt} please double-check number of zone-files%s\n" ""
     exit 1

else
   printf "${_err} failed due to: \"FOUND %s of %s zone-files\". %s\n" \
      "${#ar_zon[@]}" "${#ar_rpz[@]}" "missing zone-files:"
   _miss="$(echo "${ar_rpz[@]}" "${ar_zon[@]}" | f_sed)"
   printf -v miss_v "%s" "$_miss"
   printf "~ %s\n" "$miss_v"
   ar_miss+=("$miss_v")
   printf "${_inf} trying to get the missing zone-files from origin: %s\n" "$HOST"
   f_cer "${ar_miss[@]}"
fi

endTime=$(date +%s%N)
runTime=$(($((endTime - startTime))/1000000))
printf "\n${_inf} completed ${_cyn}IN %.2f ms${_ncl}\n" "$runTime"
exit 0
