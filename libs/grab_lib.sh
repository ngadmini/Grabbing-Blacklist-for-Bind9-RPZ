#!/usr/bin/env bash
# TAGS
#   grab_lib.sh
#   v2.2
# AUTHOR
#   ngadimin@warnet-ersa.net

shopt -s expand_aliases
alias _sort="LC_ALL=C sort --buffer-size=80% --parallel=3"
alias _sed="LC_ALL=C sed"
alias _grep="LC_ALL=C grep"

f_tmp() {   # remove temporary files/directories, array & function defined during the execution of the script
   find . -regextype posix-extended -regex '^.*(dmn|tmr|tm[pq]|txt.adulta).*|.*(gz|sex|rsk)$' -print0 | xargs -0 -r rm
   find . -type d ! -name "." -print0 | xargs -0 -r rm -rf
   find /tmp -maxdepth 1 -type f -name "txt.adult" -print0 | xargs -r0 mv -t .
   }

f_trap() {
   printf "\n"; f_tmp;
   unset -v ar_{cat,dom,dmn,reg,sho,tmp,txt,url} isDOWN
   }

f_excod() {   # exit code {9..18}
   for EC in $1; do
      local excod="$0: Exit error $EC"
      local p_ref="https://en.wikipedia.org/wiki/List_of_HTTP_status_codes"
      case $EC in
          9)   printf "\n%s\n%s\n" "you must login as non-root" "$excod"; exit 9;;
         10)   printf "\n%s\n%s\n" "supplied file: \"$2\" doesn't executable" "$excod"; exit 10;;
         11)   printf "\n%s\n%s\n" "grab_urls: must contain 21 lines" "$excod"; exit 11;;
         12)   printf "\n%s\n%s\n" "greb_regex: must contain 4 lines" "$excod"; exit 12;;
         13)   printf "%s\nPlease reffer to '%s'\n" "$excod" "$p_ref"; exit 13;;
         14)   printf "\n%s\n%s\n" "download failed" "$excod"; exit 14;;
         15)   printf "\n%s\n%s\n" "category: must equal 6" "$excod"; exit 15;;
         16)   printf "HOST = \x1b[93m$HOST\x1b[0m if that address is correct, maybe DOWN\n%s\n%s\n" "Incomplete TASK" "$excod"; exit 16;;
         17)   printf "\n%s\n%s\n" "file: \"$2\" doesn't exist" "$excod"; exit 17;;
          *)   printf "\nUNKNOWN ERROR\n"; exit 18;;
      esac
   done
   }

f_sm0() {   # getting options display messages
   printf "\n\x1b[93mCHOOSE one of the following options :\x1b[0m\n"
   printf "%4s. eliminating duplicate entries between domain lists\n" "1"
   printf "%4s. option [1] and rewriting all domain lists to RPZ format (db.* files)\n" "2"
   printf "%4s. option [1,2] and incrementing serial at zone files (rpz.* files)\n" "3"
   printf "%4s. option [1,2,3] and copying latest rpz.* and db.* files to %s\n" "4" "$1"
   printf "ENTER choice number \x1b[93m[1-4]\x1b[0m or [*] to QUIT\t"
   }

f_sm1() {   # display messages when 1'st option chosen
   printf "\n%s'st TASK option chosen\n" "$RETVAL"
   printf "\x1b[93mCONTINUED to :\x1b[0m ~eliminating duplicate entries between domain lists\n"
   printf "\x1b[93mPerforming task based on %s'st option ...\x1b[0m\n" "$RETVAL"
   }

f_sm2() {   # display messages when 2'nd option chosen
   printf "\n%s'nd TASK option chosen\n" "$RETVAL"
   printf "\x1b[93mCONTINUED to :\x1b[0m ~eliminating duplicate entries between domain lists\n"
   printf "%25s all domain lists to RPZ format (db.* files)\n" "~rewriting"
   printf "\x1b[93mPerforming task based on %s'nd option ...\x1b[0m\n" "$RETVAL"
   }

f_sm3() {   # display messages when 3'th option chosen
   printf "\n%s'th TASK option chosen\n" "$RETVAL"
   printf "\x1b[93mCONTINUED to :\x1b[0m ~eliminating duplicate entries between domain lists\n"
   printf "%25s all domain lists to RPZ format (db.* files)\n" "~rewriting"
   printf "%28s serial at zone files (rpz.* files)\n" "~incrementing"
   printf "\x1b[93mPerforming task based on %s'th option ...\x1b[0m\n" "$RETVAL"
   }

