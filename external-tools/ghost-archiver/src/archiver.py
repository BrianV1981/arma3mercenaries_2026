import json
import os
import re
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
from stealth_driver import GhostDriver

class GhostArchiver:
    def __init__(self, config_path="config.json"):
        # Load Config
        with open(config_path, "r") as f:
            self.config = json.load(f)
            
        self.driver = GhostDriver(self.config)
        
        # Setup Paths
        self.output_dir = self.config['paths']['output_dir']
        self.map_file = self.config['paths']['map_file']
        self.asset_dir = os.path.join(self.output_dir, "assets")
        self.base_url = self.config['target_url']
        
        os.makedirs(self.asset_dir, exist_ok=True)
        self.downloaded_assets = set()

    def sanitize_title(self, title):
        """Generates a safe filename from a page title."""
        return re.sub(r'[^\w\.-]', '_', title)

    def download_asset(self, url):
        """Downloads an image or CSS file, keeping a local cache to avoid re-downloads."""
        if not url or url in self.downloaded_assets:
            return None
            
        # Resolve relative URLs
        if url.startswith("//"): url = "https:" + url
        elif url.startswith("/"): url = urljoin(self.base_url, url)
            
        parsed = urlparse(url)
        filename = os.path.basename(parsed.path)
        if not filename or len(filename) < 3: return None
        
        filename = self.sanitize_title(filename)
        local_path = os.path.join(self.asset_dir, filename)
        
        try:
            res = requests.get(url, headers={"User-Agent": "Mozilla/5.0"}, timeout=2.0)
            if res.status_code == 200:
                with open(local_path, "wb") as f:
                    f.write(res.content)
                self.downloaded_assets.add(url)
                return f"assets/{filename}"
        except Exception:
            pass # Failsafe: if an asset 404s or times out, keep moving
        return None

    def localize_dom(self, html_content):
        """Parses HTML, downloads assets, and rewrites internal links to be offline-compatible."""
        soup = BeautifulSoup(html_content, 'html.parser')
        
        # 1. Harvest & Rewrite Images
        for img in soup.find_all("img"):
            local_src = self.download_asset(img.get("src"))
            if local_src: img["src"] = local_src
                
        # 2. Harvest & Rewrite Stylesheets
        for link in soup.find_all("link", rel="stylesheet"):
            local_href = self.download_asset(link.get("href"))
            if local_href: link["href"] = local_href

        # 3. Localize Internal Links (Make them point to other local HTML files)
        domain = urlparse(self.base_url).netloc
        for a in soup.find_all("a", href=True):
            href = a["href"]
            
            # Simple heuristic: if it's a relative path or points to our target domain
            if (href.startswith("/") or domain in href) and "://" not in href:
                # Extract the last part of the path as the "title"
                # This logic is generalized, but might need tweaking per-wiki engine
                parsed_href = urlparse(href)
                path_parts = [p for p in parsed_href.path.split("/") if p]
                if path_parts:
                    target_title = path_parts[-1]
                    main_t = target_title.split("#")[0]
                    frag = "#" + target_title.split("#")[1] if "#" in target_title else ""
                    a["href"] = f"./{self.sanitize_title(main_t)}.html{frag}"

        return str(soup)

    def archive_target(self, target):
        """Executes the full extraction and localization lifecycle for a single target."""
        title = target.get('title', 'Unknown')
        url = target.get('url')
        
        safe_title = self.sanitize_title(title)
        filepath = os.path.join(self.output_dir, f"{safe_title}.html")
        
        # Failsafe: Resume capability
        if os.path.exists(filepath):
            return True

        print(f"[*] Archiving: {title}")
        try:
            self.driver.open_and_wait(url)
            self.driver.mimic_human()
            
            raw_html = self.driver.extract_html()
            if not raw_html:
                print(f"  [!] Failed to extract HTML from {url}")
                return False

            localized_html = self.localize_dom(raw_html)
            
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(localized_html)
                
            return True
        except Exception as e:
            print(f"  [Error] Failed processing {title}: {e}")
            return False
        finally:
            self.driver.cleanup()

    def run(self):
        """Starts the archival process using the provided map file."""
        if not os.path.exists(self.map_file):
            print(f"[Error] Map file {self.map_file} not found. Run discovery phase first.")
            return

        with open(self.map_file, "r") as f:
            targets = json.load(f)

        print(f"=== Ghost-Archiver Started: {len(targets)} Targets ===")
        print(f"[*] Target Config: {self.config['project_name']} ({self.base_url})")
        print("[*] Minimizing browser for low-profile operation...")
        self.driver.execute("minimize")

        success_count = 0
        try:
            for target in targets:
                if self.archive_target(target):
                    success_count += 1
                if success_count % 10 == 0:
                    print(f"--- Progress: {success_count}/{len(targets)} pages archived ---")
        except KeyboardInterrupt:
            print("\n[!] Archival paused by user.")

        print(f"\n[DONE] Archival session finished. {success_count} pages processed.")

if __name__ == "__main__":
    # Assuming config is in the parent directory when run from src/
    config_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "config.json")
    archiver = GhostArchiver(config_path)
    archiver.run()
