<h1 align="center">Grabbing Blacklist Domains for Bind9-RPZ</h1>

<p align="center">
  	<b>Tailorized bash script-pack to update blacklist domains in BIND9 Response Policy Zone<br>
	Please consider adapting this pack to fit your environment properties,<br>
	since simple duplication may not given appropriate results</b><br>
	The partial output of this script-pack can be found at link below</b><br>
  	<a href="https://github.com/ngadmini/partial-output"><img src="https://img.shields.io/badge/bind9%20RPZ-Partial%20Output-blue?style=flat-square&logo=github"></a>
  	<br><br>
  	<a href="#"><img src="http://s.4cdn.org/image/title/105.gif"></a>
</p>

### files
 1. [grab_http.sh](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_http.sh) --grabbing and proccessing raw domains
 2. [grab_dedup.sh](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_dedup.sh) --removing duplicate entries between domain lists
 3. [grab_build.sh](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_build.sh) --rewriting to BIND9-rpz format
 4. [grab_cereal.sh](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_cereal.sh) --incrementing serial zones of rpz-files
 5. [grab_lib](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_lib) --contain some of functions needed by others script
 6. [grab_urls](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_urls) --urls list of remote files. case sensitive, strict order, line count and no blank lines
 7. [grab_regex](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_regex) --list of reguler expressions. case sensitive, strict order, line count and no blank lines
 8. [grab_scp.sh](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_scp.sh) --additional scripts tool for updating rpz- files and dBASE to Bind9 host
 9. [grab_cnf](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_cnf) --configuration file
10. [rpz.{adulta*,ipv4,malware,publicite,redirector,trust+}](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/tree/master/zones-rpz) --pack of zone-files, needed by [grab_cereal.sh](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_cereal.sh) 
> <b>NOTE</b><br>Place theme all under the same directory
### requirements:
- [x] please see [these wiki](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/wiki/Fitting-Environment) and [README](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/README)
### usage:
- [x] execute `grab_http.sh` with `non root privileges` either directly as a `root user` or by use of `sudo command`, from your linux desktop workstation then follow the next step
### output:
- [x] new files with prefix `db.*` are dataBases for RPZ and ready to use at BIND9-server
- [x] modified files with prefix `rpz.*` are zone -files, ready to use too
- [x] new files with prefix `txt.*` are raw domains blacklist
### in the real world
the partial output of this script-pack, can be found at [Partial Output](https://github.com/ngadmini/partial-output) as raw format.
### others:
- [x] **Credits to** : All Owner-Maintainer of sources-list in [grab_urls](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/blob/master/libs/grab_urls) and [KOMINFO NKRI](https://trustpositif.kominfo.go.id/assets/db/domains)
- [x] [![CC BY-SA 4.0][cc-by-sa-shield]][cc-by-sa]
 [![Grabbing Blacklist for Bind9 RPZ](https://img.shields.io/badge/FEEDBACK:-Issues-blue?style=flat-square&logo=github)](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/issues) 
 [![Grabbing Blacklist for Bind9 RPZ](https://img.shields.io/badge/FEEDBACK:-Dicussions-blue?style=flat-square&logo=github)](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/discussions)
 [![Grabbing Blacklist for Bind9 RPZ](https://img.shields.io/badge/USAGE:-Wiki-blue?style=flat-square&logo=github)](https://github.com/ngadmini/Grabbing-Blacklist-for-Bind9-RPZ/wiki)
- [x] This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License][cc-by-sa].

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-image]: https://licensebuttons.net/l/by-sa/4.0/88x31.png
[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg
