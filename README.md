# IP2Location OCaml Module

This OCaml module provides a fast lookup of country, region, city, latitude, longitude, ZIP code, time zone, ISP, domain name, connection type, IDD code, area code, weather station code, station name, mcc, mnc, mobile brand, elevation, usage type, address type, IAB category, district, autonomous system number (ASN) and autonomous system (AS) from IP address by using IP2Location database. This module uses a file based database available at IP2Location.com. This database simply contains IP blocks as keys, and other information such as country, region, city, latitude, longitude, ZIP code, time zone, ISP, domain name, connection type, IDD code, area code, weather station code, station name, mcc, mnc, mobile brand, elevation, usage type, address type, IAB category, district, autonomous system number (ASN) and autonomous system (AS) as values. It supports both IP address in IPv4 and IPv6.

This module can be used in many types of projects such as:

 - select the geographically closest mirror
 - analyze your web server logs to determine the countries of your visitors
 - credit card fraud detection
 - software export controls
 - display native language and currency 
 - prevent password sharing and abuse of service 
 - geotargeting in advertisement

The database will be updated in monthly basis for the greater accuracy. Free LITE databases are available at https://lite.ip2location.com/ upon registration.

The paid databases are available at https://www.ip2location.com under Premium subscription package.

As an alternative, this geolocation module can also call the IP2Location Web Service. This requires an API key. If you don't have an existing API key, you can subscribe for one at the below:

https://www.ip2location.com/web-service/ip2location

## Compilation

```
dune build
```

## QUERY USING THE BIN FILE

## Dependencies

This module requires IP2Location BIN data file to function. You may download the BIN data file at
* IP2Location LITE BIN Data (Free): https://lite.ip2location.com
* IP2Location Commercial BIN Data (Comprehensive): https://www.ip2location.com


## IPv4 BIN vs IPv6 BIN

Use the IPv4 BIN file if you just need to query IPv4 addresses.

Use the IPv6 BIN file if you need to query BOTH IPv4 and IPv6 addresses.


## Methods

Below are the methods supported in this module.

|Method Name|Description|
|---|---|
|open_db|Initialize with the BIN file.|
|query|Returns the geolocation information.|
|close_db|Closes BIN file.|

## Usage

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

Database.close_db meta;;

```

## QUERY USING THE IP2LOCATION WEB SERVICE

## Methods
Below are the methods supported in this module.

|Method Name|Description|
|---|---|
|open_ws| 3 input parameters:<ol><li>IP2Location API Key.</li><li>Package (WS1 - WS25)</li></li><li>Use HTTPS or HTTP</li></ol> |
|lookup|Query IP address. This method returns an object containing the geolocation info. <ul><li>country_code</li><li>country_name</li><li>region_name</li><li>city_name</li><li>latitude</li><li>longitude</li><li>zip_code</li><li>time_zone</li><li>isp</li><li>domain</li><li>net_speed</li><li>idd_code</li><li>area_code</li><li>weather_station_code</li><li>weather_station_name</li><li>mcc</li><li>mnc</li><li>mobile_brand</li><li>elevation</li><li>usage_type</li><li>address_type</li><li>category</li><li>continent<ul><li>name</li><li>code</li><li>hemisphere</li><li>translations</li></ul></li><li>country<ul><li>name</li><li>alpha3_code</li><li>numeric_code</li><li>demonym</li><li>flag</li><li>capital</li><li>total_area</li><li>population</li><li>currency<ul><li>code</li><li>name</li><li>symbol</li></ul></li><li>language<ul><li>code</li><li>name</li></ul></li><li>idd_code</li><li>tld</li><li>is_eu</li><li>translations</li></ul></li><li>region<ul><li>name</li><li>code</li><li>translations</li></ul></li><li>city<ul><li>name</li><li>translations</li></ul></li><li>geotargeting<ul><li>metro</li></ul></li><li>country_groupings</li><li>time_zone_info<ul><li>olson</li><li>current_time</li><li>gmt_offset</li><li>is_dst</li><li>sunrise</li><li>sunset</li></ul></li><ul>|
|get_credit|This method returns the web service credit balance in an object.|

## Usage

```ocaml
open Printf
open Ip2location

