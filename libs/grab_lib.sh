#!/usr/bin/env bash
# TAGS
#   grab_lib.sh
#   v6.2
# AUTHOR
#   ngadimin@warnet-ersa.net
# see README and LICENSE

shopt -s expand_aliases
alias _sort="LC_ALL=C sort --buffer-size=80% --parallel=3"
alias _sed="LC_ALL=C sed"
alias _grep="LC_ALL=C grep"
alias _ssh="ssh -q -T -c aes128-ctr -o Compression=no -x"
alias _rsync="rsync -rtxX -e 'ssh -q -T -c aes128-ctr -o Compression=no -x'"
_foo=$(basename "$0")
HOST="rpz.warnet-ersa.net"      # fqdn or ip-address

f_tmp() {   # remove temporary files/directories, array & function defined during the execution of the script
   find . -regextype posix-extended -regex "^.*(dmn|tmr|tm[pq]|txt.adulta).*|.*(gz|sex|rsk)$" -print0 | xargs -0 -r rm
   find . -type d ! -name "." -print0 | xargs -0 -r rm -rf
   find /tmp -maxdepth 1 -type f -name "txt.adult" -print0 | xargs -r0 mv -t .
   }

f_uset() { unset -v ar_{blanko,cat,db,dom,dmn,raw1,raw2,reg,rpz,sho,split,tmp,txt,url,zon} isDOWN; }
f_trap() { printf "\n"; f_tmp; f_uset; }

f_excod() {   # exit code {7..18}
   for EC in $1; do
      _lin=$(grep -n "^HOST" "$_foo" | cut -d":" -f1)
      local _xcod="[ERROR] $_foo: at line ${BASH_LINENO[0]}. Exit code: $EC"
      local _exit="[ERROR] $_foo: at line $_lin. Exit code: $EC"
      local _reff="https://en.wikipedia.org/wiki/List_of_HTTP_status_codes"
      case $EC in
          7) printf "\n\x1b[91m%s\x1b[0m\n%s\n" "$_xcod" "require passwordless ssh to remote host: '$2'"; exit 1;;
          8) printf "\n\x1b[91m%s\x1b[0m\n%s\n" "$_xcod" "require '$2' but it's not installed"; exit 1;;
          9) printf "\n\x1b[91m%s\x1b[0m\n%s\n" "$_xcod" "'$2' require '$3' but it's not installed"; exit 1;;
         10) printf "\n\x1b[91m%s\x1b[0m\n%s\n" "$_xcod" "you must login as non-root privileges"; exit 1;;
         11) printf "\n\x1b[91m%s\x1b[0m\n%s\n" "$_xcod" "$(basename "$2"): $(wc -l < "$2") urls. it's should consist of 21 urls"; exit 1;;
         12) printf "\n\x1b[91m%s\x1b[0m\n%s\n" "$_xcod" "$(basename "$2"): $(wc -l < "$2") lines. it's should consist of 4 lines"; exit 1;;
         13) printf "\x1b[91m[ERROR]\x1b[0m Check out [grab_urls]. if those url[s] are correct, please reffer to:\n\t%s\n" "$_reff"; exit 1;;
         14) printf "\n\x1b[91m%s\x1b[0m\n%s\n" "$_xcod" "download failed from '$2'"; exit 1;;
         15) printf "\n\x1b[91m%s\x1b[0m\n%s\n" "$_xcod" "category: must equal 6"; exit 1;;
         16) printf "%s\n\x1b[93m%s\x1b[0m: if these address is correct, maybe isDOWN\n%s\n" "$_exit" """$2""" "Incomplete TASK"; exit 1;;
         17) printf "\n\x1b[91m%s\x1b[0m\n%s\n" "$_xcod" "$(basename "$2"): doesn't exist"; exit 1;;
         18) printf "\n\x1b[91m%s\x1b[0m\n%s\n" "$_xcod" """$2"" doesn't exist in ""$3"""; exit 1;;
          *) printf "\n\x1b[91m[ERROR]\x1b[0m Unknown exit code [f_excod %s], please check:\n%s\n" "$1" "$(grep -n "f_excod $1" -- *.sh)"; exit 1;;
      esac
   done
   }

