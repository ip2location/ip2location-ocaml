module Database :
  sig
    type meta_data = {
      fs : in_channel;
      db_type : int;
      db_column : int;
      db_year : int;
      db_month : int;
      db_day : int;
      ipv4_db_count : Stdint.uint32;
      ipv4_base_addr : Stdint.uint32;
      ipv6_db_count : Stdint.uint32;
      ipv6_base_addr : Stdint.uint32;
      ipv4_index_base_addr : Stdint.uint32;
      ipv6_index_base_addr : Stdint.uint32;
      ipv4_column_size : Stdint.uint32;
      ipv6_column_size : Stdint.uint32;
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
      asys : string;
      as_domain : string;
      as_usage_type : string;
      as_cidr : string;
    }
    exception Ip2location_exception of string
    val get_api_version : string
    val open_db : string -> meta_data
    val close_db : meta_data -> unit
    val query : meta_data -> string -> ip2location_record
  end
module Web_service :
  sig
    type web_config = {
      api_key : string;
      api_package : string;
      use_ssl : bool;
    }
    exception Ip2location_exception of string
    val open_ws : string -> string -> bool -> web_config
    val lookup :
      web_config -> string -> string -> string -> int * Yojson.Basic.t
    val get_credit : web_config -> int * Yojson.Basic.t
  end
