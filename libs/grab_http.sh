#!/usr/bin/env bash
# TAGS
#   grab_http.sh v10.0
#   https://github.com/ngadmini
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

T=$(date +%s%N)
umask 027
set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:${PATH}
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# sourcing to grab_library
clear
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

# starting main script
f_stt ""
printf "${_pre} %-63s" "check availability configuration file"
f_cnf
printf "${_pre} %-63s" "check ${0##*/} is executed by non-root privileges"
[[ ! ${UID} -eq 0 ]] || f_xcd 247
f_ok

ar_shy=(grab_build.sh grab_cereal.sh grab_duplic.sh grab_rsync.sh)
ar_shn=(grab_regex grab_urls)
ar_pkg=()
ar_exe=()
declare -A ar_num              # numeric value index's position of: grab_regex is no.0 at ar_shn
ar_num[ar_shn]=$(echo "${ar_shn[*]}" | tr ' ' '\n' | awk '/grab_regex/ {print NR-1}')

printf "${_pre} %-63s" "check required debian-packages in local-host: $(hostname -I)"
for C in {curl,dos2unix,faketime,libnet-netmask-perl,rsync}; do
   if ! dpkg -s "${C}" >> /dev/null 2>&1; then
      printf "\n${_err} %s %-60s" "${C}" "not installed"
      ar_pkg+=("${C}")
   fi
done

