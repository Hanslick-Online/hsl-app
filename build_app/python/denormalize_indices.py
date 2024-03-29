from utils import denormalize_indices


files = "data/traktat/editions/*.xml"
indices = "data/indices/*.xml"
mention_xpath = ".//tei:rs[@ref]/@ref"
title_xpath = ".//tei:title[@type='main']/text()"
title_xpath_sub = ".//tei:sourceDesc//tei:edition/text()"

denormalize_indices(
    files, indices, mention_xpath, title_xpath, title_xpath_sub, blacklist_ids=[]
)

files = "data/critics/editions/*.xml"
indices = "data/indices/*.xml"
mention_xpath = ".//tei:rs[@ref]/@ref"
title_xpath = ".//tei:title[@type='main']/text()"
title_xpath_sub = ".//tei:sourceDesc//tei:edition/text()"

denormalize_indices(
    files, indices, mention_xpath, title_xpath, title_xpath_sub, blacklist_ids=[]
)
