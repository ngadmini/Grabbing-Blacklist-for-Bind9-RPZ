<h1 align="center">Grabbing Blacklist Domains for Bind9-RPZ</h1>

<p align="center">
  	<b>Tailorized bash script-pack to update blacklisted domains in BIND9 Response Policy Zone<br>
	Please consider adapting this pack to fit your environment properties,<br>
	since simple duplication may not given appropriate results.<br>
	The partial output of this script-pack can be found at link below</b><br>
  	<a href="https://github.com/ngadmini/partial-output">
      <img src="https://img.shields.io/badge/bind9%20RPZ-Partial%20Output-blue?style=flat-square&logo=github">
   </a><br><br>
  	<a href="#"><img src="http://s.4cdn.org/image/title/105.gif"></a>
</p>

### script-pack
 1. [grab_http.sh][grab-http]  --grabbing and proccessing raw domains
 2. [grab_duplic.sh][grab-dedup] --removing duplicate entries between domain lists
 3. [grab_build.sh][grab-build] --rewriting to Bind9-RPZ format
 4. [grab_cereal.sh][grab-cereal] --incrementing serial zones
 5. [grab_library][grab-lib] --a library of functions. intended for use by other scripts, not to be executed directly
 6. [grab_urls][grab-urls] --urls list of remote files. case sensitive, strict order, line count and no blank lines
 7. [grab_regex][grab-regex] --list of reguler expressions. case sensitive, strict order, line count and no blank lines
 8. [grab_rsync.sh][grab-scp] --intended for syncronize latest dBASE to Bind9 host
 9. [grab_config][grab-cnf] --configurations file
10. [rpz.*][zone-file] --pack of zone-files, targeted by [grab_cereal.sh][grab-cereal] to incrementing serial zone
> <b>NOTE</b><br>Place them all under the same directory
### requirements:
- [x] please see [these wiki][wik-i] and [README][read-me]
### usage:
- [x] execute `grab_http.sh` with `non root privileges` either directly as a `root user` or by use of `sudo command`, from your linux desktop workstation then follow the next step
### output:
- [x] new files with prefix `db.*` are dataBases for RPZ and ready to use at BIND9-server
- [x] modified files with prefix `rpz.*` are zone -files, ready to use too
- [x] new files with prefix `txt.*` are raw domains blacklist
### in the real world
the partial output of this script-pack, can be found at [Partial Output][part-output] as raw format.
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