(* query IP2Location web service *)
exception Ws_exception of string

let api_key = "YOUR_API_KEY";;
let api_package = "WS25";;
let use_ssl = true;;
let config = Web_service.open_ws api_key api_package use_ssl;;

let ip = "2a02:3037:0400:6fa2:459c:84b6:967d:69e0";;
let add_on = "continent,country,region,city,geotargeting,country_groupings,time_zone_info";;
let lang = "es";;
let code, json = Web_service.lookup config ip add_on lang;;

if code == 200
then
  let open Yojson.Basic.Util in
  let response = json |> member "response" |> to_string in
  if response = "OK"
  then
    (* standard fields *)
    let country_code = json |> member "country_code" |> to_string in
    printf "country_code: %s\n" country_code;
    let country_name = if json |> member "country_name" = `Null then "N/A" else json |> member "country_name" |> to_string in
    printf "country_name: %s\n" country_name;
    let region_name = if json |> member "region_name" = `Null then "N/A" else json |> member "region_name" |> to_string in
    printf "region_name: %s\n" region_name;
    let city_name = if json |> member "city_name" = `Null then "N/A" else json |> member "city_name" |> to_string in
    printf "city_name: %s\n" city_name;
    let latitude = if json |> member "latitude" = `Null then 0. else json |> member "latitude" |> to_float in
    printf "latitude: %f\n" latitude;
    let longitude = if json |> member "longitude" = `Null then 0. else json |> member "longitude" |> to_float in
    printf "longitude: %f\n" longitude;
    let zip_code = if json |> member "zip_code" = `Null then "N/A" else json |> member "zip_code" |> to_string in
    printf "zip_code: %s\n" zip_code;
    let time_zone = if json |> member "time_zone" = `Null then "N/A" else json |> member "time_zone" |> to_string in
    printf "time_zone: %s\n" time_zone;
    let isp = if json |> member "isp" = `Null then "N/A" else json |> member "isp" |> to_string in
    printf "isp: %s\n" isp;
    let domain = if json |> member "domain" = `Null then "N/A" else json |> member "domain" |> to_string in
    printf "domain: %s\n" domain;
    let net_speed = if json |> member "net_speed" = `Null then "N/A" else json |> member "net_speed" |> to_string in
    printf "net_speed: %s\n" net_speed;
    let idd_code = if json |> member "idd_code" = `Null then "N/A" else json |> member "idd_code" |> to_string in
    printf "idd_code: %s\n" idd_code;
    let area_code = if json |> member "area_code" = `Null then "N/A" else json |> member "area_code" |> to_string in
    printf "area_code: %s\n" area_code;
    let weather_station_code = if json |> member "weather_station_code" = `Null then "N/A" else json |> member "weather_station_code" |> to_string in
    printf "weather_station_code: %s\n" weather_station_code;
    let weather_station_name = if json |> member "weather_station_name" = `Null then "N/A" else json |> member "weather_station_name" |> to_string in
    printf "weather_station_name: %s\n" weather_station_name;
    let mcc = if json |> member "mcc" = `Null then "N/A" else json |> member "mcc" |> to_string in
    printf "mcc: %s\n" mcc;
    let mnc = if json |> member "mnc" = `Null then "N/A" else json |> member "mnc" |> to_string in
    printf "mnc: %s\n" mnc;
    let mobile_brand = if json |> member "mobile_brand" = `Null then "N/A" else json |> member "mobile_brand" |> to_string in
    printf "mobile_brand: %s\n" mobile_brand;
    let elevation = if json |> member "elevation" = `Null then 0 else json |> member "elevation" |> to_int in
    printf "elevation: %d\n" elevation;
    let usage_type = if json |> member "usage_type" = `Null then "N/A" else json |> member "usage_type" |> to_string in
    printf "usage_type: %s\n" usage_type;
    let address_type = if json |> member "address_type" = `Null then "N/A" else json |> member "address_type" |> to_string in
    printf "address_type: %s\n" address_type;
    let category = if json |> member "category" = `Null then "N/A" else json |> member "category" |> to_string in
    printf "category: %s\n" category;
    let category_name = if json |> member "category_name" = `Null then "N/A" else json |> member "category_name" |> to_string in
    printf "category_name: %s\n" category_name;
    let credits_consumed = json |> member "credits_consumed" |> to_int in
    printf "credits_consumed: %d\n" credits_consumed;
    
    (* continent addon *)
    if (member "continent" json) = `Null
    then
      print_endline "No continent addon."
    else
    (
      let continent_name = json |> member "continent" |> member "name" |> to_string in
      printf "continent_name: %s\n" continent_name;
      let continent_code = json |> member "continent" |> member "code" |> to_string in
      printf "continent_code: %s\n" continent_code;
      let continent_hemisphere = json |> member "continent" |> member "hemisphere" |> to_list |> List.map (fun x -> x |> to_string) in
      print_endline "continent_hemisphere:";
      List.iter (fun x -> x |> print_endline) continent_hemisphere;
      if (json |> member "continent" |> member "translations") = `Null
      then
        print_endline "No continent translation."
      else
      (
        let continent_translations = json |> member "continent" |> member "translations" |> to_assoc |> List.map (fun (k,v) -> (k, (v |> to_string))) in
        print_endline "continent_translation:";
        List.iter (fun (k,v) -> printf "%s: %s\n" k v) continent_translations;
      );
    );
    
    (* country addon *)
    if (member "country" json) = `Null
    then
      print_endline "No country addon."
    else
    (
      let country_name = json |> member "country" |> member "name" |> to_string in
      printf "country_name: %s\n" country_name;
      let country_alpha3_code = json |> member "country" |> member "alpha3_code" |> to_string in
      printf "country_alpha3_code: %s\n" country_alpha3_code;
      let country_numeric_code = json |> member "country" |> member "numeric_code" |> to_string in
      printf "country_numeric_code: %s\n" country_numeric_code;
      let country_demonym = json |> member "country" |> member "demonym" |> to_string in
      printf "country_demonym: %s\n" country_demonym;
      let country_flag = json |> member "country" |> member "flag" |> to_string in
      printf "country_flag: %s\n" country_flag;
      let country_capital = json |> member "country" |> member "capital" |> to_string in
      printf "country_capital: %s\n" country_capital;
      let country_total_area = json |> member "country" |> member "total_area" |> to_string in
      printf "country_total_area: %s\n" country_total_area;
      let country_population = json |> member "country" |> member "population" |> to_string in
      printf "country_population: %s\n" country_population;
      let country_currency_code = json |> member "country" |> member "currency" |> member "code" |> to_string in
      printf "country_currency_code: %s\n" country_currency_code;
      let country_currency_name = json |> member "country" |> member "currency" |> member "name" |> to_string in
      printf "country_currency_name: %s\n" country_currency_name;
      let country_currency_symbol = json |> member "country" |> member "currency" |> member "symbol" |> to_string in
      printf "country_currency_symbol: %s\n" country_currency_symbol;
      let country_language_code = json |> member "country" |> member "language" |> member "code" |> to_string in
      printf "country_language_code: %s\n" country_language_code;
      let country_language_name = json |> member "country" |> member "language" |> member "name" |> to_string in
      printf "country_language_name: %s\n" country_language_name;
      let country_idd_code = json |> member "country" |> member "idd_code" |> to_string in
      printf "country_idd_code: %s\n" country_idd_code;
      let country_tld = json |> member "country" |> member "tld" |> to_string in
      printf "country_tld: %s\n" country_tld;
      let country_is_eu = json |> member "country" |> member "is_eu" |> to_bool in
      printf "country_is_eu: %B\n" country_is_eu;
      if (json |> member "country" |> member "translations") = `Null
      then
        print_endline "No country translation."
      else
      (
        let country_translations = json |> member "country" |> member "translations" |> to_assoc |> List.map (fun (k,v) -> (k, (v |> to_string))) in
        print_endline "country_translation:";
        List.iter (fun (k,v) -> printf "%s: %s\n" k v) country_translations;
      );
    );
    
    (* region addon *)
    if (member "region" json) = `Null
    then
      print_endline "No region addon."
    else
    (
      let region_name = json |> member "region" |> member "name" |> to_string in
      printf "region_name: %s\n" region_name;
      let region_code = json |> member "region" |> member "code" |> to_string in
      printf "region_code: %s\n" region_code;
      if (json |> member "region" |> member "translations") = `Null
      then
        print_endline "No region translation."
      else
      (
        let region_translations = json |> member "region" |> member "translations" |> to_assoc |> List.map (fun (k,v) -> (k, (v |> to_string))) in
        print_endline "region_translation:";
        List.iter (fun (k,v) -> printf "%s: %s\n" k v) region_translations;
      );
    );
    
    (* city addon *)
    if (member "city" json) = `Null
    then
      print_endline "No city addon."
    else
    (
      let city_name = json |> member "city" |> member "name" |> to_string in
      printf "city_name: %s\n" city_name;
      try
        let city_translations = json |> member "city" |> member "translations" |> to_assoc |> List.map (fun (k,v) -> (k, (v |> to_string))) in
        print_endline "city_translation:";
        List.iter (fun (k,v) -> printf "%s: %s\n" k v) city_translations;
      with _ ->
        print_endline "No city translation."
    );
    
    (* geotargeting addon *)
    if (member "geotargeting" json) = `Null
    then
      print_endline "No geotargeting addon."
    else
    (
      let geotargeting_metro = json |> member "geotargeting" |> member "metro" |> to_string in
      printf "geotargeting_metro: %s\n" geotargeting_metro;
     );
    
    (* country_groupings addon *)
    if (member "country_groupings" json) = `Null
    then
      print_endline "No country_groupings addon."
    else
    (
      let country_groupings = json |> member "country_groupings" |> to_list |> List.map (fun x -> x |> to_assoc |> List.map (fun (k,v) -> (k, (v |> to_string)))) in
      print_endline "country_groupings:";
      List.iter (fun x -> x |> List.iter (fun (k,v) -> printf "%s: %s\n" k v)) country_groupings;
    );
    
    (* time_zone_info addon *)
    if (member "time_zone_info" json) = `Null
    then
      print_endline "No time_zone_info addon."
    else
    (
      let time_zone_info_olson = json |> member "time_zone_info" |> member "olson" |> to_string in
      printf "time_zone_info_olson: %s\n" time_zone_info_olson;
      let time_zone_info_current_time = json |> member "time_zone_info" |> member "current_time" |> to_string in
      printf "time_zone_info_current_time: %s\n" time_zone_info_current_time;
      let time_zone_info_gmt_offset = json |> member "time_zone_info" |> member "gmt_offset" |> to_int in
      printf "time_zone_info_gmt_offset: %d\n" time_zone_info_gmt_offset;
      let time_zone_info_is_dst = json |> member "time_zone_info" |> member "is_dst" |> to_string in
      printf "time_zone_info_is_dst: %s\n" time_zone_info_is_dst;
      let time_zone_info_sunrise = json |> member "time_zone_info" |> member "sunrise" |> to_string in
      printf "time_zone_info_sunrise: %s\n" time_zone_info_sunrise;
      let time_zone_info_sunset = json |> member "time_zone_info" |> member "sunset" |> to_string in
      printf "time_zone_info_sunset: %s\n" time_zone_info_sunset;
    );
  else
    raise (Ws_exception response)
else
  raise (Ws_exception ("HTTP Code: " ^ (Int.to_string code)))

(* check web service credit balance *)
let code, json = Web_service.get_credit config;;

if code == 200
then
  let open Yojson.Basic.Util in
  let response = json |> member "response" |> to_int in
  printf "credit_balance: %d\n" response;
else
  raise (Ws_exception ("HTTP Code: " ^ (Int.to_string code)))

```