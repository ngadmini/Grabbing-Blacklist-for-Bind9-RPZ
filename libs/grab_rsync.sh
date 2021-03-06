#!/usr/bin/env bash
# TAGS
#   grab_rsync.sh
#   v7.2
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

# check properties: db-files & zone-files at local-host
printf "\n${_inf} check availability: RPZ-dBase and zone-files in local-host: %-25s" "$(hostname -I)"
mapfile -t ar_dbc < <(f_fnd "db.*")
miss_DBC=$(echo "${ar_DBC[@]}" "${ar_dbc[@]}" | f_sed)
printf -v req_DBC "%s\n%s" "${ar_DBC[*]:0:6}" "${ar_DBC[*]:6:6}"
if ! [[ ${ar_dbc[*]} == "${ar_DBC[*]}" ]]; then f_mis "${miss_DBC}" "${req_DBC}"; fi

mapfile -t ar_rpz < <(f_fnd "rpz.*")
miss_RPZ=$(echo "${ar_RPZ[@]}" "${ar_rpz[@]}" | f_sed)
printf -v req_RPZ "%s\n%s" "${ar_RPZ[*]:0:6}" "${ar_RPZ[*]:6:6}"
if ! [[ ${ar_rpz[*]} == "${ar_RPZ[*]}" ]]; then f_mis "${miss_RPZ}" "${req_RPZ}"; fi

for PERM in {"${ar_dbc[@]}","${ar_rpz[@]}"}; do f_sta 640 "${PERM}"; done
f_ok; f_ssh   # end of check

# archieving old RPZ-dBase at remote-host
_cd=$(basename "$ZONE_DIR")
printf -v _ID "/home/rpz-%s.tar.gz" "$(date +%Y%m%d-%H%M%S)"
printf "${_inf} %-85s" "archiving stale RPZ-dBase in ${HOST}:${_ID}"
_ssh root@"${HOST}" "cd ${ZONE_DIR/$_cd/}; tar -I pigz -cf ${_ID} ${_cd}"; f_do
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
