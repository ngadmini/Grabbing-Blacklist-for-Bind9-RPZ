#!/usr/bin/env bash
# TAGS
#   grab_http.sh
#   v6.2
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE


umask 027; set -Eeuo pipefail
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
_BLD="$_DIR"/grab_build.sh; _CRL="$_DIR"/grab_cereal.sh
_DPL="$_DIR"/grab_dedup.sh; _LIB="$_DIR"/grab_lib.sh
_SCP="$_DIR"/grab_scp.sh;   _REG="$_DIR"/grab_regex; _URL="$_DIR"/grab_urls
startTime=$(date +%s);     start=$(date "+DATE: %Y-%m-%d TIME: %H:%M:%S")
export LC_NUMERIC=id_ID.UTF-8   # change to your locale country
trap f_trap 0 2 3 15            # cleanUP on exit, interrupt, quit & terminate
# shellcheck source=/dev/null
# shellcheck disable=SC2029
source "$_LIB"

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

   # define initial category and verify main category are present in array
   mkdir ipv4; mv phishing malware; mv gambling trust+; cat vpn/domains >> redirector/domains; rm -r vpn
   mapfile -t ar_cat < <(find . -maxdepth 1 -type d | sed -e "1d;s/\.\///" | sort)
   printf "%12s: \x1b[93m%s\x1b[0m\n" "initiating" "${ar_cat[*]} (${#ar_cat[@]} CATEGORIES)"
   [ "${#ar_cat[@]}" -eq 6 ] || f_xcd 15

   # remove previously domain lists if any && define temporary array based on initial category
   find . -maxdepth 1 -type f -name "txt.*" -print0 | xargs -0 -r rm
   ar_dmn=(); ar_tmp=(); ar_txt=()

   for B in {0..5}; do
      ar_dmn+=("${ar_cat[B]}"/domains); ar_tmp+=(tmq."${ar_cat[B]}"); ar_txt+=(txt."${ar_cat[B]}")
   done
}

# START MAIN SCRIPT
printf "\nStarting %s ... %s\n" "$(basename "$0")" "$start"
printf "\x1b[93mPREPARING TASKs:\x1b[0m %-63s" "Check $(basename "$0") is execute by non-root privileges"
[ ! "$UID" -eq 0 ] || f_xcd 10; f_ok; cd "$_DIR"

printf "\x1b[93mPREPARING TASKs:\x1b[0m %-63s" "Check availability bind9-server: '$HOST'"
if ping -w 1 "$HOST" >> /dev/null 2>&1; then
   f_ok; printf "\x1b[93mPREPARING TASKs:\x1b[0m %-63s" "Check bind9-server: $HOST for passwordless ssh"
   _ssh -o BatchMode=yes "$HOST" /bin/true  >> /dev/null 2>&1 || f_xcd 7 "$HOST"; f_ok
   printf "\x1b[93mPREPARING TASKs:\x1b[0m %-63s" "Check required packages on bind9-server: $HOST"
   for Y in {rsync,pigz}; do _ssh root@"$HOST" "hash $Y >> /dev/null 2>&1" || f_xcd 9 "$HOST" "$Y"; done; f_ok
else
   f_xcd 16 "$HOST"
fi

printf "\x1b[93mPREPARING TASKs:\x1b[0m %-63s" "Check required packages on local host"
pkg='curl dos2unix faketime libnet-netmask-perl rsync'
for X in $pkg; do if ! dpkg -s "$X" >> /dev/null 2>&1; then f_xcd 8 "$X"; fi; done; f_ok

printf "\x1b[93mPREPARING TASKs:\x1b[0m %-63s" "Check availability and property of script-pack"
for C in {"$_DPL","$_BLD","$_CRL","$_SCP","$_LIB"}; do
   [ -f "$C" ] || f_xcd 17 "$C"; [ -x "$C" ] || chmod +x "$C"
done
# "$_URL & $_REG": must exist and free from empty lines
[ -f "$_URL" ] || f_xcd 17 "$_URL"; _sed -i "/^$/d" "$_URL"
[ -f "$_REG" ] || f_xcd 17 "$_REG"; _sed -i "/^$/d" "$_REG"
mapfile -t ar_url < "$_URL"; [ "${#ar_url[@]}" -eq 22 ] || f_xcd 11 "$_URL"
mapfile -t ar_reg < "$_REG"; [ "${#ar_reg[@]}" -eq 3 ] || f_xcd 12 "$_REG"
f_ok

printf "\x1b[93mPREPARING TASKs:\x1b[0m Check the remote files isUP or isDOWN\n"
ar_sho=(); f_crawl "$_URL" || true   # check urls isUP or isDOWN
f_grab                               # grabbing and processing domains

