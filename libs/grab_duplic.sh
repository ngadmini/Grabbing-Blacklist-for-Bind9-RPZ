#!/usr/bin/env bash
# TAGS
#   grab_duplic.sh v9.5
#   https://github.com/ngadmini
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

T=$(date +%s%N)
set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:${PATH}
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd "${_DIR}"
readonly _LIB="${_DIR}"/grab_library
if [[ -e ${_LIB} ]]; then
   if [[ $(stat -c "%a" "${_LIB}") != 644 ]]; then chmod 644 "${_LIB}"; fi
   source "${_LIB}"
   f_trp
else
   curl -sO https://raw.githubusercontent.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/master/libs/grab_library
   response=$?
   if [[ ${response} -ne 0 ]]; then
      printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"
      exit 1
   else
      exec "$0"
   fi
fi

f_stt "[1'st] TASKs:"
[[ ! ${UID} -eq 0 ]] || f_xcd 247

# inspecting required files <categories> first
ar_cat=(txt.adult txt.ipv4 txt.malware txt.publicite txt.redirector txt.trust+)
mapfile -t ar_CAT < <(f_fnd "txt.*")
miss_v=$(echo "${ar_cat[@]}" "${ar_CAT[@]}" | f_sed)

if [[ ${#ar_CAT[@]} -eq "${#ar_cat[@]}"  &&  ${ar_CAT[*]} == "${ar_cat[*]}" ]]; then
   unset -v ar_cat
   ar_cat=()
   ar_dmn=()
   ar_tmp=()
   ar_prn=()
   for B in "${!ar_CAT[@]}"; do
      ar_cat+=("${ar_CAT[B]/txt./}")
      ar_dmn+=(dmn."${ar_CAT[B]/txt./}")
      ar_tmp+=(tmp."${ar_CAT[B]/txt./}")
      ar_prn+=(prn."${ar_CAT[B]/txt./}")
   done

   printf "${_inf} FOUND %s CATEGORIES: ${_CYN}\n" "${#ar_CAT[@]}" "${ar_cat[*]}"
   printf "${_inf} prune duplicate and sub-domains (if parent-domain exist) across CATEGORIES\n"

   f_dpl "${ar_cat[0]}"   # remove duplicate entries based on ${ar_cat[0]}
   printf "%11s = deduplicating %s entries%-16sSKIP\n" "STEP 0.1" "${ar_cat[1]}" ""
   for C in {2..5}; do
      f_dpn "${C}" "${ar_cat[C]}" "${ar_CAT[C]}" "${ar_CAT[0]}" "${ar_tmp[C]}" 0
      f_dpm "${ar_tmp[C]}" "${ar_CAT[C]}" "${ar_dmn[C]}"
   done

   # remove duplicate entries based on ${ar_cat[1]}. do nothing
   printf "pruning duplicate entries based on ${_CYN}%-17sdo nothing\n" "${ar_cat[1]^^}"

   f_dpl "${ar_cat[2]}"   # remove duplicate entries based on ${ar_cat[2]}
   for D in {3..5}; do
      f_dpn "${D}" "${ar_cat[D]}" "${ar_CAT[D]}" "${ar_CAT[2]}" "${ar_tmp[D]}" 2
      f_dpm "${ar_tmp[D]}" "${ar_CAT[D]}" "${ar_dmn[D]}"
   done

   f_dpl "${ar_cat[3]}"   # remove duplicate entries based on ${ar_cat[3]}
   for E in 4 5; do
      f_dpn "${E}" "${ar_cat[E]}" "${ar_CAT[E]}" "${ar_CAT[3]}" "${ar_tmp[E]}" 3
      f_dpm "${ar_tmp[E]}" "${ar_CAT[E]}" "${ar_dmn[E]}"
   done

   f_dpl "${ar_cat[4]}"   # remove duplicate entries based on ${ar_cat[4]}
   f_dpn 5 "${ar_cat[5]}" "${ar_CAT[5]}" "${ar_CAT[4]}" "${ar_tmp[5]}" 4
   f_dpm "${ar_tmp[5]}" "${ar_CAT[5]}" "${ar_dmn[5]}"

   # remove duplicate entries based on ${ar_cat[5]}. do nothing
   printf "pruning duplicate entries based on ${_CYN}%-15sdo nothing\n" "${ar_cat[5]^^}"
else
   f_mis "${miss_v}" "${ar_cat[*]}"
fi

printf "\n${_YLW} pruning sub-domain across CATEGORIES%-8s" "[PREPARING]"
prun_ini=$(mktemp -p "${_DIR}")
prun_out=$(mktemp -p "${_DIR}")
_srt "${ar_CAT[0]}" "${ar_CAT[@]:2:5}" > "${prun_ini}"
f_prn "${prun_ini}" "${prun_out}"
f_ok

for O in ${!ar_cat[@]}; do
   if [[ ${O} -eq 1 ]]; then
      printf "%3spruning sub-domain entries: %-25s" "" "${ar_cat[1]^^} category"
      while IFS= read -r; do
         perl -MNet::Netmask -ne 'm!(\d+\.\d+\.\d+\.\d+/?\d*)! or next;
            $h = $1; $h =~ s/(\.0)+$//; $b = Net::Netmask->new($h); $b->storeNetblock();
            END {print map {$_->base()."/".$_->bits()."\n"} cidrs2cidrs(dumpNetworkTable)}' > "${ar_prn[1]}"
      done < "${ar_CAT[1]}"
      cp "${ar_prn[1]}" "${ar_CAT[1]}"
      f_do
   else
      printf "%3spruning sub-domain entries: %-25s" "" "${ar_cat[O]^^} category"
      _srt "${prun_out}" "${ar_CAT[O]}" | uniq -d > "${ar_prn[O]}"
      cp "${ar_prn[O]}" "${ar_CAT[O]}"
      f_do
   fi
done

# display resume
printf "\n${_inf} deduplicating and pruning sub-domains in summary:\n"
for P in "${!ar_CAT[@]}"; do
   printf -v _dpl "%'d" "$(wc -l < "${ar_CAT[P]}")"
   printf "%12s: %9s entries\n" "${ar_cat[P]}" "${_dpl}"
done
_tmb=$(bc <<< "scale=3; $(wc -c "${ar_CAT[@]}" | grep total | awk -F' ' '{print $1}')/1024^2")
printf "%12s: %'d entries\n" "TOTAL" "$(wc -l "${ar_CAT[@]}" | grep "total" | awk -F' ' '{print $1}')"
printf "%12s: %9s Megabytes\n" "disk-usage" "${_tmb/./,}"
T="$(($(date +%s%N)-T))"
f_tim
exit 0
