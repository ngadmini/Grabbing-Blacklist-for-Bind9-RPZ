#!/usr/bin/env bash
# TAGS
#   grab_rsync.sh
#   v6.6
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2154

startTime=$SECONDS
set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

f_src() {
   readonly _LIB="$_DIR"/grab_library
   if [[ -e ${_LIB} ]]; then
      [[ -r ${_LIB} ]] || chmod 644 "${_LIB}"
      source "${_LIB}"
      f_trap                 # cleanUP on exit, interrupt & terminate
   else
      printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"
      exit 1
   fi
}

# START <main script>
f_src; f_cnf
printf "\n${_red}[4'th] TASKs:${_ncl}\nstarting %s at ${_cyn}%s${_ncl}\n" "${0##*/}" "${_lct}"
cd "$_DIR"
[[ ! $UID -eq 0 ]] || f_xcd 10

f_pms   # check file permission: db.* && rpz.*
if ! ping -w 1 "${HOST}" >> /dev/null 2>&1; then f_xcd 16; fi

# check existance of db-files and zone-files
ar_DBC=(db.adultaa db.adultab db.adultac db.adultad db.adultae db.adultaf db.adultag \
   db.ipv4 db.malware db.publicite db.redirector db.trust+aa db.trust+aa)
ar_RPZ=(rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf rpz.adultag \
   rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+aa rpz.trust+aa)

mapfile -t ar_dbc < <(f_fnd "db.*")
mapfile -t ar_rpz < <(f_fnd "rpz.*")
printf -v miss_DBC "%s" "$(echo "${ar_DBC[@]}" "${ar_dbc[@]}" | f_sed)"
printf -v miss_RPZ "%s" "$(echo "${ar_RPZ[@]}" "${ar_rpz[@]}" | f_sed)"

for DBC in ${ar_DBC[*]}; do [[ -e $DBC ]] || f_xcd 20 "$miss_DBC"; done
for RPZ in ${ar_RPZ[*]}; do [[ -e $RPZ ]] || f_xcd 20 "$miss_RPZ"; done
[[ ${ar_dbc[*]} == "${ar_DBC[*]}" ]] || f_xcd 19 "$miss_DBC"
[[ ${ar_rpz[*]} == "${ar_RPZ[*]}" ]] || f_xcd 19 "$miss_RPZ"

_ts=$(date "+%Y-%m-%d")
_ID="/home/rpz-${_ts}.tar.gz"
f_ssh   # check check compatibility: ${HOST} with passwordless ssh
        # check availability: ${ZONE_DIR} in ${HOST}
        # check required packages in ${HOST}
# end of check
printf "${_inf} archiving current RPZ-dBase, save in %s:%s\n" "${HOST}" "$_ID"
_ssh root@"${HOST}" "cd /etc/bind; tar -I pigz -cf $_ID zones-rpz"
printf "${_inf} find and remove old RPZ-dBase archive in %s:/home\n" "${HOST}"
_ssh root@"${HOST}" "find /home -regex '^.*\(tar.gz\)$' -mmin +1430 -print0 | xargs -0 -r rm"
printf "${_inf} syncronizing the latest RPZ-dBase to %s:%s\n" "${HOST}" "${ZONE_DIR}"
_rsync {rpz,db}.* root@"${HOST}":"${ZONE_DIR}"

if [[ ${RNDC_RELOAD} =~ [yY][eE][sS] ]]; then
   # required sufficient RAM to execute "rndc reload"
   printf "execute ${_rnr} at BIND9-server:%s\n" "${HOST}"
   _ssh root@"${HOST}" "rndc reload"
else
   # remote-host will reboot [after +@ minute] due to low memor
   printf "${_inf} host: %s scheduled for reboot at ${_grn}%s${_ncl}\n" "${HOST}" "$_fkt"
   _ssh root@"${HOST}" "shutdown -r 5 --no-wall >> /dev/null 2>&1"
   printf "${_inf} use ${_shd} at host: %s to abort" "${HOST}"
fi

runTime=$((SECONDS - startTime))
f_sm11 "$((runTime/60))m" "$((runTime%60))s"
exit 0
