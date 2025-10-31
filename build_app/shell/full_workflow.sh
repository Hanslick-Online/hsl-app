#!/bin/bash
ANT_OPTS="-Xmx5g"
#TYPESENSE_HOST="typesense.acdh-dev.oeaw.ac.at"
#TYPESENSE_PORT="443"
#TYPESENSE_PROTOCOL="https"
#TYPESENSE_API_KEY=${TYPESENSE_API_KEY}
./build_app/shell/fetch_data.sh
./build_app/shell/script.sh
ant -f build_app/ant/preprocess.xml
./build_app/shell/attributes.sh
./build_app/shell/denormalize.sh
ant -f build_app/ant/fixtures.xml
ant -f build_app/ant/build.xml
#python ./build_app/python/make_ts_index.py
