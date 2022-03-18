<h1 align="center">Grabbing Blacklist for Bind9 RPZ</h1>

<p align="center">
  	<b>Tailorized bash script pack to update domain list in BIND9 Response Policy Zone<br>
	Please consider adapting this pack to fit your environment properties,<br>
	since simple duplication may not given appropriate results</b><br>
	The partial output of this scripts can be found at link below</b><br>
  	<a href="https://github.com/ngadmini/partial-output"><img src="https://img.shields.io/badge/bind9%20RPZ-Partial%20Output-blue?style=flat-square&logo=github"></a>
  	<br><br>
  	<a href="#"><img src="http://s.4cdn.org/image/title/105.gif"></a>
</p>

### files
1. [grab_http.sh](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_http.sh) --grabbing and proccessing raw domains
2. [grab_dedup.sh](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_dedup.sh) --removing duplicate entries between domain lists
3. [grab_build.sh](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_build.sh) --rewriting to BIND9-rpz format
4. [grab_cereal.sh](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_cereal.sh) --incrementing serial zones
5. [grab_lib.sh](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_lib.sh) --contain some of functions needed by others script
6. [grab_urls](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_urls) --urls list of remote files, strick ordering and line counted. 
7. [grab_regex](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_regex) --list of reguler expressions for several purpose, strick ordering and line counted.
7. [grab_scp.sh](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_scp.sh) --scripts tool for copy, backup and update rpz-dBASE to host
8. [rpz.{adulta*,ipv4,malware,publicite,redirector,trust+}](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/tree/master/zones-rpz) --pack of zone-files
> <b>NOTE</b><br>Place theme all under the same directory
### requirements:
- [x] _curl faketime dos2unix shellcheck_. Install with `apt install -y curl faketime dos2unix shellcheck`
- [x] linux desktop, we use debian q4os as workstation
- [x] passwordless SSH to remote BIND9-server
- [x] BIND9 file structure : `/etc/bind9/zones-rpz` as place for all rpz database and zone-file.
### usage:
- [x] make executable all bash script `chmod +x *.sh`
- [x] tailorized to your environment. please see this [wiki](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/wiki/Fitting-Environment) to fitting your environment
- [x] just invoke `grab_http.sh` then follow the next step
### output:
- [x] new files with prefix `db.*` are data base for RPZ that ready to use at BIND9-server
- [x] modified files with prefix `rpz.*` are zone-files that ready to use too
- [x] new files with prefix `txt.*` are raw blacklist in categorized
- [x] a very small example output displayed at [exp-output](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/tree/master/exp-outpout)
### in the real world
the partial output of this script pack, can be found at [Partial Output](https://github.com/ngadmini/partial-output)
### others:
- [x] **Credits to** : All Owner-Maintener of sources-list in [grab_urls](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_urls), [KOMINFO NKRI](https://trustpositif.kominfo.go.id/assets/db/domains) and [shallalist](https://www.shallalist.de/index.html)
- [x] **Disclaimer** : These script are as they are, and to be used at your own risk
- [x] [![Grabbing Blacklist for Bind9 RPZ](https://img.shields.io/badge/LICENSE:-GNU%20General%20Public%20License-blue?style=flat-square&logo=github)](./LICENSE) 
 [![Grabbing Blacklist for Bind9 RPZ](https://img.shields.io/badge/FEEDBACK:-Issues-blue?style=flat-square&logo=github)](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/issues) 
 [![Grabbing Blacklist for Bind9 RPZ](https://img.shields.io/badge/FEEDBACK:-Dicussions-blue?style=flat-square&logo=github)](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/discussions)
 [![Grabbing Blacklist for Bind9 RPZ](https://img.shields.io/badge/USAGE:-Wiki-blue?style=flat-square&logo=github)](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/wiki)
