#!/bin/bash
set -euxo pipefail

VolitveBASEURL="https://volitve.dvk-rs.si/ep2024"
mkdir -p volitve

curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/config/config.json"   | jq > volitve/config.json
curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/data/obvestila.json"  | jq > volitve/obvestila.json
curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/data/data.json"       | jq > volitve/data.json
jq -r '(.slovenija.enote | map({st: .st, naziv: .naz} ))| (.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' volitve/data.json > volitve/enote.csv

sleep 5

curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/data/liste.json"      | jq > volitve/liste.json
jq -r '(.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' volitve/liste.json > volitve/liste.csv
curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/data/kandidati.json"  | jq > volitve/kandidati.json
jq -r 'map({zap_st: .zap_st, st: .st, id: .id, ime: .ime, priimek: .pri, datum_rojstva: .dat_roj[0:10], delo: .del , obcina: .obc , naselje: .nas , ulica: .ul , hisna_st: .hst, spol: .spol , ptt: .ptt , ptt_st: .ptt_st , enota: .enota, okraj_1: .okraji[0], okraj_2: .okraji[1] }) | (.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' volitve/kandidati.json > volitve/kandidati.csv
curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/data/zgod_udel.json"  | jq > volitve/zgod_udel.json

sleep 5

# Iz navodil medijem:
# https://www.dvk-rs.si/volitve-in-referendumi/drzavni-zbor-rs/volitve-drzavnega-zbora-rs/volitve-v-dz-2022/#accordion-1731-body-6
curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/data/udelezba.json"            | jq > volitve/udelezba.json
curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/data/udelezba.csv"                  > volitve/udelezba.csv
curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/data/rezultati.json"           | jq > volitve/rezultati.json

sleep 5

curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/data/rezultati.csv"                 > volitve/rezultati.csv
curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/data/kandidati_rezultati.json" | jq > volitve/kandidati_rezultati.json
curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/data/mandati.csv"                   > volitve/mandati.csv


for VE in {1..8}
do
    VETEMP="0${VE}"
    VEPAD="${VETEMP: -2}" #pad left with 0s to max 2 chars
    for VO in {1..11}
    do
        VOTEMP="0${VO}"
        VOPAD="${VOTEMP: -2}"
        echo "Scraping VE:${VEPAD} VO:${VOPAD}..."
        curl --progress-bar --fail --connect-timeout 300 "${VolitveBASEURL}/data/volisca_${VEPAD}_${VOPAD}.json" | jq > volitve/volisca_${VEPAD}_${VOPAD}.json
        sleep 5
    done
    sleep 10
done
