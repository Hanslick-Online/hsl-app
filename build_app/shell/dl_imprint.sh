# bin/bash

REDMINE_ID=21428
IMPRINT_XML=./data/imprint.xml
touch ${IMPRINT_XML}
echo '<?xml version="1.0" encoding="UTF-8"?>' >> ${IMPRINT_XML}
echo "<root>" >> ${IMPRINT_XML}
curl https://shared.acdh.oeaw.ac.at/acdh-common-assets/api/imprint.php?serviceID=${REDMINE_ID} >> ${IMPRINT_XML}
echo "</root>" >> ${IMPRINT_XML}