f_sm0() {   # getting options display messages
   printf "\n\x1b[93mCHOOSE one of the following options :\x1b[0m\n"
   printf "%4s. eliminating duplicate entries between domain lists\n" "1"
   printf "%4s. option [1] and rewriting all domain lists to RPZ format [db.* files]\n" "2"
   printf "%4s. options [1,2] and incrementing serial at zone files [rpz.*]\n" "3"
   printf "%4s. options [1,2,3] and [rsync]ronizing latest [rpz.* and db.*] files to %s\n" "4" "$1"
   printf "ENTER: \x1b[93m[1|2|3|4]\x1b[0m or [*] to QUIT\t"
   }

f_sm1() {   # display messages when 1'st option chosen
   printf "\n\x1b[91m[%s'st] TASK options chosen\x1b[0m\n" "$RETVAL"
   printf "\x1b[93mCONTINUED to :\x1b[0m ~eliminating duplicate entries between domain lists\n"
   printf "\x1b[93mPerforming task based on %s'st options ...\x1b[0m\n" "$RETVAL"
   }

f_sm2() {   # display messages when 2'nd option chosen
   f_sm5; printf "\x1b[93mPerforming task based on %s'th options ...\x1b[0m\n" "$RETVAL"
   }

f_sm3() {   # display messages when 3'th option chosen
   f_sm5; printf "%28s serial at zone files [rpz.*]\n" "~incrementing"
   printf "\x1b[93mPerforming task based on %s'th options ...\x1b[0m\n" "$RETVAL"
   }

f_sm4() {   # display messages when 4'th option chosen
   f_sm5; printf "%28s serial zone files [rpz.*]\n" "~incrementing"
   printf "%31s latest [rpz.* and db.*] files to %s\n" "~[rsync]ronizing" "$HOST"
   if grep -qE "^\s{2,}#s(*.*)d\"" grab_lib.sh; then
       printf "\x1b[32m%13s:\x1b[0m host %s will REBOOT due to low memory\n" "WARNING" "$HOST"
       printf "%18s \x1b[92m'shutdown -c'\x1b[0m at HOST: %s to abort\n" "use" "$HOST"
   fi
   printf "\x1b[93mPerforming task based on %s'th options ...\x1b[0m\n" "$RETVAL"
   }

f_sm5() {   # sub-function. must include in f_sm2 ... f_sm4
   printf "\n\x1b[91m[%s'th] TASK options chosen\x1b[0m\n" "$RETVAL"
   printf "\x1b[93mCONTINUED to :\x1b[0m ~eliminating duplicate entries between domain lists\n"
   printf "%25s all domain lists to RPZ format [db.* files]\n" "~rewriting"
   }


f_sm6() {   # display FINISH messages
   printf "\n[INFO] Completed \x1b[93mIN %s:%s\x1b[0m\n" "$1" "$2"
   printf "\x1b[32mWARNING:\x1b[0m there are still remaining duplicate entries between domain lists.\n"
   printf "%17s continue to next TASKs.\n" "consider"
   }

# display processing messages
f_sm7() { printf "%12s: %-64s\t" "grab_$1" "${2##htt*\/\/}"; }
f_sm8() { printf "\nProcessing \x1b[93m%s CATEGORY\x1b[0m with (%d) additional remote file(s)\n" "${1^^}" "$2"; }
f_sm9() { printf "%12s: %-64s\t" "fixing" "bads, duplicates and false entries at ${1^^}"; }
f_sm10() { printf "\n\x1b[91mTASKs\x1b[0m based on %s'%s options: \x1b[32mDONE\x1b[0m\n" "$RETVAL" "$1"; }
f_ok() { printf "\x1b[32m%s\x1b[0m\n" "isOK"; }         # display isOK
f_do() { printf "\x1b[32m%s\x1b[0m\n" "DONE"; }         # display DONE

