# Quickstart

## Dependencies

This module requires IP2Location BIN data file to function. You may download the BIN data file at

-   IP2Location LITE BIN Data (Free): <https://lite.ip2location.com>
-   IP2Location Commercial BIN Data (Comprehensive):
    <https://www.ip2location.com>

## Compilation

```
dune build
```

## Sample Codes

### Query geolocation information from BIN database

You can query the geolocation information from the IP2Location BIN database as below:

```ocaml
open Printf
open Ip2location

(* query IP2Location BIN datababase *)
let meta = Database.open_db "/path_to_your_database_file/your_BIN_file.BIN";;

let ip = "8.8.8.8";;
let res = Database.query meta ip;;

printf "country_short: %s\n" res.country_short;;
printf "country_long: %s\n" res.country_long;;
printf "region: %s\n" res.region;;
printf "city: %s\n" res.city;;
printf "isp: %s\n" res.isp;;
printf "latitude: %f\n" res.latitude;;
printf "longitude: %f\n" res.longitude;;
printf "domain: %s\n" res.domain;;
printf "zip_code: %s\n" res.zip_code;;
printf "time_zone: %s\n" res.time_zone;;
printf "net_speed: %s\n" res.net_speed;;
printf "idd_code: %s\n" res.idd_code;;
printf "area_code: %s\n" res.area_code;;
printf "weather_station_code: %s\n" res.weather_station_code;;
printf "weather_station_name: %s\n" res.weather_station_name;;
printf "mcc: %s\n" res.mcc;;
printf "mnc: %s\n" res.mnc;;
printf "mobile_brand: %s\n" res.mobile_brand;;
printf "elevation: %f\n" res.elevation;;
printf "usage_type: %s\n" res.usage_type;;
printf "address_type: %s\n" res.address_type;;
printf "category: %s\n" res.category;;
printf "district: %s\n" res.district;;
printf "asn: %s\n" res.asn;;
printf "as: %s\n" res.asys;;
printf "as_domain: %s\n" res.as_domain;;
printf "as_usage_type: %s\n" res.as_usage_type;;
printf "as_cidr: %s\n" res.as_cidr;;

Database.close_db meta;;
```

