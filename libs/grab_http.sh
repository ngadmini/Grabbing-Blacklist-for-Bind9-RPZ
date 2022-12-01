#!/usr/bin/env bash
# TAGS
#   grab_http.sh v8.1
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2059,SC2154

T=$(date +%s%N)
umask 027; set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:${PATH}
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# <start main script>
cd "${_DIR}"; readonly _LIB="${_DIR}"/grab_library
if [[ -e ${_LIB} ]]; then                # sourcing to grab_library
   if [[ $(stat -L -c "%a" "${_LIB}") != 644 ]]; then chmod 644 "${_LIB}"; fi
   source "${_LIB}"; f_trp; clear
else
   printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"; exit 1
fi

printf "\nstarting ${0##*/} ${_ver} at ${_CYN}" "${_lct}"; f_ver
printf "\n${_pre} %-63s" "check ${0##*/} is executed by non-root privileges"
[[ ! ${UID} -eq 0 ]] || f_xcd 247; f_ok

ar_shy=(grab_build.sh grab_cereal.sh grab_duplic.sh grab_rsync.sh)
ar_shn=(grab_regex grab_urls)
ar_pac=()
declare -A ar_num              # numeric value
ar_num[ar_txt]=1               # index's position of: ipv4 category is no.1 at ar_txt
ar_num[ar_shn]=0               #                      grab_regex is no.0 at ar_shn
ar_num[ar_url]=22              # number of lines: grab_urls
ar_num[ar_reg]=4               #                  grab_regex

# requirement inspection
printf "${_pre} %-63s" "check required debian-packages in local-host: $(hostname -I)"
for C in {curl,dos2unix,faketime,libnet-netmask-perl,rsync}; do
   if ! dpkg -s "${C}" >> /dev/null 2>&1; then
      printf "\n${_err} %s %-60s" "${C}" "not installed"
      ar_pac+=("${C}")
   fi
done

