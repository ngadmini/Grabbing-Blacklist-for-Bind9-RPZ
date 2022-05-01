#!/usr/bin/env bash
# TAGS
#   grab_http.sh
#   v6.3
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

umask 027
SOURCED=false && [ "$0" = "${BASH_SOURCE[0]}" ] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(realpath "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")
_BLD="$_DIR"/grab_build.sh; _CRL="$_DIR"/grab_cereal.sh; _REG="$_DIR"/grab_regex;
_DPL="$_DIR"/grab_dedup.sh; _SCP="$_DIR"/grab_scp.sh;    _URL="$_DIR"/grab_urls
startTime=$(date +%s);     start=$(date "+DATE: %Y-%m-%d TIME: %H:%M:%S")

f_grab() {   # initialize CATEGORY, many categories are obtained but it's the main one is adult
   printf "\n\x1b[93mPERFORMING TASKs:\x1b[0m Initiating CATEGORY of domains\n"
   f_tmp                 # remove temporary dir-file if any

   for A in {0..5}; do   # grabbing dsi.ut-capitole.fr use as initial category
      tar_dsi=$(basename "${ar_url[A]}"); ext_dsi=${tar_dsi/.tar.gz/}
      printf "%12s: %-66s" "${ext_dsi^^}" "${ar_sho[A]}"
      curl -C - -ksfO "${ar_url[A]}" || f_xcd 14 "${ar_url[A]}"
      tar -xzf "$tar_dsi" "$ext_dsi/domains"
      f_do
   done

   # define initial category and marking as an array
   mkdir ipv4; mv phishing malware; mv gambling trust+; cat vpn/domains >> redirector/domains; rm -r vpn
   mapfile -t ar_cat < <(find . -maxdepth 1 -type d | sed -e "1d;s/\.\///" | sort)
   printf "%12s: \x1b[93m%s\x1b[0m\n" "initiating" "${ar_cat[*]} (${#ar_cat[@]} CATEGORIES)"
   [ "${#ar_cat[@]}" -eq 6 ] || f_xcd 15

   # remove previously domain lists if any && define some arrays based on initial array (ar_cat)
   find . -maxdepth 1 -type f -name "txt.*" -print0 | xargs -0 -r rm
   ar_dmn=(); ar_tmp=(); ar_txt=()   # ar_dmn as raw-domains container
                                     # ar_tmp as in-process-domains container (temporary)
   for B in {0..5}; do               # ar_txt as processed-domains container
      ar_dmn+=("${ar_cat[B]}"/domains); ar_tmp+=(tmq."${ar_cat[B]}"); ar_txt+=(txt."${ar_cat[B]}")
   done
}

# START TASKs <main script>
printf "\nStarting %s ... %s\n" "$(basename "$0")" "$start"
printf "\x1b[93mPREPARING TASKs:\x1b[0m %-63s" "Check $(basename "$0") is execute by non-root privileges"
[ ! "$UID" -eq 0 ] || f_xcd 10; printf "\x1b[92m%s\x1b[0m\n" "isOK"
cd "$_DIR"; test -r "$_DIR"/grab_lib || chmod 644 "$_DIR"/grab_lib
# shellcheck source=/dev/null disable=SC2029
source "$_DIR"/grab_lib; trap f_trap EXIT TERM; trap 'printf "\ninterrupted\n"; f_trap; exit' INT

printf "\x1b[93mPREPARING TASKs:\x1b[0m %-63s" "Check availability bind9-server: '$HOST'"
if ping -w 1 "$HOST" >> /dev/null 2>&1; then f_ok
   printf "\x1b[93mPREPARING TASKs:\x1b[0m %-63s" "Check bind9-server: $HOST for passwordless ssh"
   _ssh -o BatchMode=yes "$HOST" /bin/true  >> /dev/null 2>&1 || f_xcd 7 "$HOST"; f_ok
   printf "\x1b[93mPREPARING TASKs:\x1b[0m %-63s" "Check required packages on bind9-server: $HOST"
   for C in {rsync,pigz}; do _ssh root@"$HOST" "hash $C >> /dev/null 2>&1" || f_xcd 9 "$HOST" "$C"; done; f_ok
else
   f_xcd 16 "$HOST"
fi

printf "\x1b[93mPREPARING TASKs:\x1b[0m %-63s" "Check required packages on local host"
pkg='curl dos2unix faketime libnet-netmask-perl rsync'
for D in $pkg; do if ! dpkg -s "$D" >> /dev/null 2>&1; then f_xcd 8 "$D"; fi; done; f_ok

