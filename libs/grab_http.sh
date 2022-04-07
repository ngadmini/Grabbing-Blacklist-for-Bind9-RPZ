#!/usr/bin/env bash
# TAGS
#   grab_http.sh
#   v4.2
# AUTHOR
#   ngadimin@warnet-ersa.net

SOURCED=false && [ "$0" = "${BASH_SOURCE[0]}" ] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
_BLD="$_DIR"/grab_build.sh
_CRL="$_DIR"/grab_cereal.sh
_DPL="$_DIR"/grab_dedup.sh
_REG="$_DIR"/grab_regex
_URL="$_DIR"/grab_urls
_LIB="$_DIR"/grab_lib.sh
umask 077
export LC_NUMERIC=id_ID.UTF-8
trap f_trap EXIT INT TERM   # cleanUP on exit, interrupt & terminate
startTime=$(date +%s)
start=$(date "+DATE: %Y-%m-%d%tTIME: %H:%M:%S")
# shellcheck source=/dev/null
source "$_LIB"

f_grab() {    # initialize CATEGORY, many categories are obtained but it's the main one is adult
   printf "\n\x1b[93mPERFORMING TASK.\x1b[0m Initiating CATEGORY of domains\n"
   f_tmp      # remove temporary dir-file if any
   # grabbing dsi.ut-capitole.fr use as initial category
   for A in {0..5}; do
      tar_dsi=$(basename "${ar_url[A]}"); ext_dsi=${tar_dsi/.tar.gz/}
      printf "%12s: %-66s" "${ext_dsi^^}" "${ar_sho[A]}"
      curl -C - -ksfO "${ar_url[A]}" || f_excod 14 "${ar_url[A]}"
      tar -xzf "$tar_dsi" "$ext_dsi/domains"; f_sm5
   done

   # define initial category and verify main category are present in array
   mkdir ipv4; mv phishing malware; mv gambling trust+; cat vpn/domains >> redirector/domains; rm -r vpn
   mapfile -t ar_cat < <(find . -maxdepth 1 -type d | sed -e '1d;s/\.\///' | sort)
   printf "%12s: \x1b[93m%-66s\x1b[0m" "initiating" "${ar_cat[*]} (${#ar_cat[@]} CATEGORIES)"
   [ "${#ar_cat[@]}" -eq 6 ] || f_excod 15

   # remove previously domain lists if any && define temporary array based on initial category
   find . -maxdepth 1 -type f -name "txt.*" -print0 | xargs -0 -r rm
   ar_dmn=(); ar_tmp=(); ar_txt=()
   for B in {0..5}; do
      ar_dmn+=("${ar_cat[B]}"/domains)
      ar_tmp+=(tmq."${ar_cat[B]}")
      ar_txt+=(txt."${ar_cat[B]}")
   done
   f_sm5
}

# START MAIN SCRIPT
cd "$_DIR"
printf "\nstarting ...\n%s\n" "$start"
[ ! "$UID" -eq 0 ] || f_excod 10      # comment for root privileges
for C in {"$_DPL","$_BLD","$_CRL","$_LIB"}; do [ -f "$C" ] || f_excod 17 "$C"; [ -x "$C" ] || chmod +x "$C"; done
[ -f "$_URL" ] || f_excod 17 "$_URL"; mapfile -t ar_url < "$_URL"; [ "${#ar_url[@]}" -eq 21 ] || f_excod 11 "$_URL"
[ -f "$_REG" ] || f_excod 17 "$_REG"; mapfile -t ar_reg < "$_REG"; [ "${#ar_reg[@]}" -eq 4 ] || f_excod 12 "$_REG"
printf "\x1b[93mPREPARING TASK:\x1b[0m Check the Remote Files isUP or isDOWN\n"
ar_sho=(); f_crawl "$_URL" || true; f_grab

# CATEGORY: TRUST+ --> ${ar_cat[3]} with 2 additional entries: ${urls[1,7]}
f_sm8 "${ar_cat[5]}" 2
trust=$(mktemp --tmpdir="$_DIR"); untrust=$(mktemp --tmpdir="$_DIR"); porn=$(mktemp --tmpdir="$_DIR")
f_sm7 6 "${ar_sho[6]}"; f_add "${ar_url[6]}" | _grep -v '^#' >> "${porn}"; f_sm5
for D in ${untrust}; do
   f_sm7 7 "${ar_sho[7]}"; f_add "${ar_url[7]}" | _sed "/[^\o0-\o177]/d" | _sed -e "${ar_reg[2]}" >> "$D"
   # throw porn-domains in ${untrust} and ${porn} to ${ar_dmn[0]}, use "${trust}" as temporary
   _sort "$D" "${porn}" | uniq -d >> "${trust}"
   _grep -E "${ar_reg[3]}" "$D" | _sort -u >> "${trust}"
   # delete the porn domains in ${untrust}, save the rest in ${ar_dmn[5]}
   awk 'FILENAME == ARGV[1] && FNR==NR{a[$1];next} !($1 in a)' "${trust}" "$D" >> "${ar_dmn[5]}"
