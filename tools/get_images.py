#!/usr/bin/env python3
"""EcoLoop image fetcher.

Downloads real, verified photographs from Openverse and Wikimedia Commons APIs,
resizes/crops them to spec, and saves them as bundled Flutter assets.

Usage:
    python tools/get_images.py
    python tools/get_images.py --only assets/images/products/p01.jpg
    python tools/get_images.py --pick 2
"""

import argparse
import json
import os
import re
import sys
import time
from io import BytesIO
from pathlib import Path

import requests
from PIL import Image, ImageOps

PROJECT_ROOT = Path(__file__).resolve().parent.parent
QUERIES_PATH = PROJECT_ROOT / "tools" / "queries.json"
CREDITS_PATH = PROJECT_ROOT / "tools" / "credits.json"
SOURCES_PATH = PROJECT_ROOT / "docs" / "SOURCES.md"
ASSETS_ROOT = PROJECT_ROOT / "assets" / "images"

HEADERS = {"User-Agent": "EcoLoopStudentProject/1.0 (college project)"}

# Size specs by folder
SIZE_SPECS = {
    "products": (1200, 1500),
    "hero": (1600, 900),
    "categories": (600, 600),
    "recycle": (1200, 800),
}

ACCEPTED_LICENSES = {
    "cc0", "publicdomain",
    "cc-by", "cc-by-4.0", "cc-by-3.0", "cc-by-2.0",
    "cc-by-sa", "cc-by-sa-4.0", "cc-by-sa-3.0", "cc-by-sa-2.0",
}


def log(msg):
    print(msg.encode(sys.stdout.encoding, errors="replace").decode(sys.stdout.encoding))


