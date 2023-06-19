#!/usr/bin/env bash
# TAGS
#   grab_duplic.sh v10.0
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
   ar_cat=(); ar_dmn=(); ar_tmp=(); ar_prn=()
   for B in "${!ar_CAT[@]}"; do
      ar_cat+=("${ar_CAT[B]/txt./}")
      ar_dmn+=(dmn."${ar_CAT[B]/txt./}")
      ar_tmp+=(tmp."${ar_CAT[B]/txt./}")
      ar_prn+=(prn."${ar_CAT[B]/txt./}")
   done

   printf "${_inf} FOUND %s CATEGORIES: ${_CYN}\n" "${#ar_CAT[@]}" "${ar_cat[*]}"
   printf "${_CYN} duplicate entries across CATEGORIES\n" "[PRUNE]"

   f_dpl "${ar_cat[0]}"   # remove duplicate entries based on ${ar_cat[0]}
   printf "%11s = pruning duplicates %s entries%-11sSKIP\n" "STEP 0.1" "${ar_cat[1]}" ""
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

printf "\n${_CYN} IPV4 and sub-domains if parent domain exist across CATEGORIES%-4s" "[PRUNE]"
prun_ini=$(mktemp -p "${_DIR}")   # pruning sub-domains if parent
prun_out=$(mktemp -p "${_DIR}")   #+ domain exist across CATEGORIES
_srt -s "${ar_CAT[0]}" "${ar_CAT[@]:2:5}" > "${prun_ini}"
_sed "s/^/\./" "${prun_ini}" | rev | _srt -u -s \
   | awk 'p == "" || substr($0,1,length(p)) != p { print $0; p = $0 }' \
   | rev | _sed "s/^\.//" > "${prun_out}"
f_do

# final check: invalid TLDs. if found, then creating regex to removing it's TLDs
printf "${_CYN} domains whose TLD is invalid %-36s" "[PRUNE]"
iana_tlds="https://data.iana.org/TLD/tlds-alpha-by-domain.txt"   # valid TLDs
fals_tlds=$(mktemp -p "${_DIR}")                                 # false TLDs
curl -s "${iana_tlds}" | _sed '/#/d;s/[A-Z]/\L&/g' > "${iana_tlds##*/}"
awk -F. '{print $NF}' "${prun_out}" | _srt -u -s > "${fals_tlds}"
f_awk "${iana_tlds##*/}" "${fals_tlds}" invalid_tlds

if [[ -s invalid_tlds ]]; then
   _sed -i ':a;N;$!ba;s/\n/\|/g;s/^/\/\\.\(/;s/$/\)\$\/d/' invalid_tlds
   _sed -E -i -f invalid_tlds "${prun_out}"
   f_do                           # remove all found invalid TLD's entries
else                              # no invalid tlds found
   printf "${_CYN}\n" "noFOUND"
fi

printf "${_CYN} turn-back pruned entries to proper CATEGORIES\n" "[PRUNE]"
for O in "${!ar_cat[@]}"; do
   if [[ ${O} -eq 1 ]]; then      # pruned ipv4s by turning to CIDR-block
      printf "%34s to %-19s :" "turn-back pruned ipv4-addresses" "${ar_cat[1]^^} category"
      while IFS= read -r; do
         perl -MNet::Netmask -ne 'm!(\d+\.\d+\.\d+\.\d+/?\d*)! or next;
            $h = $1; $h =~ s/(\.0)+$//; $b = Net::Netmask->new($h); $b->storeNetblock();
            END {print map {$_->base()."/".$_->bits()."\n"} cidrs2cidrs(dumpNetworkTable)}' > "${ar_prn[O]}"
      done < "${ar_CAT[O]}"
      cp "${ar_prn[O]}" "${ar_CAT[O]}"
      printf "%10s entries\n" "$(printf "%'d" "$(wc -l < "${ar_CAT[O]}")")"
   else                           # turn-back pruned domain entries to the proper category
      printf "%33s to %-20s :" "turn-back pruned domains entry" "${ar_cat[O]^^} category"
      _srt -s "${prun_out}" "${ar_CAT[O]}" | uniq -d > "${ar_prn[O]}"
      cp "${ar_prn[O]}" "${ar_CAT[O]}"
      printf "%10s entries\n" "$(printf "%'d" "$(wc -l < "${ar_CAT[O]}")")"
   fi
done

# summarize
printf "%57s : %'d entries\n" "TOTAL" "$(wc -l "${ar_CAT[@]}" | grep "total" | awk -F' ' '{print $1}')"
printf "%57s : %9s Megabytes\n" "disk-usage" "$(wc -c "${ar_CAT[@]}" | grep total | awk -F' ' '{print ($1/1024^2)}')"
T="$(($(date +%s%N)-T))"
f_tim
exit 0
