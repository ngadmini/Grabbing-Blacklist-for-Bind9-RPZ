#!/usr/bin/env bash
# TAGS
#   grab_lib.sh
#   v4.2
# AUTHOR
#   ngadimin@warnet-ersa.net

shopt -s expand_aliases
alias _sort="LC_ALL=C sort --buffer-size=80% --parallel=3"
alias _sed="LC_ALL=C sed"
alias _grep="LC_ALL=C grep"
_foo=$(basename "$0")

f_tmp() {   # remove temporary files/directories, array & function defined during the execution of the script
   find . -regextype posix-extended -regex '^.*(dmn|tmr|tm[pq]|txt.adulta).*|.*(gz|sex|rsk)$' -print0 | xargs -0 -r rm
   find . -type d ! -name "." -print0 | xargs -0 -r rm -rf
   find /tmp -maxdepth 1 -type f -name "txt.adult" -print0 | xargs -r0 mv -t .
   }

f_trap() {
   printf "\n"; f_tmp;
   unset -v ar_{cat,db,dom,dmn,reg,rpz,sho,tmp,txt,url} isDOWN
   }

f_excod() {   # exit code {9..18}
   for EC in $1; do
      _lin=$(grep -n '^HOST' "$_foo" | cut -d':' -f1)
      local _xcod="[$_foo]: at line ${BASH_LINENO[0]}. Exit error $EC"
      local _exit="[$_foo]: at line $_lin. Exit error $EC"
      local _reff="https://en.wikipedia.org/wiki/List_of_HTTP_status_codes"
      case $EC in
         10) printf "\n%s\n%s\n" "$_xcod" "you must login as non-root"; exit 1;;
         11) printf "\n%s\n%s\n" "$_xcod" "[$(basename "$2")]: $(wc -l < "$2") urls. it should consist of 21 urls"; exit 1;;
         12) printf "\n%s\n%s\n" "$_xcod" "[$(basename "$2")]: $(wc -l < "$2") lines. it should consist of 4 lines"; exit 1;;
         13) printf "Check out [grab_urls]. if those url[s] are correct,\nplease reffer to: %s\n" "$_reff"; exit 1;;
         14) printf "\n%s\n%s\n" "$_xcod" "download failed from ""$2"""; exit 1;;
         15) printf "\n%s\n%s\n" "$_xcod" "[category]: must equal 6"; exit 1;;
         16) printf "%s\n[\x1b[93m$HOST\x1b[0m]: if these address is correct, maybe isDOWN\n%s\n" "$_exit" "Incomplete TASK"; exit 1;;
         17) printf "\n%s\n%s\n" "$_xcod" "[$(basename "$2")]: doesn't exist"; exit 1;;
          *) printf "\nUnknown exit code [f_excod %s], please check:\n%s\n" "$1" "$(grep -n "f_excod $1" -- *.sh)"; exit 1;;
      esac
   done
   }

f_sm0() {   # getting options display messages
   printf "\n\x1b[93mCHOOSE one of the following options :\x1b[0m\n"
   printf "%4s. eliminating duplicate entries between domain lists\n" "1"
   printf "%4s. option [1] and rewriting all domain lists to RPZ format [db.* files]\n" "2"
   printf "%4s. option [1,2] and incrementing serial at zone files [rpz.*]\n" "3"
   printf "%4s. option [1,2,3] and [rsync]ronizing latest [rpz.* and db.*] files to %s\n" "4" "$1"
   printf "ENTER: \x1b[93m[1|2|3|4]\x1b[0m or [*] to QUIT\t"
   }

f_sm1() {   # display messages when 1'st option chosen
   f_sm11
   printf "\x1b[93mPerforming task based on %s'th option ...\x1b[0m\n" "$RETVAL"
   }

f_sm2() {   # display messages when 2'nd option chosen
   f_sm11
   printf "%25s all domain lists to RPZ format [db.* files]\n" "~rewriting"
   printf "\x1b[93mPerforming task based on %s'th option ...\x1b[0m\n" "$RETVAL"
   }

f_sm3() {   # display messages when 3'th option chosen
   f_sm11
   printf "%25s all domain lists to RPZ format [db.* files]\n" "~rewriting"
   printf "%28s serial at zone files [rpz.*]\n" "~incrementing"
   printf "\x1b[93mPerforming task based on %s'th option ...\x1b[0m\n" "$RETVAL"
   }

