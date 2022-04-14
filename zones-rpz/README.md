0. about /etc/bind/zones-rpz/ dir
1. designed to reguler update with rsync
2. only contains
      db.adultaa db.adultab db.adultac db.adultad db.adultae db.adultaf db.adultag db.ipv4 db.malware db.publicite db.redirector db.trust+
      rpz.adultaa rpz.adultab rpz.adultac rpz.adultad rpz.adultae rpz.adultaf rpz.adultag rpz.ipv4 rpz.malware rpz.publicite rpz.redirector rpz.trust+
3. make all files with permission
      chmod 640 rpz.*
      chmod 640 db.*
4. make symlinks to rpz.* in /etc/bind
      ln -s /etc/bind/zones-rpz/rpz.* /etc/bind