def load_queries():
    with open(QUERIES_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def folder_for(path_str):
    parts = Path(path_str).parts
    # assets/images/products/p01.jpg -> products
    # assets/images/hero.jpg -> hero
    # assets/images/categories/cat_x.jpg -> categories
    # assets/images/recycle/recycle_header.jpg -> recycle
    if len(parts) >= 3:
        return parts[1]  # products / categories / recycle / hero
    return "misc"


def target_size(path_str):
    folder = folder_for(path_str)
    return SIZE_SPECS.get(folder, (1200, 1500))


def normalize_license(ls):
    if not ls:
        return ""
    ls = re.sub(r"[\s\-_\.]+", "", ls.lower().strip())
    mapping = {
        "cc0": "cc0",
        "publicdomain": "publicdomain",
        "ccby": "cc-by",
        "ccbysa": "cc-by-sa",
        "ccby40": "cc-by-4.0",
        "ccbysa40": "cc-by-sa-4.0",
        "ccby30": "cc-by-3.0",
        "ccbysa30": "cc-by-sa-3.0",
        "ccby20": "cc-by-2.0",
        "ccbysa20": "cc-by-sa-2.0",
        "cc-by": "cc-by",
        "cc-by-sa": "cc-by-sa",
    }
    return mapping.get(ls, ls)


def license_ok(ls):
    n = normalize_license(ls)
    return n in ACCEPTED_LICENSES


def wait_for_rate_limit(headers, attempt):
    """Wait appropriate time on 429/5xx. Returns wait time."""
    retry_after = headers.get("Retry-After") or headers.get("retry-after")
    if retry_after:
        try:
            return int(retry_after)
        except ValueError:
            pass
    backoffs = [30, 60, 90, 120, 120, 120]
    return backoffs[min(attempt, len(backoffs) - 1)]


def fetch_with_retry(url, method="GET", params=None, max_retries=6):
    """Fetch a URL with rate-limit handling. Returns (response, success)."""
    for attempt in range(max_retries):
        try:
            resp = requests.request(
                method, url, params=params, headers=HEADERS, timeout=45
            )
            if resp.status_code in (429, 500, 502, 503, 504):
                wait = wait_for_rate_limit(resp.headers, attempt)
                log(f"   HTTP {resp.status_code}, waiting {wait}s before retry ({attempt+1}/{max_retries})")
                time.sleep(wait)
                continue
            return resp, True
        except requests.exceptions.RequestException as e:
            wait = wait_for_rate_limit({}, attempt)
            log(f"   Request error {e}, waiting {wait}s before retry ({attempt+1}/{max_retries})")
            time.sleep(wait)
    return None, False


def openverse_search(query, limit=20):
    """Search Openverse API. Returns list of candidate dicts."""
    url = "https://api.openverse.org/v1/images/"
    params = {
        "q": query,
        "license_type": "commercial",
        "category": "photograph",
        "page_size": limit,
    }
    resp, ok = fetch_with_retry(url, params=params)
    if not ok or resp is None:
        return []
    try:
        data = resp.json()
    except ValueError:
        return []
    results = data.get("results", [])
    candidates = []
    for r in results:
        url = r.get("url") or r.get("thumbnail") or ""
        if not url:
            continue
        title = r.get("title", "") or ""
        creator = r.get("creator", "") or ""
        license_str = r.get("license", "") or ""
        source_url = r.get("foreign_landing_url") or ""
        width = r.get("width") or 0
        height = r.get("height") or 0
        candidates.append({
            "title": title,
            "url": url,
            "width": width,
            "height": height,
            "license": license_str,
            "creator": creator,
            "source_url": source_url,
        })
    return candidates


def wikimedia_search(query, limit=10):
    """Search Wikimedia Commons API. Returns list of candidate dicts."""
    url = "https://commons.wikimedia.org/w/api.php"
    params = {
        "action": "query",
        "generator": "search",
        "gsrsearch": query,
        "gsrnamespace": 6,
        "gsrlimit": limit,
        "prop": "imageinfo",
        "iiprop": "url|extmetadata",
        "iiurlwidth": 1600,
        "format": "json",
    }
    resp, ok = fetch_with_retry(url, params=params)
    if not ok or resp is None:
        return []
    try:
        data = resp.json()
    except ValueError:
        return []
    pages = data.get("query", {}).get("pages", {})
    candidates = []
    for page in pages.values():
        ii = (page.get("imageinfo") or [{}])[0]
        title = page.get("title", "")
        if title.lower().endswith(".pdf"):
            continue
        em = ii.get("extmetadata", {})
        lic = em.get("LicenseShortName", {}).get("value", "")
        creator = _strip_html(em.get("Artist", {}).get("value", ""))
        image_url = ii.get("url") or ii.get("thumburl", "")
        width = ii.get("width") or ii.get("thumbwidth") or 0
        height = ii.get("height") or ii.get("thumbheight") or 0
        if not image_url:
            continue
        candidates.append({
            "title": title,
            "url": image_url,
            "width": width,
            "height": height,
            "license": lic,
            "creator": creator,
            "source_url": page.get("descriptionurl", ""),
        })
    return candidates


def _strip_html(s):
    if not s:
        return ""
    s = re.sub(r"<[^>]+>", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def size_ok(cand):
    """Check candidate is at least 700px on short side and not extreme panorama."""
    w = cand["width"]
    h = cand["height"]
    if w < 700 or h < 700:
        return False
    if w > 0 and h > 0:
        ratio = max(w, h) / min(w, h)
        if ratio > 3.0:
            return False
    return True


def download_and_process(cand, out_path, tw, th):
    """Download image, centre-crop/resize, save JPG progressive under 300KB."""
    resp, ok = fetch_with_retry(cand["url"])
    if not ok or resp is None:
        raise RuntimeError("Failed to download image")
    resp.raise_for_status()

    with Image.open(BytesIO(resp.content)) as img:
        img = img.convert("RGB")
        img = ImageOps.fit(img, (tw, th), Image.Resampling.LANCZOS)

        out_path.parent.mkdir(parents=True, exist_ok=True)
        q = 84
        while q >= 40:
            img.save(out_path, format="JPEG", quality=q, optimize=True, progressive=True)
            kb = out_path.stat().st_size / 1024
            if kb <= 300:
                break
            q -= 4
    return out_path.stat().st_size / 1024


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--only", help="Process only this asset path")
    parser.add_argument("--pick", type=int, help="Use the Nth acceptable candidate (1-based)")
    args = parser.parse_args()

    queries = load_queries()

    # Load existing credits
    existing_credits = []
    if CREDITS_PATH.exists():
        try:
            with open(CREDITS_PATH, "r", encoding="utf-8") as f:
                existing_credits = json.load(f)
        except ValueError:
            existing_credits = []
    existing_files = {c["file"] for c in existing_credits}

    items = list(queries.items())
    if args.only:
        items = [(k, v) for k, v in items if k == args.only]
        if not items:
            log(f"No query found for {args.only}")
            return

    new_credits = []

    for out_rel, query in items:
        out_path = PROJECT_ROOT / out_rel

        # Resumable: skip if already has a credit
        if out_rel in existing_files:
            log(f"SKIP (exists): {out_rel}")
            continue

        tw, th = target_size(out_rel)
        log(f"\n== {out_rel}  query='{query}'  target={tw}x{th}")

        # Wikimedia Commons (Openverse is blocked in this environment)
        wm_candidates = wikimedia_search(query, limit=10)
        log(f"   Wikimedia: {len(wm_candidates)} candidates")
        all_candidates = wm_candidates
        # If Openverse is blocked, skip its delay

        # Filter
        acceptable = []
        for cand in all_candidates:
            lic_ok = license_ok(cand["license"])
            size_ok_result = size_ok(cand)
            log(f"   CAND: {cand['title'][:50]} | lic={cand['license']}->{'OK' if lic_ok else 'REJECT'} | {cand['width']}x{cand['height']}->{'OK' if size_ok_result else 'REJECT'}")
            if not lic_ok:
                continue
            if not size_ok_result:
                continue
            if cand["url"] in {c.get("url") for c in acceptable}:
                continue
            acceptable.append(cand)

        log(f"   Acceptable: {len(acceptable)}")

        if not acceptable:
            log(f"   NO SUITABLE IMAGE")
            continue

        pick_index = None
        if args.pick is not None:
            pick_index = args.pick - 1

        success = False
        for i, cand in enumerate(acceptable):
            if pick_index is not None and i != pick_index:
                continue
            try:
                kb = download_and_process(cand, out_path, tw, th)
                log(f"   SAVE ({kb:.0f}KB) lic={cand['license']} creator={cand['creator'][:40]}")
                log(f"   SRC: {cand['source_url']}")
                new_credits.append({
                    "file": out_rel,
                    "title": cand["title"],
                    "creator": cand["creator"],
                    "license": cand["license"],
                    "source_url": cand["source_url"],
                    "image_url": cand["url"],
                })
                success = True
                break
            except Exception as e:
                log(f"   FAIL {cand['title'][:50]}: {str(e)[:100]}")
                out_path.unlink(missing_ok=True)
                time.sleep(2)

        if not success:
            log(f"   NO IMAGE SAVED")

        time.sleep(1.5)

    # Merge credits
    all_credits = existing_credits + new_credits
    CREDITS_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(CREDITS_PATH, "w", encoding="utf-8") as f:
        json.dump(all_credits, f, indent=2, ensure_ascii=False)

    # Update SOURCES.md
    if SOURCES_PATH.exists():
        content = SOURCES_PATH.read_text(encoding="utf-8")
        content = re.sub(r"\n## Image Credits.*", "", content, flags=re.S)
        content += "\n## Image Credits\n\nAll photos are from Openverse and Wikimedia Commons (CC0 / CC BY / CC BY-SA / Public Domain).\n\n"
        content += "| File | Subject | Creator | Licence | Source Page |\n"
        content += "|------|---------|---------|---------|-------------|\n"
        for c in all_credits:
            content += f"| {c['file']} | {c['title']} | {c['creator']} | {c['license']} | {c['source_url']} |\n"
        SOURCES_PATH.write_text(content, encoding="utf-8")

    log(f"\nDone. {len(new_credits)} new images, {len(all_credits)} total credits.")


if __name__ == "__main__":
    main()