f_sm8 "${ar_cat[5]}" 2         # category: TRUST+ --> ${ar_cat[5]} with 2 additional entries: ${urls[1,7]}
trust=$(mktemp --tmpdir="$_DIR"); untrust=$(mktemp --tmpdir="$_DIR"); porn=$(mktemp --tmpdir="$_DIR")
f_sm7 1 "${ar_sho[1]}"; f_do   # add gambling domain, done when initiating category
f_sm7 7 "${ar_sho[7]}"; f_add "${ar_url[7]}" >> "${untrust}"; f_do
f_sm7 21 "${ar_sho[21]}"; f_add "${ar_url[21]}" >> "${porn}"; f_do

printf "%12s: %-64s\t" "throw" "porn domains into ${ar_cat[0]^^} CATEGORY"
f_ipp "$porn" "${ar_dmn[1]}"   # throw ipv4 to ${ar_dmn[1]}
for D in ${untrust}; do        # identifying porn domains, use it's to reduce porn domains in trust+ category
   _sort "$D" "${porn}" | uniq -d >> "${trust}"
   _grep -E "${ar_reg[2]}" "$D" | _sort -u >> "${trust}"
   # delete the porn domains in ${untrust}, save the rest in ${ar_dmn[5]}
   awk 'FILENAME == ARGV[1] && FNR==NR{a[$1];next} !($1 in a)' "${trust}" "$D" >> "${ar_dmn[5]}"
done
cat "${trust}" >> "${ar_dmn[0]}"; f_do

for E in ${ar_dmn[5]}; do      # fixing bad, duplicate and false entry
   f_falsf "${ar_cat[5]}" "$E" "${ar_txt[5]}" "${ar_reg[0]}" "${ar_reg[1]}"
done
for F in ${ar_txt[5]}; do f_falsg "$F" "${ar_dmn[1]}" "${ar_cat[1]^^}"; done

f_sm8 "${ar_cat[0]}" 3         # category: ADULT --> ${ar_cat[0]} with 3 additional entries: ${ar_url[0,6,7]}
f_sm7 0 "${ar_sho[0]}"; f_do   # done when initiating category
f_sm7 6 "${ar_sho[6]}"; f_add "${ar_url[6]}" | _grep -v '^#' >> "${ar_dmn[0]}"; f_do
f_sm7 7 "${ar_sho[7]}"; f_do   # done when processing trust+ category

for H in ${ar_dmn[0]}; do      # fixing bad, duplicate and false entry
   f_falsf "${ar_cat[0]}" "$H" "${ar_txt[0]}" "${ar_reg[0]}" "${ar_reg[1]}"
done
for I in ${ar_txt[0]}; do f_falsg "$I" "${ar_dmn[1]}" "${ar_cat[1]^^}"; done

f_sm8 "${ar_cat[4]}" 2         # category: REDIRECTOR --> ${ar_cat[4]} with 2 additional entries: ${urls[4,5]}
for J in {4,5}; do f_sm7 "$J" "${ar_sho[J]}"; f_do; done   # done when initiating category
for K in ${ar_dmn[4]}; do      # fixing bad, duplicate and false entry
   f_falsf "${ar_cat[4]}" "$K" "${ar_txt[4]}" "${ar_reg[0]}" "${ar_reg[1]}"
done
for L in ${ar_txt[4]}; do f_falsg "$L" "${ar_dmn[1]}" "${ar_cat[1]^^}"; done

f_sm8 "${ar_cat[3]}" 4         # category: PUBLICITE --> ${ar_cat[3]} with 4 additional entries: ${urls[8..11]}
for M in {8..11}; do f_sm7 "$M" "${ar_sho[M]}"; f_add "${ar_url[M]}" | _grep -v "^#" >> "${ar_dmn[3]}"; f_do; done
for N in ${ar_dmn[3]}; do      # fixing bad, duplicate and false entry
   f_falsf "${ar_cat[3]}" "$N" "${ar_txt[3]}" "${ar_reg[0]}" "${ar_reg[1]}"
done
for O in ${ar_txt[3]}; do f_falsg "$O" "${ar_dmn[1]}" "${ar_cat[1]^^}"; done

f_sm8 "${ar_cat[2]}" 7         # category: MALWARE --> ${ar_cat[2]} with 7 additional entries: ${ar_url[12..18]}
f_sm7 12 "${ar_sho[12]}"; f_add "${ar_url[12]}" | _grep -v "^\(#\|:\)" | cut -d" " -f2 >> "${ar_dmn[2]}"; f_do
f_sm7 13 "${ar_sho[13]}"; f_add "${ar_url[13]}" | _sed "1,11d;/^;/d" | cut -d" " -f1 >> "${ar_dmn[2]}"; f_do
for P in {14..18}; do f_sm7 "$P" "${ar_sho[P]}"; f_add "${ar_url[P]}" | _grep -v "#" >> "${ar_dmn[2]}"; f_do; done

