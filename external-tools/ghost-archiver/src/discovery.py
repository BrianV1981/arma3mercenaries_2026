import json
import os
import time
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
from stealth_driver import GhostDriver

class GhostDiscovery:
    def __init__(self, config_path="config.json"):
        with open(config_path, "r") as f:
            self.config = json.load(f)
            
        self.driver = GhostDriver(self.config)
        self.start_url = self.config['target_url']
        self.domain = self.config['domain_constraint']
        self.output_file = self.config['paths']['map_file']
        
        os.makedirs(os.path.dirname(os.path.abspath(self.output_file)), exist_ok=True)

    def run(self, page_limit=0):
        """Executes a Breadth-First Search to map the target domain."""
        queue = [self.start_url]
        visited = set()
        all_pages = []
        
        print(f"=== Ghost-Archiver Discovery Started: {self.domain} ===")
        
        # 1. Initialize Main Tab
        self.driver.execute(f"open \"{self.start_url}\"")
        
        while queue:
            current_url = queue.pop(0)
            if current_url in visited:
                continue
                
            print(f"[*] Exploring: {current_url}")
            visited.add(current_url)
            
            try:
                # Open in transient tab
                self.driver.execute(f"open \"{current_url}\"")
                # Shorter wait for discovery vs full archival
                time.sleep(self.config['stealth']['min_dwell_time'])
                
                html = self.driver.extract_html()
                if not html:
                    print(f"  [!] No HTML for {current_url}")
                    continue
                    
                soup = BeautifulSoup(html, 'html.parser')
                
                # Save this page to our map
                title = soup.title.string.strip() if soup.title else current_url
                all_pages.append({"title": title, "url": current_url})
                
                # Extract links for the queue
                links_found = 0
                for a in soup.find_all("a", href=True):
                    href = a["href"]
                    full_url = urljoin(current_url, href)
                    parsed = urlparse(full_url)
                    
                    # Filter: same domain, not visited, not already in queue
                    if parsed.netloc == self.domain:
                        # Strip fragments for comparison
                        clean_url = full_url.split('#')[0]
                        if clean_url not in visited and clean_url not in queue:
                            # Basic generalized filter to avoid non-content loops
                            if not any(x in clean_url for x in [".php?", "action=", "login", "signup"]):
                                queue.append(clean_url)
                                links_found += 1
                
                print(f"    - Found {links_found} new links | Total Mapped: {len(all_pages)} | Queue: {len(queue)}")
                
            except Exception as e:
                print(f"  [Error] Failed to map {current_url}: {e}")
            finally:
                self.driver.enforce_tab_lockdown()
                time.sleep(1)
                
            # Optional safety break
            if page_limit > 0 and len(all_pages) >= page_limit:
                print(f"[INFO] Reached requested {page_limit}-page limit.")
                break

        # Save Map
        with open(self.output_file, "w") as f:
            json.dump(all_pages, f, indent=2)
        
        print(f"\n[DONE] Discovery Complete: {len(all_pages)} targets saved to {self.output_file}")

if __name__ == "__main__":
    config_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "config.json")
    discovery = GhostDiscovery(config_path)
    discovery.run()