f_add() { curl -C - -fs "$1" || f_excod 14 "$1"; }      # grabbing remote files

# fixing false positive and bad entry. Applied to all except ipv4 CATEGORY
f_falsf() { f_sm9 "$1"; _sort -u "$2" | _sed "/[^\o0-\o177]/d" | _sed -e "$4" -e "$5" > "$3"; }

f_falsg() { # throw ip-address entry to ipv4 CATEGORY, save in CIDR
   printf "%12s: %-64s\t" "moving" "IP-address entries into $3 CATEGORY"
   _grep -E "(?<=[^0-9.]|^)[1-9][0-9]{0,2}(\\.([0-9]{0,3})){3}(?=[^0-9.]|$)" "$1" | _sed "s/$/\/32/" >> "$2" || true
   _sed -Ei "/^([0-9]{1,3}\\.){3}[0-9]{1,3}$/d" "$1"
   f_do; printf "%12s: %'d entries.\n" "acquired" "$(wc -l < "$1")"
   }

f_syn() {   # passwordless ssh for "backUP oldDB and rsync newDB"
   # shellcheck disable=SC2154
   printf "\n\x1b[91m[4'th] TASKs:\x1b[0m\nStarting %s ... %s\n" "$(basename "$0")" "$start"
   if ping -w 1 "$HOST" >> /dev/null 2>&1; then
      _remdir="/etc/bind/zones-rpz/"
      _ssh root@"$HOST" [[ -d "$_remdir" ]] || f_excod 18 "$_remdir" "$HOST"
      mapfile -t ar_db < <(find . -maxdepth 1 -type f -name "db.*" | sed -e "s/\.\///" | sort)

      if [ "${#ar_db[@]}" -gt 12 ]; then
         printf "[ERROR] database exceeds expectations\n"
         printf "[HINTS] db.* files: %s NOT equal 12\n" "${#ar_db[@]}"
         return 1

      elif [ "${#ar_db[@]}" -lt 12 ]; then
         local _BLD="$_DIR"/grab_build.sh
         local _CRL="$_DIR"/grab_cereal.sh
         printf "NOT found db.* and rpz.* files. Try to [re]create them\n"
         "$_BLD"; "$_CRL"
         exec "$0"

      else
         mapfile -t ar_rpz < <(find . -maxdepth 1 -type f -name "rpz.*" | sed -e "s/\.\///" | sort)
         if [ "${#ar_db[@]}" -ne "${#ar_rpz[@]}" ]; then
            printf "[ERROR] something wrong with number of zone files (rpz.*)\n"
            printf "[HINTS] please double-check: grab_cereal.sh and number of zone files\n"
            printf "[HINTS] rpz.* files: %s NOT equal 12\n" "${#ar_rpz[@]}"
            return 1
         else
            # use [unpigz -v rpz-2022-04-09.tar.gz] then [tar xvf rpz-2022-04-09.tar] for decompression
            local _ts; local _ID; _ts=$(date "+%Y-%m-%d"); _ID="/home/rpz-$_ts.tar.gz"
            printf "[INFO] archiving oldDB, save in root@%s:%s\n" "$HOST" "$_ID"
            _ssh root@"$HOST" "cd /etc/bind; tar -I pigz -cf $_ID zones-rpz"
            printf "[INFO] find and remove old RPZ dBase archive in %s:/home\n" "$HOST"
            _ssh root@"$HOST" "find /home -regextype posix-extended -regex '^.*(tar.gz)$' -mmin +1430 -print0 | xargs -0 -r rm"
            printf "[INFO] syncronizing the latest RPZ dBase to %s:%s\n" "$HOST" "$_remdir"
            _rsync {rpz,db}.* root@"$HOST":"$_remdir"

            # reboot [after +@ minute] due to low memory
            printf "[INFO] host: \x1b[92m%s\x1b[0m scheduled for reboot at %s\n" "$HOST" "$(faketime -f "+5m" date +%H:%M:%S)"
            _ssh root@"$HOST" "shutdown -r 5 --no-wall >> /dev/null 2>&1"
            printf "[INFO] use \x1b[92m'shutdown -c'\x1b[0m at host: %s to abort\n" "$HOST"

            # OR comment 3 lines above AND uncomment 2 lines below, if you have sufficient RAM
            #printf "Reload BIND9-server:%s\n" "$HOST"
            #ssh root@"$HOST" "rndc reload"   # DON'T add space after "#". it's use by this script at line 78
         fi
      fi
   else
      f_excod 16 "$HOST"
   fi
   }

