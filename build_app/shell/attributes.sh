# bin/bash

echo "add attributes"
add-attributes -g "./data/traktat/editions/*.xml" -b "https://hanslick-online.github.io/hsl-app"
add-attributes -g "./data/critics/editions/*.xml" -b "https://hanslick-online.github.io/hsl-app"