f_sm4() {   # display messages when 4'th option chosen
   printf "\n%s'th TASK option chosen\n" "$RETVAL"
   printf "\x1b[93mCONTINUED to :\x1b[0m ~eliminating duplicate entries between domain lists\n"
   printf "%25s all domain lists to RPZ format (db.* files)\n" "~rewriting"
   printf "%28s serial zone files (rpz.* files)\n" "~incrementing"
   printf "%23s latest rpz.* and db.* files to %s\n" "~copying" "$1"
   printf "\x1b[32m%13s:\x1b[0m %s will REBOOT due to low memory\n" "WARNING" "$1"
   printf "%18s \x1b[92m'shutdown -c'\x1b[0m at remote HOST to abort\n" "use"
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
f_sm8() { printf "\nProcessing for \x1b[93m%s CATEGORY\x1b[0m with (%d) additional remote file(s)\n" "${1^^}" "$2"; }
f_sm9() {
   ms="bads, duplicates and false entries at ${1^^}"
   printf "%12s: %-64s\t" "fixing" "$ms"
   }

# display new task messages when getting options
f_sm10() { printf "\n\x1b[91mTASK[s]\x1b[0m based on %s'%s options: \x1b[32mDONE\x1b[0m\n" "$RETVAL" "$1"; }

f_add() { curl -C - -fs "$1" || f_excod 14; }      # grabbing remote files

# fixing false positive and bad entry. Applied to all except ipv4 CATEGORY
f_falsf() { f_sm9 "$1"; _sort -u "$2" | _sed '/[^\o0-\o177]/d' | _sed -e "$4" -e "$5" > "$3"; }

f_falsg() { # throw ip-address entry to ipv4 CATEGORY
   mvip="IP-address entries into $3 CATEGORY"
   printf "%12s: %-64s\t" "moving" "$mvip"
   _grep -E "(?<=[^0-9.]|^)[1-9][0-9]{0,2}(\\.([0-9]{0,3})){3}(?=[^0-9.]|$)" "$1" >> "$2" || true
   _sed -Ei "/^([0-9]{1,3}\\.){3}[0-9]{1,3}$/d" "$1"
   f_sm5
   printf "%12s: %'d entries.\n" "acquired" "$(wc -l < "$1")"
   }

f_scp() {   # passwordless ssh to BIND9-server for "backUP and sending the newDB"
   printf "\n\x1b[91m[4'th] TASK:\x1b[0m\n"
   if ping -w 1 "$1" >> /dev/null 2>&1; then
      timestamp=$(date "+%Y-%m-%d")
      dbID="/home/rpz-$timestamp.tar.gz"
      #
      printf "Create archive dBase RPZ : %s\n" "$dbID"
      ssh -q root@"$1" "cd /etc/bind; tar -czf $dbID zones-rpz"
      printf "Find and remove old RPZ's archive file \n"
      ssh -q root@"$1" "find /home -regextype posix-extended -regex '^.*(tar.gz)$' -mmin +1430 -print0 | xargs -0 -r rm"
      printf "Copying latest RPZ dBase files to %s\n" "$1"
      scp -q {db,rpz}.* root@"$1":/etc/bind/zones-rpz
      # reboot [after +@ minute] due to low memory
      printf "HOST : \x1b[92m%s\x1b[0m scheduled for reboot at %s WIB\n" "$1" "$(faketime -f '+5m' date +%H:%M:%S)"
      ssh root@"$1" "shutdown -r --no-wall >> /dev/null 2>&1"
      # OR comment 2 lines above AND uncomment 2 lines below, if have enough memory
      #printf "Reload BIND9-server\n"
      #ssh root@"$1" "rndc reload"
   else
      f_excod 16
   fi
   }

f_crawl() { # verify "URLS" isUP
   isDOWN=(); local i=-1
   while IFS= read -r line || [[ -n "$line" ]]; do
      # slicing urls && add element to ${ar_sho[@]}
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
      printf "%20s\n" " " | tr ' ' -
      printf "%s\n" "All URLS of remote file isUP."
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

f_rpz() {   # used by grab_build.sh
   append=$(grep -P "^#\tv.*" "$(basename "$0")" | cut -d$'\t' -f 2)
   printf "%13s %-27s : " "rewriting" "${3^^} to $1"
   awk '{print $0" IN CNAME ."}'  "$2" >> "$1"
   awk '{print "*."$0" IN CNAME ."}' "$2" >>  "$1"
   sed -i -e "1i ; generate at $(date -u '+%F %T') UTC by $(basename "$0") $append\n;" "$1"
   printf -v acq_al "%'d" "$(wc -l < "$1")"
   printf "%10s entries\n" "$acq_al"
   }