f_crawl() {   # verify "URLS" isUP
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
      printf "%30s\n" " " | tr " " -
      printf "%s\n" "All URLS of remote files isUP."
   else
      printf "%84s\n" " " | tr " " -
      printf "\x1b[91m%s\x1b[0m\n" "${isDOWN[@]}"
      f_excod 13
   fi
   }

f_dupl() { printf "eliminating duplicate entries based on \x1b[93m%s\x1b[0m\n" "${1^^}"; }
f_ddup() {  # used by grab_dedup.sh
   printf "%11s = deduplicating %s entries \t\t" "STEP 0.$1" "$2"
   _sort "$3" "$4" | uniq -d | _sort -u > "$5"
   }

f_g4b() {   # used by grab_build.sh
   local _tag; _tag=$(grep -P "^#\s{2,}v.*" "$_foo" | cut -d" " -f4)
   sed -i -e "1i ; generate at \[$(date -u "+%d-%b-%y %T") UTC\] by $_foo $_tag\n;" "$1"
   printf -v acq_al "%'d" "$(wc -l < "$1")"
   printf "%10s entries\n" "$acq_al"
   }

f_g4c() {   # used by grab_cereal.sh
   local _tag; _tag=$(grep -P "^#\s{2,}v.*" "$_foo" | cut -d" " -f4)
   sed -i "1s/^.*$/; generate at \[$(date -u "+%d-%b-%y %T") UTC\] by $_foo $_tag/" "$1"
   }

f_rpz() {   # used by grab_build.sh
   printf "%13s %-27s : " "rewriting" "${3^^} to $1"
   awk '{print $0" IN CNAME .""\n""*."$0" IN CNAME ."}' "$2" >> "$1"
   f_g4b "$@"
   }

f_ip4() {   # used by grab_build.sh
   printf "%13s %-27s : " "rewriting" "${3^^} to $1"
   awk -F. '{print $5"."$4"."$3"."$2"."$1".rpz-nsip"" CNAME ."}' "$2" >> "$1"
   f_g4b "$@"
   }

f_cer() {   # used by grab_cereal.sh to copy zone-files
   if ping -w 1 "$HOST" >> /dev/null 2>&1; then
      local _remdir; _remdir="/etc/bind/zones-rpz"
      # passwordless ssh
      _ssh -o BatchMode=yes "$HOST" /bin/true  >> /dev/null 2>&1 || f_excod 7 "$HOST"
      _ssh root@"$HOST" [[ -d "$_remdir" ]] || f_excod 18 "'_remdir'" "$HOST"

      local miss; miss="$(cat /tmp/mr_p)"
      if ! scp -qr root@"$HOST":"$_remdir"/rpz.* "$_DIR" >> /dev/null 2>&1; then
         printf "[INFO] One or more zone files are missing. %s\n" "You should create:"
         printf "~ %s\n\x1b[91m[ERROR]\x1b[0m %s\n" "$miss" "Incomplete TASK"
         return 1
      else
         printf "[INFO] Successfully copied:\n~ %s\n" "$miss"
         printf "[INFO] Retry running TASK again\n"
         exec "$0"
      fi

   else
      f_excod 16 "$HOST"
   fi
   }