if [[ ${#ar_pkg[@]} -eq 0 ]]; then
   f_ok
else
   printf "\n${_CYN} do you want to install ${_CYN} (Y/n)? " "[CONFIRM]" "${ar_pkg[*]}"
   read -r confirm
   case ${confirm:0:1} in
      y|Y|"") for _pkg in "${ar_pkg[@]}"; do
                 printf "${_inf} installing %-62s" "${_pkg}"
                 sudo apt install "${_pkg}" -y -qq >> /dev/null 2>&1
                 f_do
              done;;
           *) f_xcd 245 "${ar_pkg[*]}";;
   esac
fi

#check the actual longest of TLDs
printf "${_pre} %-63s" "check the actual longest of Top Level Domains"
_act=$(curl -s "${_tld}" | _sed '/#/d;s/[A-Z]/\L&/g' | awk '{print length}' | _srt -g | tail -1)
_reg=$(head -1 "${ar_shn[0]}" | awk -F'|' '{print $10}')
_cur=$(echo "${_reg}" | cut -d\{ -f2 | cut -d, -f1)
_neo=$(("$_act"+1))

if [[ "${_neo}" != "${_cur}" ]]; then
   printf "${_YLW}\nchanging '%s' TO '([a0-z9\-]){%d,}' in ${ar_shn[0]} line: 1\n" "CHANGE occurs" "${_reg}" "${_neo}"
   _sed -i "s/$_cur,/$_neo,/" "${ar_shn[0]}"
else
   f_ok
fi

# check script-pack's properties
printf "${_pre} %-63s" "check script-pack's property in local-host: $(hostname -I)"
for D in "${!ar_shy[@]}"; do f_pkg "${ar_shy[D]}" 755; done
for E in "${!ar_shn[@]}"; do
   f_pkg "${ar_shn[E]}" 644
   _sed -i "/^$/d" "${ar_shn[E]}"
   if [[ ${E} -eq ${ar_num[ar_shn]} ]]; then
      mapfile -t ar_reg < "${ar_shn[E]}"
      [[ ${#ar_reg[@]} -eq ${REGEX} ]] || f_xcd 249 "${ar_shn[E]}"
   else
      mapfile -t ar_url < "${ar_shn[E]}"
      [[ ${#ar_url[@]} -eq ${URLS} ]] || f_xcd 248 "${ar_shn[E]}"
   fi
done
f_ok

# initialize CATEGORY, many categories are obtained but the main one is adult
printf "${_pre} check availability of sources-urls (as listed in %s)\n" "${ar_shn[1]}"
f_uri "${ar_shn[1]}" || :             # check availability of sources-urls
printf "\n${_ylw}PERFORMING TASKs:${_ncl} initiating CATEGORY of domains\n"
f_tmp                                 # remove stale dir & files if any
for A in {0..5}; do                   # grab blacklist from dsi.ut-capitole.fr
   tar_dsi=$(basename "${ar_url[A]}") #+ and use as initialize categories
   ext_dsi="${tar_dsi/.tar.gz/}"
   find . -maxdepth 1 -type d -o -type f -name "${ext_dsi}" -print0 | xargs -0 -r rm -rf
   printf "%12s: %-66s" "${ext_dsi^^}" "${ar_uri[A]}"
   curl -sO "${ar_url[A]}" || f_xcd 251 "${ar_url[A]}"
   tar -xzf "${tar_dsi}"
   f_do
done

mkdir ipv4                            # make some adjusment to initializing categories
mv phishing malware
mv gambling trust+
cat vpn/domains >> redirector/domains
rm -rf vpn

mapfile -t ar_cat < <(f_cat)          # initializing category
printf "%12s: ${_CYN}\n" "initiating" "${ar_cat[*]} (${#ar_cat[@]} CATEGORIES)"
f_frm "txt.*"                         # remove stale domain lists if any
ar_dmn=()                             # use it's as raw-domains container
ar_txt=()                             #+            processed-domains container

for B in "${!ar_cat[@]}"; do
   ar_dmn+=("${ar_cat[B]}"/domains)
   ar_txt+=(txt."${ar_cat[B]}")
done

# category: TRUST+
# contents: gambling domains and [TRUST+Positif](https://trustpositif.kominfo.go.id/)
#+          ${ar_cat[5]} with 2 additional entries: ${ar_url[1,7]}
f_sm7 "${ar_cat[5]}" 2
trust=$(mktemp -p "${_DIR}")
untrust=$(mktemp -p "${_DIR}")
porn=$(mktemp -p "${_DIR}")
f_sm6 1 "${ar_uri[1]}"; f_do     # add gambling-domains to trust+ category
f_sm6 7 "${ar_uri[7]}"; f_add "${ar_url[7]}" > "${trust}"; f_do   # frequently error-code curl: (35)
#cp ~/Downloads/domains_isp "${trust}"; f_do                      #+  & firefox: PR_CONNECT_RESET_ERROR
printf "%12s: %-66s" "reducing" "porn domains and move it's to ${ar_cat[0]^^} CATEGORY"
f_add "${ar_url[18]}" > "${porn}"                       # use it's as a control to reducing
_srt -us "${trust}" -o "${trust}"                       #+  adult-domains as listed in "${trust}"
_srt -s "${trust}" "${porn}" | uniq -d > "${untrust}"   #+  then move adult-domains to
_grp -E "${ar_reg[1]}" "${trust}" >> "${untrust}"       #+  adult category "${ar_dmn[0]}"
f_awk "${untrust}" "${trust}" "${ar_dmn[5]}"   # reducing adult entries by moving it's
cat "${untrust}" >> "${ar_dmn[0]}"             #+ to adult category
f_do
# fixing false-bad entries
f_fix "${ar_cat[5]}" "${ar_dmn[5]}" "${ar_txt[5]}"; f_do
f_fip "${ar_txt[5]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: ADULT
# contents: adult-porn domains
#+          ${ar_cat[0]} with 2 additional entries: ${ar_url[0,6]} and some from the trust+ category
f_sm7 "${ar_cat[0]}" 2
f_sm6 0 "${ar_uri[0]}"; f_do     # done while initializing category
f_sm6 6 "${ar_uri[6]}"; f_add "${ar_url[6]}" | _grp -v '^#' >> "${ar_dmn[0]}"; f_do
# fixing false-bad entries
f_fix "${ar_cat[0]}" "${ar_dmn[0]}" "${ar_txt[0]}"
f_out "${ar_txt[0]}" "${ar_txt[5]}"
f_fip "${ar_txt[0]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: REDIRECTOR
# contents: vpn and proxy domains
#+          ${ar_cat[4]} with 2 additional entries: ${ar_url[4,5]}
f_sm7 "${ar_cat[4]}" 2           # done while initializing category
for F in {4,5}; do f_sm6 "${F}" "${ar_uri[F]}"; f_do; done
# fixing false-bad entries
f_fix "${ar_cat[4]}" "${ar_dmn[4]}" "${ar_txt[4]}"
f_out "${ar_txt[4]}" "${ar_txt[5]}"
f_fip "${ar_txt[4]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: PUBLICITE
# contents: adv domains
#+          ${ar_cat[3]} with 5 additional entries: ${ar_url[3,8..11]}
f_sm7 "${ar_cat[3]}" 5
f_sm6 3 "${ar_uri[3]}"; f_do     # done while initializing category
for G in {8..11}; do
   f_sm6 "${G}" "${ar_uri[G]}"; f_add "${ar_url[G]}" | _grp -v "^#" >> "${ar_dmn[3]}"; f_do
done
# fixing false-bad entries
f_fix "${ar_cat[3]}" "${ar_dmn[3]}" "${ar_txt[3]}"
f_out "${ar_txt[3]}" "${ar_txt[5]}"
f_fip "${ar_txt[3]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: MALWARE
# contents: malware, phishing and ransomware domains
#+          ${ar_cat[2]} with 8 additional entries: ${ar_url[2,12..17]}
f_sm7 "${ar_cat[2]}" 7
f_sm6 2 "${ar_uri[2]}"; f_do     # done while initializing category
f_sm6 12 "${ar_uri[12]}"; f_add "${ar_url[12]}" | _grp -Ev "^(#|:)" | cut -d' ' -f2 >> "${ar_dmn[2]}"; f_do
f_sm6 13 "${ar_uri[13]}"; f_add "${ar_url[13]}" | _sed "1,11d;/^;/d" | cut -d' ' -f1 >> "${ar_dmn[2]}"; f_do
for H in {14..17}; do
   f_sm6 "${H}" "${ar_uri[H]}"; f_add "${ar_url[H]}" | _grp -Ev "^(#|$)" >> "${ar_dmn[2]}"; f_do
done
# fixing false-bad entries
f_fix "${ar_cat[2]}" "${ar_dmn[2]}" "${ar_txt[2]}"
f_out "${ar_txt[2]}" "${ar_txt[5]}"
f_fip "${ar_txt[2]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: IPV4
# contents: ipv4 as CIDR block and captured ipv4 from others category
f_sm7 "${ar_cat[1]}" 0
f_sm8 "${ar_cat[1]}"             # fixing false-bad entries
awk '!x[$0]++' "${ar_dmn[1]}" | _srt -n -t . -k1,1 -k2,2 -k3,3 -k4,4 -s -o "${ar_txt[1]}"; f_do
printf "%12s: %'d entries.\n" "acquired" "$(wc -l < "${ar_txt[1]}")"

# summarize
printf "\nprocessing sources-urls (${_CYN}) in summary:\n" "${#ar_txt[@]} CATEGORIES"
for J in "${!ar_cat[@]}"; do
   printf -v _sum "%'d" "$(wc -l < "${ar_txt[J]}")"
   printf "%12s: %9s entries\n" "${ar_cat[J]}" "${_sum}"
done
printf "%12s: %'d entries\n" "TOTAL" "$(awk 'END {print NR}' "${ar_txt[@]}")"
printf "%12s: %9s Megabytes\n\n" "disk-usage" "$(wc -c "${ar_txt[@]}" | tail -1 | awk -F' ' '{print ($1/1024^2)}')"
T="$(($(date +%s%N)-T))"
f_tim

f_sm0   # completed by offering OPTIONs: continued to various tasks OR stop here
read -r opsi
until [[ ${opsi} =~ ^[1-4]{1}$ ]]; do
   printf "please enter: ${_CYN} to continue OR ${_ccl} to quit\n" "[1|2|3|4]"
   read -r opsi
done
for L in "${!ar_shy[@]}"; do ar_exe+=("${_DIR}/${ar_shy[L]}"); done
case ${opsi:0:1} in
   1) f_sm1; "${ar_exe[2]}"; f_sm9 st;;
   2) f_sm2
      if "${ar_exe[2]}"; then
         if "${ar_exe[0]}"; then f_sm9 nd; fi
      else exit 1; fi;;
   3) f_sm3
      if "${ar_exe[2]}"; then
         if "${ar_exe[0]}"; then
            if "${ar_exe[1]}"; then f_sm9 th; fi
         else exit 1; fi
      else exit 1; fi;;
   4) f_sm4
      if "${ar_exe[2]}"; then
         if "${ar_exe[0]}"; then
            if "${ar_exe[1]}"; then
               if "${ar_exe[3]}"; then f_sm9 th; fi
            else exit 1; fi
         else exit 1; fi
      else exit 1; fi;;
   *) f_cln; exit 1;;
esac
exit 0
