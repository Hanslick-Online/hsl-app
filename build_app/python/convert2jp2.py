import os, glob
from PIL import Image

files = glob.glob("./traktat-facs/0009/sub/*.tif")

for infile in sorted(files):
    f, e = os.path.splitext(infile)
    outfile = f + ".jp2"
    
    print(outfile)
    if infile != outfile:
        try:
            with Image.open(infile) as im:
                im.convert("RGBA").save(outfile, 'JPEG2000', quality_mode='dB', quality_layers=[41])
            os.remove(infile)
        except OSError:
            print("cannot convert", infile)
