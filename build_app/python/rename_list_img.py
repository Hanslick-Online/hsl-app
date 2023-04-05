import os
import glob
import pandas as pd

from PIL import Image


dirs = glob.glob("./traktat-facs/*")
print(dirs)

def rename_files(dirs=dirs):
    for d in dirs:
        files = glob.glob(f"{d}/sub")
        for x in files:
            tif = glob.glob(f"{x}/*")
            print(tif)
            for idx, f in enumerate(sorted(tif)):
                print(f)
                fn = f.split("/")
                sv_dir = fn[1]
                sv_dir2 = fn[2]
                sv_dir3 = fn[3]
                sv_fn = fn[4]
                if sv_dir2 == "1":
                    os.rename(f, os.path.join(sv_dir, sv_dir2, sv_dir3, f"vms_1854_{sv_fn.split('_')[-1]}"))
                if sv_dir2 == "2":
                    os.rename(f, os.path.join(sv_dir, sv_dir2, sv_dir3, f"vms_1858_{sv_fn.split('_')[-1]}"))
                if sv_dir2 == "3":
                    n = int(sv_fn.split("-")[-1].split(".")[0])
                    os.rename(f, os.path.join(sv_dir, sv_dir2, sv_dir3, f"vms_1865_{n:04d}.jp2"))
                if sv_dir2 == "4":
                    os.rename(f, os.path.join(sv_dir, sv_dir2, sv_dir3, f"vms_1874_{sv_fn.split('_')[-1]}"))
                if sv_dir2 == "5":
                    n = int(sv_fn.split("-")[-1].split(".")[0])
                    os.rename(f, os.path.join(sv_dir, sv_dir2, sv_dir3, f"vms_1876_{n:04d}.jp2"))
                if sv_dir2 == "0006":
                    os.rename(f, os.path.join(sv_dir, sv_dir2, sv_dir3, f"vms_1881_{idx:04d}.tif"))
                if sv_dir2 == "0007":
                    os.rename(f, os.path.join(sv_dir, sv_dir2, sv_dir3, f"vms_1885_{idx:04d}.tif"))
                if sv_dir2 == "0008":
                    os.rename(f, os.path.join(sv_dir, sv_dir2, sv_dir3, f"vms_1891_{idx:04d}.tif"))
                if sv_dir2 == "9":
                    os.rename(f, os.path.join(sv_dir, sv_dir2, sv_dir3, f"vms_1896_{sv_fn.split('_')[-1]}"))
                if sv_dir2 == "10":
                    os.rename(f, os.path.join(sv_dir, sv_dir2, sv_dir3, f"vms_1902_{sv_fn.split('_')[-1]}"))

# rename_files()

def yield_img_dict(images):
    for x in images:
        item = {}
        item['id'] = os.path.basename(x).split('.')[0]
        with Image.open(x) as image:
            item['width'], item['height'] = image.width, image.height
        yield item

for x in dirs:
    dir = x
    dirNo = int(dir.split("/")[-1])
    dirNo = f"{dirNo:04d}"
    images = sorted(glob.glob(f"{dir}/sub/*"))
    df = pd.DataFrame(yield_img_dict(images), columns=['id', 'width', 'height'])
    df.to_csv(f'{dir}/{dirNo}_out.csv', index=False)
