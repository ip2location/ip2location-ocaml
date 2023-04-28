open Stdint
open Lwt
open Cohttp
open Cohttp_lwt_unix
open Yojson

module Database = struct
  type meta_data = {
    fs : in_channel;
    db_type : int;
    db_column : int;
    db_year : int;
    db_month : int;
    db_day : int;
    ipv4_db_count : uint32;
    ipv4_base_addr : uint32;
    ipv6_db_count : uint32;
    ipv6_base_addr : uint32;
    ipv4_index_base_addr : uint32;
    ipv6_index_base_addr : uint32;
    ipv4_column_size : uint32;
    ipv6_column_size : uint32
  }

  type ip2location_record = {
    country_short : string;
    country_long : string;
    region : string;
    city : string;
    isp : string;
    latitude : float;
    longitude : float;
    domain : string;
    zip_code : string;
    time_zone : string;
    net_speed : string;
    idd_code : string;
    area_code : string;
    weather_station_code : string;
    weather_station_name : string;
    mcc : string;
    mnc : string;
    mobile_brand : string;
    elevation : float;
    usage_type : string;
    address_type : string;
    category : string;
    district : string;
    asn : string;
    asys : string
  }

  exception Ip2location_exception of string

  let get_api_version = "8.1.0"

  let load_mesg mesg =
    {
      country_short = mesg;
      country_long = mesg;
      region = mesg;
      city = mesg;
      isp = mesg;
      latitude = 0.;
      longitude = 0.;
      domain = mesg;
      zip_code = mesg;
      time_zone = mesg;
      net_speed = mesg;
      idd_code = mesg;
      area_code = mesg;
      weather_station_code = mesg;
      weather_station_name = mesg;
      mcc = mesg;
      mnc = mesg;
      mobile_brand = mesg;
      elevation = 0.;
      usage_type = mesg;
      address_type = mesg;
      category = mesg;
      district = mesg;
      asn = mesg;
      asys = mesg
    }

  let get_bytes inc pos len =
    try
      seek_in inc pos;
      let res = Bytes.create len in
      really_input inc res 0 len;
      res
    with e ->
      raise e

  (* let read_uint8 inc pos = *)
    (* Bytes.get_uint8 (get_bytes inc pos 1) 0 *)

  (* let read_uint32 inc pos = *)
    (* Uint32.of_bytes_little_endian (get_bytes inc pos 4) 0 *)

  (* let read_uint128 inc pos = *)
    (* Uint128.of_bytes_little_endian (get_bytes inc pos 16) 0 *)

  let read_uint8_row row pos =
    Bytes.get_uint8 row pos

  let read_uint32_row row pos =
    Uint32.of_bytes_little_endian row pos

  let read_uint128_row row pos =
    Uint128.of_bytes_little_endian row pos

  let read_str meta pos =
    let row = get_bytes meta.fs pos 256 in (* max size of string field + 1 byte for the length *)
    let len = read_uint8_row row 0 in
    let data = Bytes.sub row 1 len in
    Bytes.to_string data

  let read_col_country_row meta row db_type col =
    let x = "This parameter is unavailable for selected data file. Please upgrade the data file." in
    let col_pos = col.(db_type) in
    
    if col_pos == 0
    then
      (x, x)
    else
      let col_offset = (col_pos - 2) lsl 2 in
      let x0 = Uint32.to_int (read_uint32_row row col_offset) in
      let x1 = read_str meta x0 in
      let x2 = read_str meta (x0 + 3) in
      (x1, x2)

  let read_col_string_row meta row db_type col =
    let col_pos = col.(db_type) in
    
    if col_pos == 0
    then
      "This parameter is unavailable for selected data file. Please upgrade the data file."
    else
      let col_offset = (col_pos - 2) lsl 2 in
      read_str meta (Uint32.to_int (read_uint32_row row col_offset))

  let read_float32 row =
    let rec pow2 = function
      | 0 -> 1
      | n -> 2 * (pow2 (n - 1))
    in
    let getbit b n = (b land (pow2 n)) lsr n in
    let b0 = Uint8.to_int (Uint8.of_bytes_little_endian row 0) in
    let b1 = Uint8.to_int (Uint8.of_bytes_little_endian row 1) in
    let b2 = Uint8.to_int (Uint8.of_bytes_little_endian row 2) in
    let b3 = Uint8.to_int (Uint8.of_bytes_little_endian row 3) in
    let sign = getbit b3 7
    and exponent = 128*(getbit b3 6) + 64*(getbit b3 5) + 32*(getbit b3 4) + 16*(getbit b3 3) + 8*(getbit b3 2) + 4*(getbit b3 1) + 2*(getbit b3 0) + (getbit b2 7)
    and significand = b0 + 256*b1 + 65536*(((b2 lsl 1) land 0xFF ) lsr 1) in
    let max_significand = (float (pow2 23)) -. 1.0 in
    if exponent = 255 then
      if significand = 0 then
        if sign = 0 then neg_infinity else infinity
      else
        nan
    else if exponent = 0 then
      if significand = 0 then
        if sign = 0 then 0.0 else -0.0
      else
        let fs = if sign = 0 then 1.0 else -1.0
        and fexp = (2.0) ** (-126.0)
        and fsig = ((float significand) /. max_significand) in
        fs *. fexp *. fsig
    else
      let fs = if sign = 0 then 1.0 else -1.0
      and fexp = (2.0) ** (float (exponent - 127))
      and fsig = 1.0 +. ((float significand) /. max_significand) in
      fs *. fexp *. fsig

  let read_float_row row pos =
    let data = Bytes.sub row pos 4 in
    read_float32 data

  (* let round_float n prec = *)
    (* let p = Float.pow 10. prec in *)
    (* (Float.round (n *. p)) /. p *)

  let read_col_float_row row db_type col =
    let col_pos = col.(db_type) in

    if col_pos == 0
    then
      0.
    else
      let col_offset = (col_pos - 2) lsl 2 in
      read_float_row row col_offset

  let read_col_float_string_row meta row db_type col =
    let col_pos = col.(db_type) in

    if col_pos == 0
    then
      0.
    else
      let col_offset = (col_pos - 2) lsl 2 in
      let x = Uint32.to_int (read_uint32_row row col_offset) in
      let n = read_str meta x in
      Float.of_string n

  (** Initialize with the IP2Location BIN database path and read metadata *)
  let open_db bin_path =
    let inc = open_in_bin bin_path in
    let row = get_bytes inc 0 64 in
    
    let db_type = read_uint8_row row 0 in
    let db_column = read_uint8_row row 1 in
    let db_year = read_uint8_row row 2 in
    let db_month = read_uint8_row row 3 in
    let db_day = read_uint8_row row 4 in
    let ipv4_db_count = read_uint32_row row 5 in
    let ipv4_base_addr = read_uint32_row row 9 in
    let ipv6_db_count = read_uint32_row row 13 in
    let ipv6_base_addr = read_uint32_row row 17 in
    let ipv4_index_base_addr = read_uint32_row row 21 in
    let ipv6_index_base_addr = read_uint32_row row 25 in
    let product_code = read_uint8_row row 29 in
    
    (* check if is correct BIN (should be 1 for IP2Location BIN file), also checking for zipped file (PK being the first 2 chars) *)
    if (product_code != 1 && db_year >= 21) || (db_type == 80 && db_column == 75)
    then
      raise (Ip2location_exception "Incorrect IP2Location BIN file format. Please make sure that you are using the latest IP2Location BIN file.")
    else
      {
        fs = inc;
        db_type = db_type;
        db_column = db_column;
        db_year = db_year;
        db_month = db_month;
        db_day = db_day;
        ipv4_db_count = ipv4_db_count;
        ipv4_base_addr = ipv4_base_addr;
        ipv6_db_count = ipv6_db_count;
        ipv6_base_addr = ipv6_base_addr;
        ipv4_index_base_addr = ipv4_index_base_addr;
        ipv6_index_base_addr = ipv6_index_base_addr;
        ipv4_column_size = Uint32.shift_left (Uint32.of_int db_column) 2; (* 4 bytes each column *)
        ipv6_column_size = Uint32.add (Uint32.of_int 16) (Uint32.shift_left (Uint32.of_int (db_column - 1)) 2); (* 4 bytes each column, except IPFrom column which is 16 bytes *)
      }
  
  (** Close input channel *)
  let close_db meta = close_in_noerr meta.fs

  let read_record meta row db_type =
    let country_position = [|0; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2|] in
    let region_position = [|0; 0; 0; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3; 3|] in
    let city_position = [|0; 0; 0; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4; 4|] in
    let isp_position = [|0; 0; 3; 0; 5; 0; 7; 5; 7; 0; 8; 0; 9; 0; 9; 0; 9; 0; 9; 7; 9; 0; 9; 7; 9; 9; 9|] in
    let latitude_position = [|0; 0; 0; 0; 0; 5; 5; 0; 5; 5; 5; 5; 5; 5; 5; 5; 5; 5; 5; 5; 5; 5; 5; 5; 5; 5; 5|] in
    let longitude_position = [|0; 0; 0; 0; 0; 6; 6; 0; 6; 6; 6; 6; 6; 6; 6; 6; 6; 6; 6; 6; 6; 6; 6; 6; 6; 6; 6|] in
    let domain_position = [|0; 0; 0; 0; 0; 0; 0; 6; 8; 0; 9; 0; 10;0; 10; 0; 10; 0; 10; 8; 10; 0; 10; 8; 10; 10; 10|] in
    let zip_code_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 7; 7; 7; 7; 0; 7; 7; 7; 0; 7; 0; 7; 7; 7; 0; 7; 7; 7|] in
    let time_zone_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 8; 8; 7; 8; 8; 8; 7; 8; 0; 8; 8; 8; 0; 8; 8; 8|] in
    let net_speed_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 8; 11;0; 11;8; 11; 0; 11; 0; 11; 0; 11; 11; 11|] in
    let idd_code_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 9; 12; 0; 12; 0; 12; 9; 12; 0; 12; 12; 12|] in
    let area_code_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 10 ;13 ;0; 13; 0; 13; 10; 13; 0; 13; 13; 13|] in
    let weather_station_code_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 9; 14; 0; 14; 0; 14; 0; 14; 14; 14|] in
    let weather_station_name_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 10; 15; 0; 15; 0; 15; 0; 15; 15; 15|] in
    let mcc_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 9; 16; 0; 16; 9; 16; 16; 16|] in
    let mnc_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 10;17; 0; 17; 10; 17; 17; 17|] in
    let mobile_brand_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 11;18; 0; 18; 11; 18; 18; 18|] in
    let elevation_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 11; 19; 0; 19; 19; 19|] in
    let usage_type_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 12; 20; 20; 20|] in
    let address_type_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 21; 21|] in
    let category_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 22; 22|] in
    let district_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 23|] in
    let asn_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 24|] in
    let asys_position = [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 25|] in
    
    let country_short, country_long = read_col_country_row meta row db_type country_position in
    let region = read_col_string_row meta row db_type region_position in
    let city = read_col_string_row meta row db_type city_position in
    let isp = read_col_string_row meta row db_type isp_position in
    let latitude = read_col_float_row row db_type latitude_position in
    let longitude = read_col_float_row row db_type longitude_position in
    let domain = read_col_string_row meta row db_type domain_position in
    let zip_code = read_col_string_row meta row db_type zip_code_position in
    let time_zone = read_col_string_row meta row db_type time_zone_position in
    let net_speed = read_col_string_row meta row db_type net_speed_position in
    let idd_code = read_col_string_row meta row db_type idd_code_position in
    let area_code = read_col_string_row meta row db_type area_code_position in
    let weather_station_code = read_col_string_row meta row db_type weather_station_code_position in
    let weather_station_name = read_col_string_row meta row db_type weather_station_name_position in
    let mcc = read_col_string_row meta row db_type mcc_position in
    let mnc = read_col_string_row meta row db_type mnc_position in
    let mobile_brand = read_col_string_row meta row db_type mobile_brand_position in
    let elevation = read_col_float_string_row meta row db_type elevation_position in
    let usage_type = read_col_string_row meta row db_type usage_type_position in
    let address_type = read_col_string_row meta row db_type address_type_position in
    let category = read_col_string_row meta row db_type category_position in
    let district = read_col_string_row meta row db_type district_position in
    let asn = read_col_string_row meta row db_type asn_position in
    let asys = read_col_string_row meta row db_type asys_position in
    
    {
      country_short = country_short;
      country_long = country_long;
      region = region;
      city = city;
      isp = isp;
      latitude = latitude;
      longitude = longitude;
      domain = domain;
      zip_code = zip_code;
      time_zone = time_zone;
      net_speed = net_speed;
      idd_code = idd_code;
      area_code = area_code;
      weather_station_code = weather_station_code;
      weather_station_name = weather_station_name;
      mcc = mcc;
      mnc = mnc;
      mobile_brand = mobile_brand;
      elevation = elevation;
      usage_type = usage_type;
      address_type = address_type;
      category = category;
      district = district;
      asn = asn;
      asys = asys
    }
  
  let rec search_tree meta ip_num db_type low high base_addr col_size ip_type =
    if low <= high
    then
      let mid = Uint32.shift_right_logical (Uint32.add low high) 1 in
      let row_offset = Uint32.add base_addr (Uint32.mul mid col_size) in
      
      let first_col = Uint32.of_int (if ip_type == 4 then 4 else 16) in
      let read_len = Uint32.add col_size first_col in
      
      let row = get_bytes meta.fs ((Uint32.to_int row_offset) - 1) (Uint32.to_int read_len) in (* reading IP From + whole row + next IP From *)
      
      let ip_from = if ip_type == 4 then Uint32.to_uint128 (read_uint32_row row 0) else read_uint128_row row 0 in
      let ip_to = if ip_type == 4 then Uint32.to_uint128 (read_uint32_row row (Uint32.to_int col_size)) else read_uint128_row row (Uint32.to_int col_size) in
      
      if ip_num >= ip_from && ip_num < ip_to
      then
        let row_len = Uint32.to_int (Uint32.sub col_size first_col) in
        let row2 = Bytes.sub row (Uint32.to_int first_col) row_len in
        
        read_record meta row2 db_type
      else
        if ip_num < ip_from
        then
          search_tree meta ip_num db_type low (Uint32.pred mid) base_addr col_size ip_type
        else
          search_tree meta ip_num db_type (Uint32.succ mid) high base_addr col_size ip_type
    else
      load_mesg "IP address not found."
  
  let search_4 meta ip_num =
    if meta.ipv4_index_base_addr > Uint32.zero
    then
      let index_pos = Uint32.to_int (Uint32.add (Uint128.to_uint32 (Uint128.shift_left (Uint128.shift_right_logical ip_num 16) 3)) meta.ipv4_index_base_addr) in
      let row = get_bytes meta.fs (index_pos - 1) 8 in (* 4 bytes for each IP From & IP To *)
      let low = read_uint32_row row 0 in
      let high = read_uint32_row row 4 in
      search_tree meta ip_num meta.db_type low high meta.ipv4_base_addr meta.ipv4_column_size 4
    else
      search_tree meta ip_num meta.db_type Uint32.zero meta.ipv4_db_count meta.ipv4_base_addr meta.ipv4_column_size 4
  
  let search_6 meta ip_num =
    if meta.ipv6_index_base_addr > Uint32.zero
    then
      let index_pos = Uint32.to_int (Uint32.add (Uint128.to_uint32 (Uint128.shift_left (Uint128.shift_right_logical ip_num 112) 3)) meta.ipv6_index_base_addr) in
      let row = get_bytes meta.fs (index_pos - 1) 8 in (* 4 bytes for each IP From & IP To *)
      let low = read_uint32_row row 0 in
      let high = read_uint32_row row 4 in
      
      search_tree meta ip_num meta.db_type low high meta.ipv6_base_addr meta.ipv6_column_size 6
    else
      search_tree meta ip_num meta.db_type Uint32.zero meta.ipv6_db_count meta.ipv6_base_addr meta.ipv6_column_size 6
  
  (** Query geolocation data for IP address *)
  let query meta ip =
    begin
      let from_v4_mapped = Uint128.of_string "281470681743360" in
      let to_v4_mapped = Uint128.of_string "281474976710655" in
      let from_6_to_4 = Uint128.of_string "42545680458834377588178886921629466624" in
      let to_6_to_4 = Uint128.of_string "42550872755692912415807417417958686719" in
      let from_teredo = Uint128.of_string "42540488161975842760550356425300246528" in
      let to_teredo = Uint128.of_string "42540488241204005274814694018844196863" in
      let last_32_bits = Uint128.of_string "4294967295" in
      
      try
   	    let x = Ipaddr.V4.of_string_exn ip in
        let ip_num = Uint32.to_uint128 (Uint32.of_bytes_big_endian (Bytes.of_string (Ipaddr.V4.to_octets x)) 0) in (* big endian because is network byte order *)
        search_4 meta ip_num
      with _ ->
        try
   	      let x = Ipaddr.V6.of_string_exn ip in
          let ip_num = Uint128.of_bytes_big_endian (Bytes.of_string (Ipaddr.V6.to_octets x)) 0 in (* big endian because is network byte order *)
          if ip_num >= from_v4_mapped && ip_num <= to_v4_mapped
          then
            search_4 meta (Uint128.sub ip_num from_v4_mapped)
          else if ip_num >= from_6_to_4 && ip_num <= to_6_to_4
          then
            search_4 meta (Uint128.logand (Uint128.shift_right_logical ip_num 80) last_32_bits)
          else if ip_num >= from_teredo && ip_num <= to_teredo
          then
            search_4 meta (Uint128.logand (Uint128.lognot ip_num) last_32_bits)
          else
            search_6 meta ip_num
        with _ ->
          load_mesg "Invalid IP address."
    end
  
