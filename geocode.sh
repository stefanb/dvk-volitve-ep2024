#!/bin/bash
# set -e

# cut down csv to just the needed columns for geocoding (address, city, ZIP)
# https://csvkit.readthedocs.io/en/latest/scripts/csvsql.html

# add styling via simplestyle-spec:
# https://github.com/mapbox/simplestyle-spec/tree/master/1.1.0
    # --CAST(kandidati.st AS int) AS st,

rm -f data/ep2024/kandidati-cut.csv
csvsql --query "
SELECT
    CAST(zap_st AS int) AS zap_st,
    ime,
    priimek,
    datum_rojstva,
    spol,
    delo,
    ulica || ' ' || hisna_st AS naslov,
    naselje,
    CAST(ptt_st AS int) || ' ' || ptt AS posta,
    liste.knaz AS lista,
    '#' || liste.hcol AS \"marker-color\"
FROM kandidati JOIN liste ON kandidati.st = liste.st
" \
data/ep2024/kandidati.csv data/ep2024/liste.csv > data/ep2024/kandidati-cut.csv


# Geocode multiple addresses in a CSV file.

# Usage:
#   geocode csv [flags]

# Flags:
#       --addressCol int     Number (1..x) of the CSV column containing address (street number appendix) (required)
#       --appendAll          Append all columns
#       --cityCol int        Number (1..x) of the CSV column containing city name (optional)
#       --decimals int       Number of decimals for precision (default 5)
#   -h, --help               help for csv
#       --in string          Input CSV file (required)
#       --lat string         CSV field for geographic latitude (default "lat")
#       --lon string         CSV field for geographic longitude (default "lon")
#       --out string         Output CSV file (required)
#       --separator string   CSV separator character (default ",")
#       --zipCol int         Number (1..x) of the CSV column containing numeric ZIP code (required)

geocode csv --in=data/ep2024/kandidati-cut.csv --out=data/ep2024/kandidati-geocoded.csv  --addressCol=7 --cityCol=8 --zipCol=9

# https://gdal.org/drivers/vector/csv.html#building-point-geometries
# https://gdal.org/drivers/vector/geojson.html#layer-creation-options
# https://gdal.org/programs/ogr2ogr.html

# echo "aa"
ogr2ogr -f GeoJSON -s_srs EPSG:4326 -t_srs EPSG:4326 data/ep2024/kandidati.geojson data/ep2024/kandidati-geocoded.csv -oo X_POSSIBLE_NAMES=lon* -oo Y_POSSIBLE_NAMES=lat* -oo KEEP_GEOM_COLUMNS=NO

rm -f data/ep2024/kandidati-cut.csv data/ep2024/kandidati-geocoded.csv

# https://github.com/mapbox/geojson.io/blob/main/API.md