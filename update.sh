#!/bin/bash
set -euxo pipefail

VOTEKEY=${1:-ep2024}

VolitveBASEURL="https://volitve.dvk-rs.si/${VOTEKEY}"
CURL="curl --progress-bar --fail --connect-timeout 300"
DIR="data/${VOTEKEY}"
mkdir -p "${DIR}"

$CURL "${VolitveBASEURL}/config/config.json"   | jq > ${DIR}/config.json
$CURL "${VolitveBASEURL}/data/obvestila.json"  | jq > ${DIR}/obvestila.json
$CURL "${VolitveBASEURL}/data/data.json"       | jq > ${DIR}/data.json
jq -r '(.slovenija.enote | map({st: .st, naziv: .naz} ))| (.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' ${DIR}/data.json > ${DIR}/enote.csv

#check ig VOTEKEY doesn't start with "referendum"
if [[ $VOTEKEY != referendum* ]]
then
    $CURL "${VolitveBASEURL}/data/liste.json"      | jq > ${DIR}/liste.json
    jq -r '(.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' ${DIR}/liste.json > ${DIR}/liste.csv
    $CURL "${VolitveBASEURL}/data/kandidati.json"  | jq > ${DIR}/kandidati.json
    jq -r 'map({zap_st: .zap_st, st: .st, id: .id, ime: .ime, priimek: .pri, datum_rojstva: .dat_roj[0:10], delo: .del , obcina: .obc , naselje: .nas , ulica: .ul , hisna_st: .hst, spol: .spol , ptt: .ptt , ptt_st: .ptt_st , enota: .enota, okraj_1: .okraji[0], okraj_2: .okraji[1] }) | (.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' ${DIR}/kandidati.json > ${DIR}/kandidati.csv
fi

$CURL "${VolitveBASEURL}/data/zgod_udel.json"  | jq > ${DIR}/zgod_udel.json

# Iz navodil medijem:
# https://www.dvk-rs.si/volitve-in-referendumi/drzavni-zbor-rs/volitve-drzavnega-zbora-rs/volitve-v-dz-2022/#accordion-1731-body-6
$CURL "${VolitveBASEURL}/data/udelezba.json"            | jq > ${DIR}/udelezba.json
$CURL "${VolitveBASEURL}/data/udelezba.csv"                  > ${DIR}/udelezba.csv
$CURL "${VolitveBASEURL}/data/rezultati.json"           | jq > ${DIR}/rezultati.json
$CURL "${VolitveBASEURL}/data/rezultati.csv"                 > ${DIR}/rezultati.csv
$CURL "${VolitveBASEURL}/data/izvoz.xlsx"                    > ${DIR}/izvoz.xlsx

if [[ $VOTEKEY != referendum* ]]
then
    $CURL "${VolitveBASEURL}/data/kandidati_rezultati.json" | jq > ${DIR}/kandidati_rezultati.json
    $CURL "${VolitveBASEURL}/data/mandati.csv"                   > ${DIR}/mandati.csv
fi

for VE in {1..8}
do
    VETEMP="0${VE}"
    VEPAD="${VETEMP: -2}" #pad left with 0s to max 2 chars
    for VO in {1..11}
    do
        VOTEMP="0${VO}"
        VOPAD="${VOTEMP: -2}"
        echo "Scraping VE:${VEPAD} VO:${VOPAD}..."
        $CURL "${VolitveBASEURL}/data/volisca_${VEPAD}_${VOPAD}.json" | jq > ${DIR}/volisca_${VEPAD}_${VOPAD}.json
    done
done
