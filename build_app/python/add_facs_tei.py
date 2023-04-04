import os
import glob

from utils import facs_to_tei


files = sorted(glob.glob(os.path.join("data", "traktat", "editions", "*.xml")))
facs = sorted(glob.glob(os.path.join("traktat-facs", "*", "*_out.csv")))

for fi, fc in zip(files, facs):
    try:
        facs_to_tei(fpath=fi, fnames=fc)
    except Exception as err:
        print(err)
