# bin/bash

rm -rf ./data
wget https://github.com/Hanslick-Online/hsl-vms-data/archive/refs/heads/master.zip
unzip master
mkdir ./data
mkdir ./data/traktat
mkdir ./data/traktat/editions
mkdir ./data/traktat/comp
mkdir ./data/traktat/meta
mv hsl-vms-data-master/102_derived_tei/102_02_tei-simple_refactored/*.xml ./data/traktat/editions
mv hsl-vms-data-master/102_derived_tei/102_05_comp_refactored/*.xml ./data/traktat/comp
mv hsl-vms-data-master/102_derived_tei/102_06_paratexts/*.xml ./data/traktat/meta
rm -rf hsl-vms-data-master
rm master.zip

rm -rf ./data/traktat/indices
mkdir ./data/traktat/indices
rm -rf ./html/geo
mkdir ./html/geo
wget https://github.com/Hanslick-Online/hsl-entities/archive/refs/heads/main.zip
unzip main
mv hsl-entities-main/out/*.xml ./data/traktat/indices
mv hsl-entities-main/out/*.geojson ./html/geo
rm -rf hsl-entities-main
rm main.zip
