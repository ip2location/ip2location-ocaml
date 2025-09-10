# IP2Location OCaml API

## Database Module

```{py:function} open_db(bin_path )
Open and load the IP2Location BIN database for lookup.

:param str bin_path : (Required) The file path links to IP2Location BIN databases.
```

```{py:function} close_db()
Closes BIN file and resets metadata.
```

```{py:function} query(ip)
Retrieve geolocation information for an IP address.

:param str ip: (Required) The IP address (IPv4 or IPv6).
:return: Returns the geolocation information. Refer below table for the fields avaliable.

**RETURN FIELDS**

| Field Name       | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| country_short    |     Two-character country code based on ISO 3166. |
| country_long     |     Country name based on ISO 3166. |
| region           |     Region or state name. |
| city             |     City name. |
| isp              |     Internet Service Provider or company\'s name. |
| latitude         |     City latitude. Defaults to capital city latitude if city is unknown. |
| longitude        |     City longitude. Defaults to capital city longitude if city is unknown. |
| domain           |     Internet domain name associated with IP address range. |
| zip_code          |     ZIP code or Postal code. [172 countries supported](https://www.ip2location.com/zip-code-coverage). |
| time_zone         |     UTC time zone (with DST supported). |
| net_speed         |     Internet connection type. |
| idd_code         |     The IDD prefix to call the city from another country. |
| area_code        |     A varying length number assigned to geographic areas for calls between cities. [223 countries supported](https://www.ip2location.com/area-code-coverage). |
| weather_station_code     |     The special code to identify the nearest weather observation station. |
| weather_station_name     |     The name of the nearest weather observation station. |
| mcc              |     Mobile Country Codes (MCC) as defined in ITU E.212 for use in identifying mobile stations in wireless telephone networks, particularly GSM and UMTS networks. |
| mnc              |     Mobile Network Code (MNC) is used in combination with a Mobile Country Code(MCC) to uniquely identify a mobile phone operator or carrier. |
| mobile_brand     |     Commercial brand associated with the mobile carrier. You may click [mobile carrier coverage](https://www.ip2location.com/mobile-carrier-coverage) to view the coverage report. |
| elevation        |     Average height of city above sea level in meters (m). |
| usage_type       |     Usage type classification of ISP or company. |
| address_type     |     IP address types as defined in Internet Protocol version 4 (IPv4) and Internet Protocol version 6 (IPv6). |
| category         |     The domain category based on [IAB Tech Lab Content Taxonomy](https://www.ip2location.com/free/iab-categories). |
| district         |     District or county name. |
| asn              |     Autonomous system number (ASN). BIN databases. |
| asys          |     Autonomous system (AS) name. |
| as_domain    | Domain name of the AS registrant. |
| as_usage_type    | Usage type of the AS registrant. |
| as_cidr    | CIDR range for the whole AS. |
```