printf "\x1b[93mPREPARING TASKs:\x1b[0m %-63s" "Check availability and property of script-pack"
for E in {"$_DPL","$_BLD","$_CRL","$_SCP"}; do [ -e "$E" ] || f_xcd 17 "$E"; [ -x "$E" ] || chmod +x "$D"; done
[ -e "$_URL" ] || f_xcd 17 "$_URL"; _sed -i "/^$/d" "$_URL"; mapfile -t ar_url < "$_URL"
[ -e "$_REG" ] || f_xcd 17 "$_REG"; _sed -i "/^$/d" "$_REG"; mapfile -t ar_reg < "$_REG"
[ "${#ar_url[@]}" -eq 22 ] || f_xcd 11 "$_URL"; [ "${#ar_reg[@]}" -eq 3 ] || f_xcd 12 "$_REG"
f_ok

printf "\x1b[93mPREPARING TASKs:\x1b[0m Check the remote files isUP or isDOWN\n"
ar_sho=(); f_crawl "$_URL" || true   # check urls isUP or isDOWN
f_grab                               # grabbing and processing domains

f_sm8 "${ar_cat[5]}" 3         # category: TRUST+ --> ${ar_cat[5]} with 3 additional entries: ${urls[1,7,21]}
trust=$(mktemp --tmpdir="$_DIR"); untrust=$(mktemp --tmpdir="$_DIR"); porn=$(mktemp --tmpdir="$_DIR")
f_sm7 1 "${ar_sho[1]}"; f_do   # add gambling domain, done when initiating category
f_sm7 7 "${ar_sho[7]}"; f_add "${ar_url[7]}" >> "${untrust}"; f_do
f_sm7 21 "${ar_sho[21]}"; f_add "${ar_url[21]}" >> "${porn}"; f_do

printf "%12s: %-64s\t" "throw" "porn domains into ${ar_cat[0]^^} CATEGORY"
f_ip "$porn" "${ar_dmn[1]}"    # throw ipv4 to ${ar_dmn[1]} && identifying porn domains, use it's to
_sort "${untrust}" "${porn}" | uniq -d >> "${trust}"   #+ reduce porn domains in trust+ category
_grep -E "${ar_reg[2]}" "${untrust}" >> "${trust}" && sort -u "${trust}" -o "${trust}"
# delete the porn domains in ${untrust}, save the rest in ${ar_dmn[5]}
awk 'FILENAME == ARGV[1] && FNR==NR{a[$1];next} !($1 in a)' "${trust}" "${untrust}" >> "${ar_dmn[5]}"
cat "${trust}" >> "${ar_dmn[0]}"; f_do
f_fix "${ar_cat[5]}" "${ar_dmn[5]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[5]}"
f_fip "${ar_txt[5]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

f_sm8 "${ar_cat[0]}" 3         # category: ADULT --> ${ar_cat[0]} with 3 additional entries: ${ar_url[0,6,7]}
f_sm7 0 "${ar_sho[0]}"; f_do   # done when initiating category
f_sm7 6 "${ar_sho[6]}"; f_add "${ar_url[6]}" | _grep -v '^#' >> "${ar_dmn[0]}"; f_do
f_sm7 7 "${ar_sho[7]}"; f_do   # done when processing trust+ category
f_fix "${ar_cat[0]}" "${ar_dmn[0]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[0]}"
f_fip "${ar_txt[0]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

f_sm8 "${ar_cat[4]}" 2         # category: REDIRECTOR --> ${ar_cat[4]} with 2 additional entries: ${urls[4,5]}
for F in {4,5}; do f_sm7 "$F" "${ar_sho[F]}"; f_do; done   # done when initiating category
f_fix "${ar_cat[4]}" "${ar_dmn[4]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[4]}"
f_fip "${ar_txt[4]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

f_sm8 "${ar_cat[3]}" 5         # category: PUBLICITE --> ${ar_cat[3]} with 5 additional entries: ${urls[3,8..11]}
f_sm7 3 "${ar_sho[3]}"; f_do   # done when initiating category
for G in {8..11}; do f_sm7 "$G" "${ar_sho[G]}"; f_add "${ar_url[G]}" | _grep -v "^#" >> "${ar_dmn[3]}"; f_do; done
f_fix "${ar_cat[3]}" "${ar_dmn[3]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[3]}"
f_fip "${ar_txt[3]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

f_sm8 "${ar_cat[2]}" 7         # category: MALWARE --> ${ar_cat[2]} with 7 additional entries: ${ar_url[12..18]}
f_sm7 12 "${ar_sho[12]}"; f_add "${ar_url[12]}" | _grep -v "^\(#\|:\)" | cut -d" " -f2 >> "${ar_dmn[2]}"; f_do
f_sm7 13 "${ar_sho[13]}"; f_add "${ar_url[13]}" | _sed "1,11d;/^;/d" | cut -d" " -f1 >> "${ar_dmn[2]}"; f_do
for H in {14..18}; do f_sm7 "$H" "${ar_sho[H]}"; f_add "${ar_url[H]}" | _grep -v "#" >> "${ar_dmn[2]}"; f_do; done
f_fix "${ar_cat[2]}" "${ar_dmn[2]}" "${ar_reg[0]}" "${ar_reg[1]}" "${ar_txt[2]}"
f_fip "${ar_txt[2]}" "${ar_dmn[1]}" "${ar_cat[1]^^}"

