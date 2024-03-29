<h1 align="center">Grabbing Blacklisted Domains for Bind9-RPZ</h1>

<p align="center">
  	<b>Bash script-pack to update blacklisted domains in BIND9 Response Policy Zone<br>
	Please consider adapting this pack to fit your environment properties,<br>
	since simple duplication may not given appropriate results.<br>
	The partial output of this script-pack can be found at <a href="https://github.com/ngadmini/partial-output">this repo</a></b><br>
  	<a href="https://github.com/ngadmini/partial-output">
      <img src="https://img.shields.io/badge/bind9%20RPZ-Partial%20Output-blue?style=flat-square&logo=github">
   </a><br><br>
  	<a href="#"><img src="http://s.4cdn.org/image/title/105.gif"></a>
</p>

### featuring

- [x] free from duplicate entries and sub-domains entries (if it's parent-domain exist) across entire categories
- [x] free from invalid TLDs and domain entries that construct with international characters (non ASCII)
- [x] ip-address is written in CIDR block
- [x] updated RPZ dataBase and incremented serial-zones are syncronized to BIND9-server and propagate the new update

### script-pack
 1. [grab_http.sh][grab-http]  --grabbing and proccessing domains from [sources-list][grab-urls]
 2. [grab_duplic.sh][grab-dedup] --removing duplicate entries and sub-domains if parent domain exist
 3. [grab_build.sh][grab-build] --rewriting to Bind9-RPZ format-entry
 4. [grab_cereal.sh][grab-cereal] --incrementing serial number at [rpz.*][zone-file]
 5. [grab_library][grab-lib] --a library of functions. intended for use by other scripts, not to be executed directly
 6. [grab_urls][grab-urls] --urls of sources-list. case sensitive, sort as is, line count and no blank lines
 7. [grab_regex][grab-regex] --list of reguler expressions. case sensitive, sort as is, line count and no blank lines
 8. [grab_rsync.sh][grab-scp] --intended for syncronize latest dBASE to Bind9 host
 9. [grab_config][grab-cnf] --configurations file
10. [rpz.*][zone-file] --pack of zone-files
> <b>NOTE</b><br>Place them all under the same directory
### requirements:
- [x] please see [these wiki][wik-i] and [README](libs/README)
### usage:
- [x] execute `grab_http.sh` with `non root privileges` either directly as a `root user` or by use of `sudo command`, from your linux desktop workstation then follow the next step
### output:
- [x] new files with prefix `db.*` are dataBases for RPZ and ready to use at BIND9-server
- [x] incremented serial of zone-files - [rpz.*][zone-file], ready to use too
- [x] new files with prefix `txt.*` as the output of [grab_duplic.sh][grab-dedup] can be found at [this repository][part-output]
### others:
- [x] **Credits to** : All Owner-Maintainer of sources-list in [grab_urls][grab-urls] and [KOMINFO NKRI][kominfo-nkri]
- [x] [![CC BY-SA 4.0][cc-by-sa-badge]][cc-by-sa]
 [![Grabbing Blacklist for Bind9 RPZ][issues-badge]](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/issues) 
 [![Grabbing Blacklist for Bind9 RPZ][discussions-badge]](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/discussions)
 [![Grabbing Blacklist for Bind9 RPZ][usage-wiki-badge]](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/wiki)
- [x] This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License][cc-by-sa].

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-image]: https://licensebuttons.net/l/by-sa/4.0/88x31.png
[cc-by-sa-badge]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg
[issues-badge]: https://img.shields.io/badge/FEEDBACK:-Issues-lightgrey?style=flat&logo=github
[discussions-badge]: https://img.shields.io/badge/FEEDBACK:-Dicussions-lightgrey?style=flat&logo=github
[usage-wiki-badge]: https://img.shields.io/badge/USAGE:-Wiki-lightgrey?style=flat&logo=github

[grab-http]: https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_http.sh
[grab-dedup]: https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_duplic.sh
[grab-build]: https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_build.sh
[grab-cereal]: https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_cereal.sh
[grab-lib]: https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_library
[grab-urls]: https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_urls
[grab-regex]: https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_regex
[grab-scp]: https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_rsync.sh
[grab-cnf]: https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_config
[zone-file]: https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/tree/master/zones-rpz
[kominfo-nkri]: https://trustpositif.kominfo.go.id/assets/db/domains
[part-output]: https://github.com/ngadmini/partial-output
[wik-i]: https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/wiki/Fitting-Environment
[read-me]: https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/README
