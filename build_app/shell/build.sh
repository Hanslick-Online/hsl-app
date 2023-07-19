# bin/bash

echo "fetch data"
./build_app/shell/fetch_data.sh

echo "install dependencies"
./build_app/shell/script.sh

echo "preprocess xml files"
ant -f build_app/ant/preprocess.xml

echo "install python dependencies"
pip install -U pip
pip install -r build_app/python/requirements.txt
./build_app/shell/attributes.sh
./build_app/shell/denormalize.sh

echo "build app"
ant -f build_app/ant/build.xml