for Q in ${ar_dmn[2]}; do      # fixing bad, duplicate and false entry
   f_falsf "${ar_cat[2]}" "$Q" "${ar_txt[2]}" "${ar_reg[0]}" "${ar_reg[1]}"
done
for R in ${ar_txt[2]}; do f_falsg "$R" "${ar_dmn[1]}" "${ar_cat[1]^^}"; done

f_sm8 "${ar_cat[1]}" 2         # category: IPV4 --> ${ar_cat[1]} with 2 additional entries: ${ar_url[19..20]}
for S in {19,20}; do           # save ipv4 sub-nets into CIDR block
   f_sm7 "$S" "${ar_sho[S]}"
   f_add "${ar_url[S]}" | _grep -v "^#" | _sed -e "/\/[0-9]\{2\}$/ ! s/$/\/32/" >> "${ar_dmn[1]}"
   f_do
done

f_sm9 "${ar_cat[1]}"           # remove duplicate entry then sort
awk '!x[$0]++' "${ar_dmn[1]}" | _sort -n -t . -k1,1 -k2,2 -k3,3 -k4,4 -o "${ar_txt[1]}"; f_do
printf "%12s: %'d entries.\n" "acquired" "$(wc -l < "${ar_txt[1]}")"

# display of ACQUIRED DOMAINS
[ "${#ar_txt[@]}" -eq 6 ] || f_xcd 15
printf "\nAcquired domains (\x1b[93m%s CATEGORIES\x1b[0m) in summary:\n" "${#ar_txt[@]}"

for U in {0..5}; do
   printf -v aqr_sum "%'d" "$(wc -l < "${ar_txt[U]}")"
   printf "%12s: %9s entries\n" "${ar_cat[U]}" "$aqr_sum"
done

printf -v _sum "%'d" "$(wc -l "${ar_txt[@]}" | grep "total" | cut -d" " -f3)"
printf "%12s: %9s entries\n" "TOTAL" "$_sum"

# finishing
# pruning sub-domains if domains present and turn ipv4 sub-nets into CIDR blocks
printf "\n\x1b[93mPRUNING:\x1b[0m sub-domains if domains present and sub-nets into CIDR blocks if any\n"
dos2unix "${ar_txt[@]}" >> /dev/null 2>&1

for V in {0..5}; do
   if [ "$V" -eq 1 ]; then   # turn ipv4 sub-nets into CIDR blocks if any
      while read -r; do      # require 'libnet-netmask-perl'
         perl -MNet::Netmask -ne 'm!(\d+\.\d+\.\d+\.\d+/?\d*)! or next;
         $h = $1; $h =~ s/(\.0)+$//; $b=Net::Netmask->new($h); $b->storeNetblock();
         END {print map {$_->base()."/".$_->bits()."\n"} cidrs2cidrs(dumpNetworkTable)}' | \
         _sed "s/\//\./" > "${ar_tmp[V]}"
      done < "${ar_txt[V]}"
      printf -v _ipv4 "%'d" "$(wc -l < "${ar_tmp[V]}")"
      printf "%12s: %9s entries\n" "${ar_cat[V]}" "$_ipv4"
   else                      # prune sub-domains if domain present
      _sed 's/^/\./' "${ar_txt[V]}" | rev | _sort -u \
         | awk 'p == "" || substr($0,1,length(p)) != p { print $0; p = $0 }' \
         | rev | _sed "s/^\.//" | _sort > "${ar_tmp[V]}"
      printf -v _snp "%'d" "$(wc -l < "${ar_tmp[V]}")"
      printf "%12s: %9s entries\n" "${ar_cat[V]}" "$_snp"
   fi
   cp "${ar_tmp[V]}" "${ar_txt[V]}"
done

# TASKs: completed
unset -v ar_txt
mapfile -t ar_txt < <(find . -maxdepth 1 -type f -name "txt.*" | sed -e "s/\.\///" | sort)
printf -v _tsp "%'d" "$(wc -l "${ar_tmp[@]}" | grep "total" | cut -d" " -f3)"
printf "%12s: %s entries\n" "TOTAL" "$_tsp"
endTime=$(date +%s); DIF=$((endTime - startTime)); f_sm6 "$((DIF/60))" "$((DIF%60))s"; f_uset
# end of grabbing and processing

f_sm0 "$HOST"      # offerring OPTIONs: continued to next stept OR stop here
read -r RETVAL     # TO DO:
case $RETVAL in    #   offering options with getopts
   1) f_sm1; "$_DPL"; f_sm10 st;;
   2) f_sm2; "$_DPL"; "$_BLD"; f_sm10 nd;;
   3) f_sm3; "$_DPL"; "$_BLD"; "$_CRL"; f_sm10 th;;
   4) f_sm4; "$_DPL"; "$_BLD"; "$_CRL"; "$_SCP"; f_sm10 th;;
   *) f_rvu;;
esac
printf "bye!\n"
exit 0
