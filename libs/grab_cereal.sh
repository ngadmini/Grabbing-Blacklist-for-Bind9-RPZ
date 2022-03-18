#!/usr/bin/env bash
# TAGS
#	grab_cereal.sh
#	v2.2
# AUTHOR
#	ngadimin@warnet-ersa.net

SOURCED=false && [ "$0" = "${BASH_SOURCE[0]}" ] || SOURCED=true
if ! $SOURCED; then set -Eeuo pipefail; fi
PATH=/bin:/usr/bin:/usr/local/bin:$PATH
_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

printf "\n\x1b[91m[3'th] TASK:\x1b[0m\nIncrementing serial of zone files (rpz.* files)\n"
mapfile -t ar_zon < <(find . -maxdepth 1 -type f -name "rpz.*" | sed -e 's/\.\///' | sort)
if [ "${#ar_zon[@]}" -eq 11 ]; then
	printf "FOUND:\t%s complete\n" "${#ar_zon[@]}"
	for each in "${ar_zon[@]}"; do
		DATE=$(date +%Y%m%d)
		SERIAL=$(grep "SOA" "$each" | cut -d \( -f 2 | cut -d ' ' -f 1)
		if [ ${#SERIAL} -lt ${#DATE} ]; then
			newSERIAL="${DATE}00"
		else
			# 20190104
			SERIAL_date=${SERIAL::-2}
			# same day
			if [ "$DATE" -eq "$SERIAL_date" ]; then
				# 04 (max used 99 times)
				SERIAL_num=${SERIAL: -2}
				# force decimal increment
				SERIAL_num=$((10#$SERIAL_num + 1))
				newSERIAL="${DATE}$(printf '%02d' $SERIAL_num)"
			else
				newSERIAL="${DATE}00"
			fi
		fi
		sed -i -e 's/'"$SERIAL"'/'"$newSERIAL"'/g' "$each"
	done
	printf "all serial zones incremented to \x1b[93m%s\x1b[0m\n" "$newSERIAL"

else
	HOST="rpz.warnet-ersa.net"
	ar_rpz=( "rpz.adultaa" "rpz.adultab" "rpz.adultac" "rpz.adultad" "rpz.adultae" "rpz.adultaf" \
				"rpz.ipv4" "rpz.malware" "rpz.publicite" "rpz.redirector" "rpz.trust+" )
	printf "\n\x1b[91mFAILED due to:\x1b[0m FOUND %s of 11 zone files:\n%s\n" "${#ar_zon[@]}" "${ar_zon[*]}"
	printf "TRYING to get them from origin: %s\n" "$HOST"
	if ping -w 1 "$HOST" >> /dev/null 2>&1; then
		# passwordless ssh
		scp -qr root@"$HOST":/etc/bind/zones-rpz/"${ar_rpz[*]}" "$_DIR" >> /dev/null 2>&1 || \
		mapfile -t ar_scp < <(find . -maxdepth 1 -type f -name "rpz.*" | sed -e 's/\.\///' | sort)
		if [ "${#ar_scp[@]}" -ne 11 ]; then
			printf "FOUND: %s files. One or more zones files are missing, You should create:\n" "${#ar_scp[@]}"
			printf -v ar_diff "%s" "$(echo "${ar_rpz[@]}" "${ar_scp[@]}" | sed "s/ /\n/g" | sort | uniq -u)"
			printf "%s\n" "$ar_diff"
			exit 1
		else
			printf "COPIED:\t%s\n" "${ar_scp[*]}"
			printf "RETRY running TASK again\n"
			exec "$0"
		fi
	else
		printf "HOST = \x1b[93m%s\x1b[0m if that address is correct, maybe DOWN\n%s\n" "$HOST" "Incomplete TASK"
		exit 1
	fi
fi
unset -v ar_{zon,rpz,scp}
exit 0