done; f_sm5

# fixing bad, duplicate and false entry
for E in ${ar_dmn[5]}; do
   f_falsf "${ar_cat[5]}" "$E" "${ar_txt[5]}" "${ar_reg[0]}" "${ar_reg[1]}"
done; f_sm5
for F in ${ar_txt[5]}; do f_falsg "$F" "${ar_dmn[1]}" "${ar_cat[1]^^}"; done

# CATEGORY: ADULT --> ${ar_cat[0]} with 3 additional entries: ${ar_url[0,6,7]}
f_sm8 "${ar_cat[0]}" 3
for V in {0,6,7}; do f_sm7 "$V" "${ar_sho[V]}"; f_sm5; done
cat "${trust}" >> "${ar_dmn[0]}"
# fixing bad, duplicate and false entry
for G in ${ar_dmn[0]}; do
   f_falsf "${ar_cat[0]}" "$G" "${ar_txt[0]}" "${ar_reg[0]}" "${ar_reg[1]}"
done; f_sm5
for H in ${ar_txt[0]}; do f_falsg "$H" "${ar_dmn[1]}" "${ar_cat[1]^^}"; done

# CATEGORY: REDIRECTOR --> ${ar_cat[4]} with 2 additional entries: ${urls[4,5]}
f_sm8 "${ar_cat[4]}" 2
for W in {4,5}; do f_sm7 "$W" "${ar_sho[W]}"; f_sm5; done
# fixing bad, duplicate and false entry
for I in ${ar_dmn[4]}; do
   f_falsf "${ar_cat[4]}" "$I" "${ar_txt[4]}" "${ar_reg[0]}" "${ar_reg[1]}"
done; f_sm5
for J in ${ar_txt[4]}; do f_falsg "$J" "${ar_dmn[1]}" "${ar_cat[1]^^}"; done

# CATEGORY: PUBLICITE --> ${ar_cat[3]} with 4 additional entries: ${urls[8..11]}
f_sm8 "${ar_cat[3]}" 4
for K in {8..11}; do
   f_sm7 "$K" "${ar_sho[K]}"; f_add "${ar_url[K]}" | _grep -v '^#' >> "${ar_dmn[3]}"; f_sm5
done
# fixing bad, duplicate and false entry
for L in ${ar_dmn[3]}; do
   f_falsf "${ar_cat[3]}" "$L" "${ar_txt[3]}" "${ar_reg[0]}" "${ar_reg[1]}"
done; f_sm5
for M in ${ar_txt[3]}; do f_falsg "$M" "${ar_dmn[1]}" "${ar_cat[1]^^}"; done

# CATEGORY: MALWARE --> ${ar_cat[2]} with 7 additional entries: ${ar_url[12..18]}
f_sm8 "${ar_cat[2]}" 7
f_sm7 12 "${ar_sho[12]}"; f_add "${ar_url[12]}" | _grep -v "^\(#\|:\)" | cut -d' ' -f2 >> "${ar_dmn[2]}"; f_sm5
f_sm7 13 "${ar_sho[13]}"; f_add "${ar_url[13]}" | _sed '1,11d;/^;/d' | cut -d' ' -f1 >> "${ar_dmn[2]}"; f_sm5
for O in {14..18}; do
   f_sm7 "$O" "${ar_sho[O]}"; f_add "${ar_url[O]}" | _grep -v '^#' >> "${ar_dmn[2]}"; f_sm5
done
# fixing bad, duplicate and false entry
for P in ${ar_dmn[2]}; do
   f_falsf "${ar_cat[2]}" "$P" "${ar_txt[2]}" "${ar_reg[0]}" "${ar_reg[1]}"
done; f_sm5
for Q in ${ar_txt[2]}; do f_falsg "$Q" "${ar_dmn[1]}" "${ar_cat[1]^^}"; done

