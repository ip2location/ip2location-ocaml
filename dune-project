(lang dune 3.4)

(name ip2location)

(version 8.0.0)

(generate_opam_files true)

(source
 (github ip2location/ip2location-ocaml))

(authors "IP2Location.com")

(maintainers "IP2Location.com")

(license MIT)

(documentation https://github.com/ip2location/ip2location-ocaml)

(package
 (name ip2location)
 (synopsis "IP2Location OCaml module to get geolocation data")
 (description "IP2Location IP Geolocation OCaml module enables you to get your visitors' country, region, city, latitude, longitude, ZIP code, ISP, domain name, timezone, connection speed, IDD code, area code, weather station code, weather station name, MCC, MNC, mobile brand name, elevation, usage type, address type and IAB category based on IP address.")
 (depends ocaml dune stdint ipaddr str lwt cohttp cohttp-lwt-unix yojson)
 (tags (ip2location geolocation)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
