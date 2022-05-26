#!/usr/bin/env bash
# TAGS
#   grab_http.sh
#   v6.6
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2154

startTime=$SECONDS
umask 027
set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
_BLD="$_DIR"/grab_build.sh
_CRL="$_DIR"/grab_cereal.sh
_DPL="$_DIR"/grab_duplic.sh
_REG="$_DIR"/grab_regex
_SCP="$_DIR"/grab_rsync.sh
_URL="$_DIR"/grab_urls
wc_cat=6       # number of category
wc_url=22      # number of lines ${_URL}
wc_reg=3       # number of lines $(_REG}

f_grab() {   # initialize CATEGORY, many categories are obtained but the main one is adult
   printf "\n${_ylw}PERFORMING TASKs:${_ncl} initiating CATEGORY of domains%s\n"
   f_tmp                       # remove temporary dir-file if any

   for A in {0..5}; do         # grabbing dsi.ut-capitole.fr use as initial category
      tar_dsi=$(basename "${ar_url[A]}")
      ext_dsi=${tar_dsi/.tar.gz/}
      printf "%12s: %-66s" "${ext_dsi^^}" "${ar_sho[A]}"
      curl -C - -ksfO "${ar_url[A]}" || f_xcd 14 "${ar_url[A]}"
      find . -type d -o -type f -name "${ext_dsi}" -print0 | xargs -0 -r rm -rf
      tar -xzf "${tar_dsi}" "${ext_dsi/domains}"
      f_do
   done

   mkdir ipv4                  # make adjusment for initial category
   mv phishing malware         #
   mv gambling trust+          # adult ipv4 malware publicite redirector AND trust+
   cat vpn/domains >> redirector/domains
   rm -rf vpn

   # initial array (ar_cat) AND define some new arrays based on its
   mapfile -t ar_cat < <(f_cat)
   printf "%12s: ${_cyn}%s${_ncl}\n" "initiating" "${ar_cat[*]} (${#ar_cat[@]} CATEGORIES)"
   [[ ${#ar_cat[@]} -eq ${wc_cat} ]] || f_xcd 15
   f_frm "txt.*"               # remove previously CATEGORY-files if any
   ar_dmn=()                   # ar_dmn as raw-domains container
   ar_tmp=()                   # ar_tmp as in-process-domains container (temporary)
   ar_txt=()                   # ar_txt as processed-domains container
   for B in "${!ar_cat[@]}"; do
      ar_dmn+=("${ar_cat[B]}"/domains)
      ar_tmp+=(tmq."${ar_cat[B]}")
      ar_txt+=(txt."${ar_cat[B]}")
   done
}

f_src() {
   readonly _LIB="$_DIR"/grab_library
   if [[ -e ${_LIB} ]]; then
      [[ -r ${_LIB} ]] || chmod 644 "${_LIB}"
      source "${_LIB}"
      f_trap                 # cleanUP on exit, interrupt & terminate
   else
      printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"
      exit
   fi
}

# START <preparing>
f_src; f_cnf
printf "\nstarting %s at ${_cyn}%s${_ncl}\n" "${0##*/}" "${_lct}"
cd "$_DIR"
printf "${_pre} %-63s" "check ${0##*/} is execute by non-root privileges"
[[ ! $UID -eq 0 ]] || f_xcd 10; f_ok

printf "${_pre} %-63s" "check required packages on local-host: $(hostname -I)"
pkg='curl dos2unix faketime libnet-netmask-perl rsync'
for D in $pkg; do
   if ! dpkg -s "$D" >> /dev/null 2>&1; then f_xcd 8 "$D"; fi
done
f_ok

printf "${_pre} %-63s" "check properties of script-pack on local-host: $(hostname -I)"
for E in {"$_DPL","$_BLD","$_CRL","$_SCP"}; do
   [[ -e $E ]] || f_xcd 17 "$E"
   [[ -x $E ]] || chmod +x "$E"
done

for e in {"$_REG","$_URL"}; do
   [[ -e $e ]] || f_xcd 17 "$e"
   [[ -r $e ]] || chmod 644 "$e"
   _sed -i "/^$/d" "$e"
done

mapfile -t ar_url < "$_URL"; [[ ${#ar_url[@]} -eq ${wc_url} ]] || f_xcd 11 "$_URL"
mapfile -t ar_reg < "$_REG"; [[ ${#ar_reg[@]} -eq ${wc_reg} ]] || f_xcd 12 "$_REG"
f_ok

printf "${_pre} check the remote-files isUP or isDOWN%s\n"
f_crawl "$_URL"

# <main script>
f_grab                         # grabbing categories

# category: TRUST+ --> ${ar_cat[5]} with 3 additional entries: ${url[1,7,21]}
f_sm8 "${ar_cat[5]}" 3
trust=$(mktemp --tmpdir="$_DIR")
untrust=$(mktemp --tmpdir="$_DIR")
porn=$(mktemp --tmpdir="$_DIR")

f_sm7 1 "${ar_sho[1]}";f_do    # done when initiating category
f_sm7 7 "${ar_sho[7]}"; f_add "${ar_url[7]}" >> "${untrust}"; f_do
f_sm7 21 "${ar_sho[21]}"; f_add "${ar_url[21]}" >> "${porn}"; f_do

# identifying porn domains, use its to reduce porn domains in trust+ category
printf "%12s: %-64s\t" "throw" "porn domains into ${ar_cat[0]^^} CATEGORY"
f_ip "${porn}" "${ar_dmn[1]}"
_sort "${untrust}" "${porn}" | uniq -d >> "${trust}"
_grep -E "${ar_reg[2]}" "${untrust}" | sort -u >> "${trust}"

# throw the porn domains ${untrust} into adult CATEGORY, save the rest in trust+ CATEGORY
awk 'FILENAME == ARGV[1] && FNR==NR{a[$1];next} !($1 in a)' "${trust}" "${untrust}" >> "${ar_dmn[5]}"
cat "${trust}" >> "${ar_dmn[0]}"
f_do

f_fix "${ar_cat[5]}" "${ar_dmn[5]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[5]}"
f_fip "${ar_txt[5]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: ADULT --> ${ar_cat[0]} with 3 additional entries: ${ar_url[0,6,7]}
f_sm8 "${ar_cat[0]}" 3
f_sm7 0 "${ar_sho[0]}"; f_do    # done when initiating category
f_sm7 6 "${ar_sho[6]}"; f_add "${ar_url[6]}" | _grep -v '^#' >> "${ar_dmn[0]}"; f_do
f_sm7 7 "${ar_sho[7]}"; f_do    # done when processing trust+ category

f_fix "${ar_cat[0]}" "${ar_dmn[0]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[0]}"
f_fip "${ar_txt[0]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: REDIRECTOR --> ${ar_cat[4]} with 2 additional entries: ${ar_url[4,5]}
f_sm8 "${ar_cat[4]}" 2          # done when initiating category
for F in {4,5}; do f_sm7 "$F" "${ar_sho[F]}"; f_do; done
f_fix "${ar_cat[4]}" "${ar_dmn[4]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[4]}"
f_fip "${ar_txt[4]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: PUBLICITE --> ${ar_cat[3]} with 5 additional entries: ${ar_url[3,8..11]}
f_sm8 "${ar_cat[3]}" 5
f_sm7 3 "${ar_sho[3]}";f_do     # done when initiating category

for G in {8..11}; do
   f_sm7 "$G" "${ar_sho[G]}"
   f_add "${ar_url[G]}" | _grep -v "^#" >> "${ar_dmn[3]}"
   f_do
done

f_fix "${ar_cat[3]}" "${ar_dmn[3]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[3]}"
f_fip "${ar_txt[3]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: MALWARE --> ${ar_cat[2]} with 8 additional entries: ${ar_url[2,12..18]}
f_sm8 "${ar_cat[2]}" 8
f_sm7 2 "${ar_sho[2]}"; f_do    # done when initiating category

f_sm7 12 "${ar_sho[12]}"
f_add "${ar_url[12]}" | _grep -v "^\(#\|:\)" | cut -d" " -f2 >> "${ar_dmn[2]}"
f_do

f_sm7 13 "${ar_sho[13]}"
f_add "${ar_url[13]}" | _sed "1,11d;/^;/d" | cut -d" " -f1 >> "${ar_dmn[2]}"
f_do

for H in {14..18}; do
   f_sm7 "$H" "${ar_sho[H]}"
   f_add "${ar_url[H]}" | _grep -v "#" >> "${ar_dmn[2]}"
   f_do
done

f_fix "${ar_cat[2]}" "${ar_dmn[2]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[2]}"
f_fip "${ar_txt[2]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

# category: IPV4 --> ${ar_cat[1]} with 2 additional entries: ${ar_url[19..20]}
f_sm8 "${ar_cat[1]}" 2

for I in {19,20}; do     # save ipv4 into sub-nets
   f_sm7 "$I" "${ar_sho[I]}"
   f_add "${ar_url[I]}" | _grep -v "^#" | _sed -e "/\/[0-9]\{2\}$/ ! s/$/\/32/" >> "${ar_dmn[1]}"
   f_do
done

f_sm9 "${ar_cat[1]}"     # remove duplicate entry then sort the rest
awk '!x[$0]++' "${ar_dmn[1]}" | _sort -n -t . -k1,1 -k2,2 -k3,3 -k4,4 -o "${ar_txt[1]}"
f_do
printf "%12s: %'d entries.\n" "acquired" "$(wc -l < "${ar_txt[1]}")"

# display of ACQUIRED DOMAINS
[[ ${#ar_txt[@]} -eq ${#ar_cat[@]} ]] || f_xcd 15
printf "\nacquired domains (${_cyn}%s CATEGORIES${_ncl}) in summary:\n" "${#ar_txt[@]}"
for J in "${!ar_cat[@]}"; do
   printf -v aqr_sum "%'d" "$(wc -l < "${ar_txt[J]}")"
   printf "%12s: %9s entries\n" "${ar_cat[J]}" "${aqr_sum}"
done
printf -v _sum "%'d" "$(wc -l "${ar_txt[@]}" | grep "total" | cut -d" " -f3)"
printf "%12s: %9s entries\n" "TOTAL" "${_sum}"

# END <finishing>
printf "\n${_ylw}PRUNING:${_ncl} sub-domains if parent-domains present and sub-nets into CIDR blocks if any%s\n"
dos2unix "${ar_txt[@]}" >> /dev/null 2>&1

for K in "${!ar_txt[@]}"; do
   if [[ $K -eq 1 ]]; then   # turn ipv4 sub-nets into Classless Inter-Domain Routing (CIDR) blocks if any
      while read -r; do      # require 'libnet-netmask-perl'
         perl -MNet::Netmask -ne 'm!(\d+\.\d+\.\d+\.\d+/?\d*)! or next;
         $h = $1;
         $h =~ s/(\.0)+$//;
         $b=Net::Netmask->new($h);
         $b->storeNetblock();
         END {print map {$_->base()."/".$_->bits()."\n"} cidrs2cidrs(dumpNetworkTable)}' > "${ar_tmp[K]}"
      done < "${ar_txt[K]}"
      printf -v _ip4 "%'d" "$(wc -l < "${ar_tmp[K]}")"
      printf "%12s: %9s entries\n" "${ar_cat[K]}" "${_ip4}"
   else                      # prune sub-domains if parent domain present
      _sed 's/^/\./' "${ar_txt[K]}" \
         | rev \
         | _sort -u \
         | awk 'p == "" || substr($0,1,length(p)) != p { print $0; p = $0 }' \
         | rev \
         | _sed "s/^\.//" \
         | _sort > "${ar_tmp[K]}"
      printf -v _snp "%'d" "$(wc -l < "${ar_tmp[K]}")"
      printf "%12s: %9s entries\n" "${ar_cat[K]}" "${_snp}"
   fi
   cp "${ar_tmp[K]}" "${ar_txt[K]}"
done

unset -v ar_txt
mapfile -t ar_txt < <(f_fnd "txt.*")
printf "%12s: %'d entries\n" "TOTAL" "$(wc -l "${ar_tmp[@]}" | grep "total" | cut -d" " -f3)"
runTime=$((SECONDS - startTime))
f_sm6 "$((runTime/60))m" "$((runTime%60))s"
f_klin

# completing the task. offerring OPTIONs: continued to next tasks OR stop here
f_sm0 "${HOST}"
read -r RETVAL
until [[ ${RETVAL} =~ ^[1-4]{1}$ ]]
do
   printf "please enter: ${_cyn}[1|2|3|4]${_ncl} or Ctrl+c to quit%s\n"
   read -r RETVAL
done
case $RETVAL in
   1) f_sm1; "$_DPL"; f_sm10 st;;
   2) f_sm2
      if "$_DPL"; then
         if "$_BLD"; then f_sm10 nd; fi
      else
         exit 1
      fi
      ;;
   3) f_sm3
      if "$_DPL"; then
         if "$_BLD"; then
            if "$_CRL"; then f_sm10 th; fi
         else
            exit 1
         fi
      else
         exit 1
      fi
      ;;
   4) f_sm4
      if "$_DPL"; then
         if "$_BLD"; then
            if "$_CRL"; then
               if "$_SCP"; then f_sm10 th; fi
            else
               exit 1
            fi
         else
            exit 1
         fi
      else
         exit 1
      fi
      ;;
   *) f_rvu;;
esac
printf "bye!\n"
exit 0