f_sm8 "${ar_cat[1]}" 2         # category: IPV4 --> ${ar_cat[1]} with 2 additional entries: ${ar_url[19..20]}
for I in {19,20}; do           # save ipv4 sub-nets into CIDR block
   f_sm7 "$I" "${ar_sho[I]}"
   f_add "${ar_url[I]}" | _grep -v "^#" | _sed -e "/\/[0-9]\{2\}$/ ! s/$/\/32/" >> "${ar_dmn[1]}"
   f_do
done
f_sm9 "${ar_cat[1]}"           # remove duplicate entry then sort
awk '!x[$0]++' "${ar_dmn[1]}" | _sort -n -t . -k1,1 -k2,2 -k3,3 -k4,4 -o "${ar_txt[1]}"; f_do
printf "%12s: %'d entries.\n" "acquired" "$(wc -l < "${ar_txt[1]}")"

# display of ACQUIRED DOMAINS
[ "${#ar_txt[@]}" -eq 6 ] || f_xcd 15
printf "\nAcquired domains (\x1b[93m%s CATEGORIES\x1b[0m) in summary:\n" "${#ar_txt[@]}"
for J in {0..5}; do
   printf -v aqr_sum "%'d" "$(wc -l < "${ar_txt[J]}")"
   printf "%12s: %9s entries\n" "${ar_cat[J]}" "$aqr_sum"
done
printf -v _sum "%'d" "$(wc -l "${ar_txt[@]}" | grep "total" | cut -d" " -f3)"
printf "%12s: %9s entries\n" "TOTAL" "$_sum"

# finishing
printf "\n\x1b[93mPRUNING:\x1b[0m sub-domains if parent-domains present and sub-nets into CIDR blocks if any\n"
dos2unix "${ar_txt[@]}" >> /dev/null 2>&1

for K in {0..5}; do
   if [ "$K" -eq 1 ]; then   # turn ipv4 sub-nets into CIDR blocks if any
      while read -r; do      # require 'libnet-netmask-perl'
         perl -MNet::Netmask -ne 'm!(\d+\.\d+\.\d+\.\d+/?\d*)! or next;
         $h = $1; $h =~ s/(\.0)+$//; $b=Net::Netmask->new($h); $b->storeNetblock();
         END {print map {$_->base()."/".$_->bits()."\n"} cidrs2cidrs(dumpNetworkTable)}' |\
         _sed "s/\//\./" > "${ar_tmp[K]}"
      done < "${ar_txt[K]}"
      printf -v _ip4 "%'d" "$(wc -l < "${ar_tmp[K]}")"; printf "%12s: %9s entries\n" "${ar_cat[K]}" "$_ip4"
   else                      # prune sub-domains if parent domain present
      _sed 's/^/\./' "${ar_txt[K]}" | rev | _sort -u |\
         awk 'p == "" || substr($0,1,length(p)) != p { print $0; p = $0 }' |\
         rev | _sed "s/^\.//" | _sort > "${ar_tmp[K]}"
      printf -v _snp "%'d" "$(wc -l < "${ar_tmp[K]}")"; printf "%12s: %9s entries\n" "${ar_cat[K]}" "$_snp"
   fi
   cp "${ar_tmp[K]}" "${ar_txt[K]}"
done

unset -v ar_txt
mapfile -t ar_txt < <(find . -maxdepth 1 -type f -name "txt.*" | sed -e "s/\.\///" | sort)
printf -v _tsp "%'d" "$(wc -l "${ar_tmp[@]}" | grep "total" | cut -d" " -f3)"
printf "%12s: %s entries\n" "TOTAL" "$_tsp"
endTime=$(date +%s); DIF=$((endTime - startTime)); f_sm6 "$((DIF/60))" "$((DIF%60))s"; f_uset
# TASKs completed. end of grabbing and processing

f_sm0 "$HOST"      # offerring OPTIONs: continued to next stept OR stop here
read -r RETVAL
case $RETVAL in
   1) f_sm1; "$_DPL"; f_sm10 st;;
   2) f_sm2; "$_DPL"; "$_BLD"; f_sm10 nd;;
   3) f_sm3; "$_DPL"; "$_BLD"; "$_CRL"; f_sm10 th;;
   4) f_sm4; "$_DPL"; "$_BLD"; "$_CRL"; "$_SCP"; f_sm10 th;;
   *) f_rvu;;
esac
printf "bye!\n"
exit 0