f_sm4() {   # display messages when 4'th option chosen
   f_sm11
   printf "%25s all domain lists to RPZ format [db.* files]\n" "~rewriting"
   printf "%28s serial zone files [rpz.*]\n" "~incrementing"
   printf "%31s latest [rpz.* and db.*] files to %s\n" "~[rsync]ronizing" "$1"
   if grep -qE "^\s{2,}#s(*.*)d\"" grab_lib.sh; then
       printf "\x1b[32m%13s:\x1b[0m host %s will REBOOT due to low memory\n" "WARNING" "$1"
       printf "%18s \x1b[92m'shutdown -c'\x1b[0m at HOST: %s to abort\n" "use" "$1"
   fi
   printf "\x1b[93mPerforming task based on %s'th option ...\x1b[0m\n" "$RETVAL"
   }

f_sm5() { printf "\x1b[32m%s\x1b[0m\n" "DONE"; }      # display DONE

f_sm6() {   # display FINISH messages
   printf "completed \x1b[93mIN %s:%s\x1b[0m\n" "$1" "$2"
   printf "\x1b[32mWARNING:\x1b[0m there are still remaining duplicate entries between domain lists.\n"
   printf "%17s continue to next TASK.\n" "consider"
   }

# display processing messages
f_sm7() { printf "%12s: %-64s\t" "grab_$1" "${2##htt*\/\/}"; }
f_sm8() { printf "\nProcessing \x1b[93m%s CATEGORY\x1b[0m with (%d) additional remote file(s)\n" "${1^^}" "$2"; }
f_sm9() { printf "%12s: %-64s\t" "fixing" "bads, duplicates and false entries at ${1^^}"; }
f_sm10() { printf "\n\x1b[91mTASK[s]\x1b[0m based on %s'%s options: \x1b[32mDONE\x1b[0m\n" "$RETVAL" "$1"; }
f_sm11() {
   printf "\n%s'st TASK option chosen\n" "$RETVAL"
   printf "\x1b[93mCONTINUED to :\x1b[0m ~eliminating duplicate entries between domain lists\n"
   }

f_add() { curl -C - -fs "$1" || f_excod 14 "$1"; }      # grabbing remote files

# fixing false positive and bad entry. Applied to all except ipv4 CATEGORY
f_falsf() { f_sm9 "$1"; _sort -u "$2" | _sed '/[^\o0-\o177]/d' | _sed -e "$4" -e "$5" > "$3"; }

f_falsg() { # throw ip-address entry to ipv4 CATEGORY
   printf "%12s: %-64s\t" "moving" "IP-address entries into $3 CATEGORY"
   _grep -E "(?<=[^0-9.]|^)[1-9][0-9]{0,2}(\\.([0-9]{0,3})){3}(?=[^0-9.]|$)" "$1" >> "$2" || true
   _sed -Ei "/^([0-9]{1,3}\\.){3}[0-9]{1,3}$/d" "$1"
   f_sm5
   printf "%12s: %'d entries.\n" "acquired" "$(wc -l < "$1")"
   }

f_syn() {   # passwordless ssh to BIND9-server for "backUP oldDB and rsync newDB"
   printf "\n\x1b[91m[4'th] TASK:\x1b[0m\n"
   if ping -w 1 "$1" >> /dev/null 2>&1; then
      mapfile -t ar_db < <(find . -maxdepth 1 -type f -name "db.*" | sed -e 's/\.\///' | sort)
      mapfile -t ar_rpz < <(find . -maxdepth 1 -type f -name "rpz.*" | sed -e 's/\.\///' | sort)
      if [ "${#ar_db[@]}" -eq 11 ] && [ "${#ar_rpz[@]}" -eq 11 ]; then
         local timestamp; timestamp=$(date "+%Y-%m-%d")
         local _ID; _ID="/home/rpz-$timestamp.tar.gz"
         #
         printf "Create archive of RPZ dBase in %s:%s\n" "$1" "$_ID"
         ssh -q root@"$1" "cd /etc/bind; tar -I 'gzip -1' -cf $_ID zones-rpz"
         printf "Find and remove old RPZ dBase archive in %s:/home\n" "$1"
         ssh -q root@"$1" "find /home -regextype posix-extended -regex '^.*(tar.gz)$' -mmin +1430 -print0 | xargs -0 -r rm"
         printf "Syncronizing the latest RPZ dBase to %s\n" "$1"
         mkdir zones-rpz; mv {rpz,db}.* zones-rpz
         rsync -aqW zones-rpz/ root@"$1":/etc/bind/zones-rpz/
         # reboot [after +@ minute] due to low memory
         printf "HOST: \x1b[92m%s\x1b[0m scheduled for reboot at %s\n" "$1" "$(faketime -f '+5m' date +%H:%M:%S)"
         ssh root@"$1" "shutdown -r 5 --no-wall >> /dev/null 2>&1"
         # OR comment 3 lines above AND uncomment 2 lines below, if you have enough memory
         #printf "Reload BIND9-server\n"
         #ssh root@"$1" "rndc reload"
         mv zones-rpz/{rpz,db}.* .
      else
         local _BLD="$_DIR"/grab_build.sh
         local _CRL="$_DIR"/grab_cereal.sh
         printf "NOT found db.* and rpz.* files. Try to [re]create them\n"
         "$_BLD"; "$_CRL"
         exec "$0"
      fi
   else
      f_excod 16
   fi
   }