if [[ ${#ar_pac[@]} -eq 0 ]]; then
   f_ok
else
   printf "\n${_CYN} do you want to install ${_CYN} (Y/n)? " "[CONFIRM]" "${ar_pac[*]}"
   read -r confirm
   case ${confirm:0:1} in
      y|Y) for _pac in "${ar_pac[@]}"; do
              printf "${_inf} installing %-62s" "${_pac}"
              sudo apt install "${_pac}" -y -qq >> /dev/null 2>&1; f_do
           done;;
        *) f_xcd 245 "${ar_pac[*]}";;
   esac
fi

# script-pack's properties inspection
printf "${_pre} %-63s" "check script-pack's properties in local-host: $(hostname -I)"
if echo "${ar_num[*]}" | _grp -E "([[:punct:]]|[[:alpha:]])" >> /dev/null 2>&1; then f_xcd 252; fi
for D in "${!ar_shy[@]}"; do
   if ! [[ -e ${ar_shy[D]} ]]; then
      f_no "${ar_shy[D]}"; f_ori "libs/${ar_shy[D]}" "${ar_shy[D]}"
   fi
   f_sta 755 "${ar_shy[D]}"
done

for E in "${!ar_shn[@]}"; do
   if ! [[ -e ${ar_shn[E]} ]]; then
      f_no "${ar_shn[E]}"; f_ori "libs/${ar_shn[E]}" "${ar_shn[E]}"
   fi
   f_sta 644 "${ar_shn[E]}"; _sed -i "/^$/d" "${ar_shn[E]}"
   if [[ ${E} -eq ${ar_num[ar_shn]} ]]; then
      mapfile -t ar_reg < "${ar_shn[E]}"
      [[ ${#ar_reg[@]} -eq ${ar_num[ar_reg]} ]] || f_xcd 249 "${ar_shn[E]}"
   else
      mapfile -t ar_url < "${ar_shn[E]}"
      [[ ${#ar_url[@]} -eq ${ar_num[ar_url]} ]] || f_xcd 248 "${ar_shn[E]}"
   fi
done
f_ok

printf "${_pre} check availability of remote-files (in %s)\n" "${ar_shn[1]}"
f_crw "${ar_shn[1]}" || :

# initialize, grabbing and processing raw-domains (CATEGORY)
f_grb

# category: TRUST+ --> ${ar_cat[5]} with 3 additional entries: ${url[1,7,21]}
# contents: gambling and [TRUST+Positif](https://trustpositif.kominfo.go.id/)
f_sm8 "${ar_cat[5]}" 3
trust=$(mktemp -p "${_DIR}"); untrust=$(mktemp -p "${_DIR}"); porn=$(mktemp -p "${_DIR}")

f_sm7 1 "${ar_sho[1]}"; f_do     # done while initializing category
f_sm7 7 "${ar_sho[7]}"; f_add "${ar_url[7]}" | _sed -e "${ar_reg[3]}" >> "${trust}"; f_do
f_sm7 21 "${ar_sho[21]}"; f_add "${ar_url[21]}" | _sed "/-ru$/d" >> "${porn}"; f_do

# identifying porn-domains to reduce adult entries and move to adult category [line: 115]
printf "%12s: %-66s" "throw" "porn domains into ${ar_cat[0]^^} CATEGORY"
_srt "${trust}" "${porn}" | uniq -d >> "${untrust}"
_grp -E "${ar_reg[2]}" "${trust}" | _srt -u >> "${untrust}"
awk 'FILENAME == ARGV[1] && FNR==NR{a[$1];next} !($1 in a)' "${untrust}" "${trust}" >> "${ar_dmn[5]}"
f_do

f_fix "${ar_cat[5]}" "${ar_dmn[5]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[5]}"
f_fip "${ar_txt[5]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: ADULT --> ${ar_cat[0]} with 3 additional entries: ${ar_url[0,6,7]}
# contents: adult and porn domains
f_sm8 "${ar_cat[0]}" 3
f_sm7 0 "${ar_sho[0]}"; f_do     # done while initializing category
f_sm7 6 "${ar_sho[6]}"; f_add "${ar_url[6]}" | _grp -v '^#' >> "${ar_dmn[0]}"; f_do
f_sm7 7 "${ar_sho[7]}"; cat "${untrust}" >> "${ar_dmn[0]}"; f_do

f_gog "${ar_dmn[0]}"
f_fix "${ar_cat[0]}" "${ar_dmn[0]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[0]}"
f_fip "${ar_txt[0]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: REDIRECTOR --> ${ar_cat[4]} with 2 additional entries: ${ar_url[4,5]}
# contents: vpn and proxy domains
f_sm8 "${ar_cat[4]}" 2           # done while initializing category
for F in {4,5}; do f_sm7 "${F}" "${ar_sho[F]}"; f_do; done
f_fix "${ar_cat[4]}" "${ar_dmn[4]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[4]}"
f_fip "${ar_txt[4]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: PUBLICITE --> ${ar_cat[3]} with 5 additional entries: ${ar_url[3,8..11]}
# contents: ad domains
f_sm8 "${ar_cat[3]}" 5
f_sm7 3 "${ar_sho[3]}";f_do      # done while initializing category
for G in {8..11}; do
   f_sm7 "${G}" "${ar_sho[G]}"; f_add "${ar_url[G]}" | _grp -v "^#" >> "${ar_dmn[3]}"; f_do
done
f_fix "${ar_cat[3]}" "${ar_dmn[3]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[3]}"
f_fip "${ar_txt[3]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: MALWARE --> ${ar_cat[2]} with 8 additional entries: ${ar_url[2,12..18]}
# contents: malware, phishing and ransomware domains
f_sm8 "${ar_cat[2]}" 8
f_sm7 2 "${ar_sho[2]}"; f_do     # done while initializing category
f_sm7 12 "${ar_sho[12]}"; f_add "${ar_url[12]}" | _grp -v "^\(#\|:\)" | cut -d' ' -f2 >> "${ar_dmn[2]}"; f_do
f_sm7 13 "${ar_sho[13]}"; f_add "${ar_url[13]}" | _sed "1,11d;/^;/d" | cut -d' ' -f1 >> "${ar_dmn[2]}"; f_do
for H in {14..18}; do
   f_sm7 "${H}" "${ar_sho[H]}"; f_add "${ar_url[H]}" | _grp -v "#" >> "${ar_dmn[2]}"; f_do
done

f_gog "${ar_dmn[2]}"
f_fix "${ar_cat[2]}" "${ar_dmn[2]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[2]}"
f_fip "${ar_txt[2]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: IPV4 --> ${ar_cat[1]} with 2 additional entries: ${ar_url[19..20]}
# contents: captured ipv4 from adult, publicite, malware and trust+
f_sm8 "${ar_cat[1]}" 2
for I in {19,20}; do             # save ipv4 as CIDR block
   f_sm7 "${I}" "${ar_sho[I]}"
   f_add "${ar_url[I]}" | _grp -v "^#" | _sed -r "/\/[0-9]\{2\}$/ ! s/$/\/32/" >> "${ar_dmn[1]}"
   f_do
done
f_sm9 "${ar_cat[1]}"; awk '!x[$0]++' "${ar_dmn[1]}" | _srt -n -t . -k1,1 -k2,2 -k3,3 -k4,4 -o "${ar_txt[1]}"; f_do
printf "%12s: %'d entries.\n" "acquired" "$(wc -l < "${ar_txt[1]}")"

# <finishing>
printf "\nprocessing raw-domains (${_CYN}) in summary:\n" "${#ar_txt[@]} CATEGORIES"
for J in "${!ar_cat[@]}"; do
   printf -v _sum "%'d" "$(wc -l < "${ar_txt[J]}")"
   printf "%12s: %9s entries\n" "${ar_cat[J]}" "${_sum}"
done
_tmb1=$(bc <<< "scale=3; $(wc -c "${ar_txt[@]}" | grep total | awk -F' ' '{print $1}')/1024^2")
printf "%12s: %'d entries\n" "TOTAL" "$(wc -l "${ar_txt[@]}" | grep "total" | awk -F' ' '{print $1}')"
printf "%12s: %9s Megabytes\n" "disk-usage" "${_tmb1/./,}"

printf "\n${_YLW} sub-domains if parent-domains present and IPV4 into CIDR blocks if any\n" "PRUNING:"
for K in "${!ar_txt[@]}"; do
   if [[ ${K} -eq ${ar_num[ar_txt]} ]]; then   # turn ipv4 sub-nets to CIDR blocks if any
      while IFS= read -r; do                   # require 'libnet-netmask-perl'
         perl -MNet::Netmask -ne 'm!(\d+\.\d+\.\d+\.\d+/?\d*)! or next;
         $h = $1; $h =~ s/(\.0)+$//; $b = Net::Netmask->new($h); $b->storeNetblock();
         END {print map {$_->base()."/".$_->bits()."\n"} cidrs2cidrs(dumpNetworkTable)}' > "${ar_tmp[K]}"
      done < "${ar_txt[K]}"
      printf -v _ip4 "%'d" "$(wc -l < "${ar_tmp[K]}")"
      printf "%12s: %9s entries\n" "${ar_cat[K]}" "${_ip4}"
   else                                        # prune sub-domains if parent domain present
      _sed 's/^/\./' "${ar_txt[K]}" | rev | _srt -u \
         | awk 'p == "" || substr($0,1,length(p)) != p { print $0; p = $0 }' \
         | rev | _sed "s/^\.//" | _srt > "${ar_tmp[K]}"
      printf -v _snp "%'d" "$(wc -l < "${ar_tmp[K]}")"
      printf "%12s: %9s entries\n" "${ar_cat[K]}" "${_snp}"
   fi
   cp "${ar_tmp[K]}" "${ar_txt[K]}"
done
_tmb2=$(bc <<< "scale=3; $(wc -c "${ar_tmp[@]}" | grep total | awk -F' ' '{print $1}')/1024^2")
printf "%12s: %'d entries\n" "TOTAL" "$(wc -l "${ar_tmp[@]}" | grep "total" | awk -F' ' '{print $1}')"
printf "%12s: %9s Megabytes\n\n" "disk-usage" "${_tmb2/./,}"
T="$(($(date +%s%N)-T))"; f_tim

# <completing> offerring OPTIONs: continued to next tasks OR stop here
f_sm6; f_cnf; f_sm0 "${HOST}"; read -r opsi
until [[ ${opsi} =~ ^[1-4]{1}$ ]]; do
   printf "please enter: ${_CYN} to continue OR ${_ccl} to quit\n" "[1|2|3|4]"
   read -r opsi
done
ar_exe=(); for L in "${!ar_shy[@]}"; do ar_exe+=("${_DIR}/${ar_shy[L]}"); done
case ${opsi} in
   1) f_sm1; "${ar_exe[2]}"; f_sma st; shift;;
   2) f_sm2
      if "${ar_exe[2]}"; then
         if "${ar_exe[0]}"; then f_sma nd; fi
      else exit 1; fi; shift;;
   3) f_sm3
      if "${ar_exe[2]}"; then
         if "${ar_exe[0]}"; then
            if "${ar_exe[1]}"; then f_sma th; fi
         else exit 1; fi
      else exit 1; fi; shift;;
   4) f_sm4
      if "${ar_exe[2]}"; then
         if "${ar_exe[0]}"; then
            if "${ar_exe[1]}"; then
               if "${ar_exe[3]}"; then f_sma th; fi
            else exit 1; fi
         else exit 1; fi
      else exit 1; fi; shift;;
   *) f_cln; exit 1;;
esac
printf "bye!\n"
exit 0