end

module Web_service = struct
  type web_config = {
    api_key : string;
    api_package : string;
    use_ssl : bool
  }
  
  exception Ip2location_exception of string
  
  let check_params api_key api_package =
    let r = Str.regexp {|^[0-9A-Z]+$|} in
    let r2 = Str.regexp {|^WS[0-9]+$|} in
    if (not (Str.string_match r api_key 0)) || (String.length api_key) <> 10
    then
      raise (Ip2location_exception "Invalid API key.")
    else if not (Str.string_match r2 api_package 0)
    then
      raise (Ip2location_exception "Invalid package name.")
    else
      true
  
  (** Initialize the IP2Location Web Service *)
  let open_ws api_key api_package use_ssl =
    let _ = check_params api_key api_package in (* if params wrong, will throw exception *)
    {
      api_key = api_key;
      api_package = api_package;
      use_ssl = use_ssl
    }
  
  let call_geolocation_api config ip add_on lang =
    let protocol = if config.use_ssl then "https" else "http" in
    let uri = Uri.of_string (protocol ^ "://api.ip2location.com/v2/?key=" ^ config.api_key ^ "&ip=" ^ ip ^ "&package=" ^ config.api_package ^ "&addon=" ^ add_on ^ "&lang=" ^ lang) in
    
    Lwt_main.run begin
      Client.get uri >>= fun (resp, body) ->
        let code = resp |> Response.status |> Code.code_of_status in
        let json_promise = body |> Cohttp_lwt.Body.to_string in
        json_promise >>= (fun json_string ->
          return (code, json_string)
        )
    end
  
  let call_credit_api config =
    let protocol = if config.use_ssl then "https" else "http" in
    let uri = Uri.of_string (protocol ^ "://api.ip2location.com/v2/?key=" ^ config.api_key ^ "&check=true") in
    
    Lwt_main.run begin
      Client.get uri >>= fun (resp, body) ->
        let code = resp |> Response.status |> Code.code_of_status in
        let json_promise = body |> Cohttp_lwt.Body.to_string in
        json_promise >>= (fun json_string ->
          return (code, json_string)
        )
    end
  
  (** Call the web service to get geolocation info *)
  let lookup config ip add_on lang =
    let code, json_string = call_geolocation_api config ip add_on lang in
    let json = Basic.from_string json_string in
    (code, json)
  
  (** Call the web service to check the credit balance *)
  let get_credit config =
    let code, json_string = call_credit_api config in
    let json = Basic.from_string json_string in
    (code, json)
  
end