# CATEGORY: IPV4 --> ${ar_cat[1]} with 4 additional entries: ${ar_url[19..20]}
f_sm8 "${ar_cat[1]}" 2
f_sm7 19 "${ar_sho[19]}"; f_add "${ar_url[19]}" | _sed '/\(#\|\/\)/d' >> "${ar_dmn[1]}"; f_sm5
f_sm7 20 "${ar_sho[20]}"; f_add "${ar_url[20]}" | _grep -v '^#' >> "${ar_dmn[1]}"; f_sm5
# fixing bad, duplicate and false entry
f_sm9 "${ar_cat[1]}"
for R in ${ar_dmn[1]}; do
   awk '!x[$0]++' "$R" | _sed -e '/:\|\.$\|\//d' | _sort -n -t . -k1,1 -k2,2 -k3,3 -k4,4 -o "${ar_txt[1]}"
done; f_sm5
printf "%12s: %'d entries.\n" "acquired" "$(wc -l < "${ar_txt[1]}")"

# display the result OF ACQUIRING DOMAINS
[ "${#ar_txt[@]}" -eq 6 ] || f_excod 15
printf "\nAcquired domains (\x1b[93m%s CATEGORIES\x1b[0m) in summary:\n" "${#ar_txt[@]}"
for S in {0..5}; do
   printf -v aqr_sum "%'d" "$(wc -l < "${ar_txt[S]}")"
   printf "%12s: %9s entries\n" "${ar_cat[S]}" "$aqr_sum"
done
printf -v ttl_sum "%'d" "$(wc -l "${ar_txt[@]}" | grep "total" | cut -d' ' -f3)"
printf "%12s: %9s entries\n" "TOTAL" "$ttl_sum"

# SORTING AND PRUNING SUB-domains if domains present
printf "\nSORT & PRUNE: sorting and pruning sub-domains if domains present%-17s" " "
dos2unix "${ar_txt[@]}" >> /dev/null 2>&1
for T in {0..5}; do
   # skipping ipV4 from sorting and prunning
   if [ "$T" -eq 1 ]; then continue; fi
   _sort -u "${ar_txt[T]}" -o "${ar_txt[T]}"
   _sed 's/^/\./' "${ar_txt[T]}" | rev | _sort -u \
      | awk 'p == "" || substr($0,1,length(p)) != p { print $0; p = $0 }' \
      | rev | _sed 's/^\.//' | _sort > "${ar_tmp[T]}"
   unset -v ar_txt
   mapfile -t ar_txt < <(find . -maxdepth 1 -type f -name "txt.*" | sed -e 's/\.\///' | sort)
   cp "${ar_tmp[T]}" "${ar_txt[T]}"
done; f_sm5

# display the result of SORTING AND PRUNING
printf "Acquired domains (\x1b[93m%s CATEGORIES\x1b[0m) after sorting and prunning:\n" "${#ar_txt[@]}"
for U in {0..5}; do
   printf -v aqr_sp "%'d" "$(wc -l < "${ar_txt[U]}")"
   printf "%12s: %9s entries\n" "${ar_cat[U]}" "$aqr_sp"
done
printf -v ttl_sp "%'d" "$(wc -l "${ar_txt[@]}" | grep "total" | cut -d' ' -f3)"
printf "%12s: %9s entries\n" "TOTAL" "$ttl_sp"

# TASK: completed
endTime=$(date +%s)
DIF=$((endTime - startTime))
f_sm6 "$((DIF/60))" "$((DIF%60))s"
unset -v ar_{cat,dmn,reg,sho,tmp,txt,url} isDOWN

# offerring OPTIONS: continued to next stept OR stop here
HOST="rpz.warnet-ersa.net"      # fqdn or ip-address
f_sm0 "$HOST"
read -r RETVAL
case $RETVAL in
   1) f_sm1; "$_DPL"; f_sm10 st;;
   2) f_sm2; "$_DPL"; "$_BLD"; f_sm10 nd;;
   3) f_sm3; "$_DPL"; "$_BLD"; "$_CRL"; f_sm10 th;;
   4) f_sm4 "$HOST"; "$_DPL"; "$_BLD"; "$_CRL"; f_scp "$HOST"; f_sm10 th;;
   *) printf "\x1b[91mNothing choosen, just stop right now\x1b[0m\n"
      printf "\x1b[91mYou can still run: %s anytime after this\x1b[0m\n" \
         "[grab_dedup.sh, grab_build.sh, grab_cereal.sh and grab_scp.sh]";;
esac
printf "bye!\n"
exit 0
