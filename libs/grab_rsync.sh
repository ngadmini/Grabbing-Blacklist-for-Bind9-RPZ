#!/usr/bin/env bash
# TAGS
#   grab_rsync.sh
#   v7.1
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   don't change unless you know what you're doing
#   see README and LICENSE
# shellcheck source=/dev/null disable=SC2059,SC2154

T=$(date +%s%N)
set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${_DIR}"

readonly _LIB="${_DIR}"/grab_library
if [[ -e ${_LIB} ]]; then
   if [[ $(stat -L -c "%a" "${_LIB}") != 644 ]]; then chmod 644 "${_LIB}"; fi
   source "${_LIB}"; f_trp; f_cnf
else
   printf "[FAIL] %s notFOUND\n" "${_LIB##*/}"; exit 1
fi

f_stt "[4'th] TASKs:"
ar_DBC=(db.adultaa db.adultab db.adultac db.adultad db.adultae db.adultaf db.adultag \
   db.ipv4 db.malware db.publicite db.redirector db.trust+)
ar_RPZ=(rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf rpz.adultag \
   rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+)

# check required: db-files at local-host
printf "\n${_inf} check availability: RPZ-dBase and zone-files in local-host: %-25s" "$(hostname -I)"
mapfile -t ar_dbc < <(f_fnd "db.*")
printf -v miss_DBC "%s" "$(echo "${ar_DBC[@]}" "${ar_dbc[@]}" | f_sed)"
if ! [[ ${ar_dbc[*]} == "${ar_DBC[*]}" ]]; then
   printf "\n${_inf} misMATCH file: ${_CYN}" "${miss_DBC}"; f_xcd 255 "${ar_DBC[*]}"
fi

# check required: zone-files at local-host
mapfile -t ar_rpz < <(f_fnd "rpz.*")
printf -v miss_RPZ "%s" "$(echo "${ar_RPZ[@]}" "${ar_rpz[@]}" | f_sed)"
if ! [[ ${ar_rpz[*]} == "${ar_RPZ[*]}" ]]; then
   printf "\n${_inf} misMATCH file: ${_CYN}" "${miss_RPZ}"; f_xcd 255 "${ar_RPZ[*]}"
fi

# check permission: zone-files and db-files at local-host
for PERM in {"${ar_dbc[@]}","${ar_rpz[@]}"}; do f_sta 640 "${PERM}"; done
f_ok; f_ssh   # end of check

# archieving old RPZ-dBase at remote-host
printf -v _ID "/home/rpz-%s.tar.gz" "$(date +%Y%m%d-%H%M%S)"
printf "${_inf} %-85s" "archiving stale RPZ-dBase in ${HOST}:${_ID}"
_ssh root@"${HOST}" "cd ${ZONE_DIR/zones-rpz/}; tar -I pigz -cf ${_ID} zones-rpz"; f_do
printf "${_hnt} extract with: '${_GRN}'\nfollowed by '${_GRN}'\n" "unpigz -v ${_ID}" "tar -xvf ${_ID/.gz/}"
printf "${_inf} %-85s" "find and remove old RPZ-dBase archive in ${HOST}:/home"
_ssh root@"${HOST}" "find /home -regex '^.*\(tar.gz\)$' -mmin +1440 -print0 | xargs -0 -r rm"; f_do

# syncronizing latest RPZ-dBase to remote-host
printf "${_inf} %-85s" "syncronizing the latest RPZ-dBase to ${HOST}:${ZONE_DIR}"
_snc {rpz,db}.* root@"${HOST}":"${ZONE_DIR}"; f_do

# applying latest RPZ-dBase at remote-host
if [[ ${RNDC_RELOAD} =~ [yY][eE][sS] ]]; then
   # required sufficient RAM to executing "rndc reload"
   printf "execute ${_rnr} at BIND9-server:%s\n" "${HOST}"
   _ssh root@"${HOST}" "rndc reload"
else
   # ${HOST} will reboot after [shutdown -r $@ --no-wall] minutes due to low memory
   printf "${_wn1} remote-host: %s scheduled for ${_GRN}\n" "${HOST}" "reboot at ${_fkt}"
   _ssh root@"${HOST}" "shutdown -r 5 --no-wall >> /dev/null 2>&1"
   printf "${_hnt} use ${_shd} at host: %s to abort\n" "${HOST}"
fi

T="$(($(date +%s%N)-T))"; f_tim
exit 0
