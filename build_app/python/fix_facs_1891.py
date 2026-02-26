#!/usr/bin/env python
"""
Postprocessing script to fix scrambled facsimile page references in
edition 8 (1891) of VMS.

Problem: The facsimile digitization of edition 8 has errors starting from
page 002 (https://id.acdh.oeaw.ac.at/hanslick-vms/vms_1891_002.tif is the
wrong image). From that point on, every even-numbered page file contains the
wrong content:
  - file 004.tif actually shows page 002
  - file 006.tif actually shows page 004
  - file 008.tif actually shows page 006
  - ...
  - file 222.tif actually shows page 220

Odd-numbered pages (001, 003, 005, ..., 221) are correct.

Fix: For even-numbered pages 002–220, remap the facs URL in <pb> elements
from vms_1891_NNN.tif to vms_1891_{NNN+2}.tif so that the correct image is
served. The <facsimile>/<surface>/<graphic> declarations are left unchanged:
they describe which image files exist (the files are still there, just with
wrong content), while <pb facs> is the reference that drives what image the
reader sees for a given page.

The script is idempotent: it uses the page number from the <pb n="[N]">
attribute to determine the expected original URL, and only applies the fix
when the URL matches that original pattern.

See: https://github.com/Hanslick-Online/hsl-app/issues/178

Usage:
    python build_app/python/fix_facs_1891.py
"""

import re
import os


EDITION_FILE = os.path.join(
    "data", "traktat", "editions", "08_VMS_1891_TEI_AW_26-01-21-TEI-P5.xml"
)

BASE_URL = "https://id.acdh.oeaw.ac.at/hanslick-vms/vms_1891_"

# Pattern to match <pb> elements with facs attribute containing a numeric
# page URL. Captures:
#   1: everything up to and including facs="<base_url>
#   2: the zero-padded page number
#   3: .tif" and rest of element
# Also captures the n="[N]" attribute to extract the logical page number.
PB_PATTERN = re.compile(
    r'(<pb\b[^>]*\bn=")\[(\d+)\]("[^>]*\bfacs="'
    + re.escape(BASE_URL)
    + r')(\d{3})(\.tif")'
)

# Range of even pages that need fixing: 002, 004, 006, ..., 220
EVEN_PAGES_TO_FIX = set(range(2, 221, 2))


def fix_pb_facs(match: re.Match) -> str:
    """
    For <pb> elements referencing even-numbered pages 002–220, remap the
    facs URL to point to the file that actually contains the correct image.

    Uses the logical page number from n="[N]" to determine if a fix is
    needed and what the correct URL should be, making the operation
    idempotent.
    """
    pre_n = match.group(1)  # '<pb ... n="'
    page_n = match.group(2)  # page number from n="[N]"
    mid = match.group(3)  # ']" ... facs="<base_url>'
    # url_num = match.group(4)  # page number from URL
    post = match.group(5)  # '.tif"'

    logical_page = int(page_n)

    if logical_page in EVEN_PAGES_TO_FIX:
        corrected_num = logical_page + 2
        return f"{pre_n}[{page_n}]{mid}{corrected_num:03d}{post}"

    # Not an even page that needs fixing — return unchanged
    return match.group(0)


def fix_edition_file(filepath: str) -> None:
    """Read the XML file, fix facsimile URLs in <pb> elements, write back."""
    if not os.path.isfile(filepath):
        print(f"ERROR: File not found: {filepath}")
        return

    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Count actual changes (where page number is even and in range)
    changes = 0

    def counting_fix(match: re.Match) -> str:
        nonlocal changes
        result = fix_pb_facs(match)
        if result != match.group(0):
            changes += 1
        return result

    new_content = PB_PATTERN.sub(counting_fix, content)

    if new_content == content:
        print(f"No changes needed in {filepath} (already fixed or pattern not found)")
        return

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(new_content)

    print(f"Fixed {changes} <pb> facs URL(s) in {filepath}")


if __name__ == "__main__":
    fix_edition_file(EDITION_FILE)
