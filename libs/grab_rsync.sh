#!/usr/bin/env bash
# TAGS
#   grab_rsync.sh v10.3
#   https://github.com/ngadmini
# AUTHOR
#   ngadimin@warnet-ersa.net
# TL;DR
#   see README and LICENSE

T=$(date +%s%N)
set -Eeuo pipefail
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
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

f_stt "[4'th] TASKs:"
printf "${_inf} %-85s" "check availability configuration file"
f_cnf; [[ ! ${UID} -eq 0 ]] || f_xcd 247

ar_DBC=(db.adultaa db.adultab db.adultac db.adultad db.adultae db.adultaf db.adultag \
   db.ipv4 db.malware db.publicite db.redirector db.trust+aa db.trust+ab)
ar_RPZ=(rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf rpz.adultag \
   rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+aa rpz.trust+ab)

# check db-files & zone-files at local-host
printf "${_inf} check availability: RPZ-dBase and zone-files in local-host: %-25s" "$(hostname -I)"
mapfile -t ar_dbc < <(f_fnd "db.*")   # check db-files
miss_DBC=$(echo "${ar_DBC[@]}" "${ar_dbc[@]}" | f_sed)
printf -v need_DBC "%s\n%s" "${ar_DBC[*]:0:7}" "${ar_DBC[*]:7:6}"
if ! [[ ${ar_dbc[*]} == "${ar_DBC[*]}" ]]; then f_mis "${miss_DBC}" "${need_DBC}"; fi

mapfile -t ar_rpz < <(f_fnd "rpz.*")   # check zone-files
miss_RPZ=$(echo "${ar_RPZ[@]}" "${ar_rpz[@]}" | f_sed)
printf -v need_RPZ "%s\n%s" "${ar_RPZ[*]:0:7}" "${ar_RPZ[*]:7:6}"
if ! [[ ${ar_rpz[*]} == "${ar_RPZ[*]}" ]]; then f_mis "${miss_RPZ}" "${need_RPZ}"; fi

# file's permission and ownership should be 640 root:bind
for PERM in {"${ar_dbc[@]}","${ar_rpz[@]}"}; do f_sta 640 "${PERM}"; done; f_ok

f_ssh   # check db-files & zone-files of ${HOST} & archieving the stale
printf -v _ID "/home/rpz-%s.tar.gz" "$(date +%Y%m%d-%H%M%S)"
printf "${_inf} %-85s" "archiving stale RPZ-dBase in ${HOST}:${_ID}"
_ssh root@"${HOST}" "tar -czf ${_ID} --absolute-names ${ZONE_DIR}
   find /home -regex '^.*\(tar.gz\)$' -mmin +1440 -print0 | xargs -0 -r rm"
f_do

# syncronizing latest db-files & zone-files to ${HOST}
printf "${_inf} %-85s" "syncronizing the latest RPZ-dBase to ${HOST}:${ZONE_DIR}"
_snc {rpz,db}.* root@"${HOST}":"${ZONE_DIR}"; f_do

if [[ ${RNDC_RELOAD} =~ [yY][eE][sS] ]]; then   # applying latest RPZ-dBase at remote-host
   printf "execute ${_rnr} at BIND9-server:%s\n" "${HOST}"
   _ssh root@"${HOST}" "rndc reload"  # require sufficient RAM to exec "rndc reload"
else                                  # ${HOST} will reboot after [shutdown -r $@ --no-wall]
   _fkt="$(faketime -f "+5m" date +%I:%M:%S\ %p\ %Z)"   #+  minutes, due to low memory
   printf "${_wn1} remote-host: %s has scheduled to reboot at ${_GRN}\n" "${HOST}" "${_fkt}"
   _ssh root@"${HOST}" "shutdown -r 5 --no-wall >> /dev/null 2>&1"
   printf "${_hnt} use ${_shd} at host: %s to abort\n" "${HOST}"
fi

f_end
