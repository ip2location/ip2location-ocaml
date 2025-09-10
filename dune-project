(lang dune 3.20)

(name ip2location)
(version 8.2.0)
(maintainers "IP2Location.com")
(authors "IP2Location.com")
(license MIT)
(source (github ip2location/ip2location-ocaml))

(generate_opam_files)

(package
 (name ip2location)
 (synopsis "IP2Location OCaml module to get geolocation data")
 (description "IP2Location IP Geolocation OCaml module enables you to get your visitors' country, region, city, latitude, longitude, ZIP code, ISP, domain name, timezone, connection speed, IDD code, area code, weather station code, weather station name, MCC, MNC, mobile brand name, elevation, usage type, address type, IAB category, district, autonomous system number (ASN), autonomous system (AS), AS domain, AS usage type and AS CIDR based on IP address.")
 (tags (ip2location geolocation))
 (depends
  (ocaml (>= "4.08"))
  stdint
  (ipaddr (>= "4.0"))
  lwt
  cohttp
  cohttp-lwt-unix
  (yojson (>= "1.6"))))
