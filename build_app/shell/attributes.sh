# bin/bash

echo "add attributes"
add-attributes -g "./data/traktat/editions/*.xml" -b "https://hanslick.acdh.oeaw.ac.at"
add-attributes -g "./data/critics/editions/*.xml" -b "https://hanslick.acdh.oeaw.ac.at"
add-attributes -g "./data/vms/editions/*.xml" -b "https://hanslick.acdh.oeaw.ac.at"
