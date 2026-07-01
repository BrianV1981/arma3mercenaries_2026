import subprocess
import os
import time
import random

class GhostDriver:
    def __init__(self, config):
        self.clawgle_bin = config['clawgle']['bin_path']
        self.cdp_port = str(config['clawgle']['cdp_port'])
        self.state_file = os.path.expanduser(config['clawgle']['state_file'])
        
        # Ensure absolute path for Clawgle bin if it's relative
        if not os.path.isabs(self.clawgle_bin):
            # Assume it's relative to the project root for now, or require absolute in config
            base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            self.clawgle_bin = os.path.normpath(os.path.join(base_dir, self.clawgle_bin))
            
        self.stealth_config = config['stealth']

    def execute(self, cmd_args):
        """Executes a Clawgle command with the configured environment."""
        env = os.environ.copy()
        env["CLAWGLE_STATE_FILE"] = self.state_file
        env["CDP_PORT"] = self.cdp_port
        
        # We need to call node explicitly
        full_cmd = f"/usr/bin/node {self.clawgle_bin} {cmd_args}"
        
        try:
            result = subprocess.run(full_cmd, shell=True, capture_output=True, text=True, check=True, env=env)
            return result.stdout.strip()
        except subprocess.CalledProcessError as e:
            # print(f"  [GhostDriver Error] {e.stderr}")
            return None

    def mimic_human(self):
        """Performs randomized actions to simulate human presence."""
        action_types = ["scroll", "wiggle", "idle"]
        num_actions = random.randint(
            self.stealth_config['human_actions_min'], 
            self.stealth_config['human_actions_max']
        )
        
        for _ in range(num_actions):
            action = random.choice(action_types)
            if action == "scroll":
                time.sleep(random.uniform(0.5, 1.5))
            elif action == "wiggle":
                x, y = random.randint(100, 800), random.randint(100, 600)
                self.execute(f"tapxy {x} {y}")
            elif action == "idle":
                time.sleep(random.uniform(1.0, 2.5))

    def enforce_tab_lockdown(self):
        """Nuclear sweep: Closes all tabs except index 0 (The Anchor)."""
        import json
        try:
            tabs_json = self.execute("tabs --json")
            if not tabs_json: return
            tabs = json.loads(tabs_json)
            if len(tabs) > 1:
                # Close from the end to avoid index shifting issues
                for i in range(len(tabs) - 1, 0, -1):
                    self.execute(f"close {i}")
        except Exception:
            pass

    def open_and_wait(self, url):
        """Opens a URL in a new transient tab and applies initial dwell time."""
        self.execute(f"open \"{url}\"")
        time.sleep(random.uniform(self.stealth_config['min_dwell_time'], self.stealth_config['max_dwell_time']))
        
    def extract_html(self):
        """Extracts the fully rendered HTML DOM."""
        return self.execute("html")
        
    def cleanup(self):
        """Closes the transient tab and applies a cooldown."""
        self.enforce_tab_lockdown()
        time.sleep(random.uniform(1.0, 3.0))