f_crawl() { # verify "URLS" isUP
   isDOWN=(); local i=-1
   while IFS= read -r line || [[ -n "$line" ]]; do
      # slicing urls && add element to ${ar_sho[@]}
	   local lll; local ll; local l; local p_url
      lll="${line##htt*\/\/}"; ll="$(basename "$line")"; l="${lll/\/*/}"; p_url="$l/..?../$ll"
      ar_sho+=("${p_url}"); ((i++))
      printf "%12s: %-64s\t" "urls_${i}" "${ar_sho[i]}"
      statusCode=$(curl -C - -ks -o /dev/null -I -w "%{http_code}" "$line")
      # https://trustpositif.kominfo.go.id/assets/db/domains give me "$statusCode" 405 = Method Not Allowed
      if [[ "$statusCode" != 2* && "$statusCode" != 405 ]]; then
         printf "\x1b[91m%s\x1b[0m\n" "Code: $statusCode"
         isDOWN+=("[Respon Code:${statusCode}] ${line}")    # add element to ${isDOWN[@]}
      else
         printf "\x1b[32m%s\x1b[0m\n" "isUP"
      fi
   done < "$1"
   local isDOWNCount=${#isDOWN[@]}
   if [ "$isDOWNCount" -eq 0 ]; then
      printf "%30s\n" " " | tr ' ' -
      printf "%s\n" "All URLS of remote files isUP."
   else
      printf "%20s\n" " " | tr ' ' -
      printf "\x1b[91m%s\x1b[0m\n" "${isDOWN[@]}"
      f_excod 13
   fi
   }

f_ddup() {  # used by grab_dedup.sh
   printf "%11s = deduplicating %s entries \t\t" "STEP 0.$1" "$2"
   _sort "$3" "$4" | uniq -d | _sort -u > "$5"
   }

f_dupl() { printf "eliminating duplicate entries based on \x1b[93m%s\x1b[0m\n" "${1^^}"; }

f_app() {   # used by grab_build.sh
   local _tag; _tag=$(grep -P "^#\s{2,}v.*" "$_foo" | cut -d' ' -f4)
   sed -i -e "1i ; generate at \[$(date -u '+%d-%b-%y %T') UTC\] by $_foo $_tag\n;" "$1"
   printf -v acq_al "%'d" "$(wc -l < "$1")"
   printf "%10s entries\n" "$acq_al"
   }

f_net() {   # add "/24 - /31 subnet" to ipv4 category. NOT coverred by grab_http.sh
   local _url; _url="https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level3.netset"
   f_add  "$_url" | _grep '\/[0-9]\{2\}$' | _sed 's/\//\./g' | _sort -n -t . -k1,1 -k2,2 -k3,3 -k4,4 -k5,5 \
      | awk -F. '{print ""$5"."$4"."$3"."$2"."$1".rpz-nsip"" CNAME ."}' >> "$1"
   }

f_rpz() {
   printf "%13s %-27s : " "rewriting" "${3^^} to $1"
   awk '{print $0" IN CNAME .""\n""*."$0" IN CNAME ."}' "$2" >> "$1"
   f_app "$@"
   }

f_ip4() {
   printf "%13s %-27s : " "rewriting" "${3^^} to $1"
   awk -F. '{print "32."$4"."$3"."$2"."$1".rpz-nsip"" IN CNAME ."}' "$2" >> "$1"
   f_net "$@"; f_app "$@"
   }
