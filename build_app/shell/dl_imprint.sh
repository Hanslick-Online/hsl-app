# bin/bash

REDMINE_ID=21428
IMPRINT_XML=./data/imprint.xml
rm ${IMPRINT_XML}
touch ${IMPRINT_XML}
echo '<?xml version="1.0" encoding="UTF-8"?>' >> ${IMPRINT_XML}
echo "<root><div>" >> ${IMPRINT_XML}
curl "https://imprint.acdh.oeaw.ac.at/${REDMINE_ID}/?locale=de&format=xhtml" >> ${IMPRINT_XML}
echo "</div></root>" >> ${IMPRINT_XML}

IMPRINT_XML=./data/imprint_en.xml
rm ${IMPRINT_XML}
touch ${IMPRINT_XML}
echo '<?xml version="1.0" encoding="UTF-8"?>' >> ${IMPRINT_XML}
echo "<root><div>" >> ${IMPRINT_XML}
curl "https://imprint.acdh.oeaw.ac.at/${REDMINE_ID}/?locale=en&format=xhtml" >> ${IMPRINT_XML}
echo "</div></root>" >> ${IMPRINT_XML}