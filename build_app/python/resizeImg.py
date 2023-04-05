import os, glob
from PIL import Image

files = glob.glob("./traktat-facs/0006/sub2/*.jp2")

for infile in sorted(files):
    try:
        with Image.open(infile) as im:
            (width, height) = (im.width // 4, im.height // 4)
            im_resized = im.resize((width, height))
        print(f"resizing {infile} to width: {width} and height: {height}")
    except OSError:
        print("cannot convert", infile)
