denormalize-indices -f "data/critics/editions/*.xml" -i "data/indices/*.xml" -m './/tei:rs[@ref]/@ref' -t 'erwähnt in ' -x './/tei:title[@type="main"]/text()'
denormalize-indices -f "data/traktat/editions/*.xml" -i "data/indices/*.xml" -m './/tei:rs[@ref]/@ref' -t 'erwähnt in ' -x './/tei:title[@type="main"]/text()'