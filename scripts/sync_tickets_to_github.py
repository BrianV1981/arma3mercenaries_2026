#!/usr/bin/env python3
"""
sync_tickets_to_github.py
Author: A.I.M.
Description: Scans native Arma 3 .rpt/log files for A3M_TICKETS_EXPORT logs and pushes new tickets to GitHub.
"""
import os
import sys
import json
import subprocess
import glob

# Paths
SERVER_LOGS_DIR = "/home/brian-vasquez/arma3server/server_logs"
HISTORY_FILE = "/home/brian-vasquez/arma3server/server_logs/synced_tickets.txt"
REPO_OWNER = "BrianV1981"
REPO_NAME = "arma3mercenaries_2026"

def get_synced_hashes():
    if not os.path.exists(HISTORY_FILE):
        return set()
    with open(HISTORY_FILE, 'r') as f:
        return set(line.strip() for line in f if line.strip())

def save_synced_hash(ticket_hash):
    with open(HISTORY_FILE, 'a') as f:
        f.write(ticket_hash + '\n')

def main():
    if not os.path.exists(SERVER_LOGS_DIR):
        print(f"[A3M Sync] Server logs directory not found: {SERVER_LOGS_DIR}")
        return

    # Find all .log and .rpt files
    log_files = glob.glob(os.path.join(SERVER_LOGS_DIR, "*.log")) + glob.glob(os.path.join(SERVER_LOGS_DIR, "*.rpt"))
    
    if not log_files:
        print("[A3M Sync] No server logs found. Nothing to sync.")
        return

    synced_hashes = get_synced_hashes()
    success_count = 0

    print(f"[A3M Sync] Scanning {len(log_files)} log files for tickets...")

    for log_file in log_files:
        try:
            with open(log_file, 'r', errors='replace') as f:
                for line in f:
                    if "[A3M_TICKETS_EXPORT]" not in line:
                        continue
                        
                    try:
                        # Format: ... [A3M_TICKETS_EXPORT] {"author":"...", ...}
                        json_str = line.split("[A3M_TICKETS_EXPORT]", 1)[1].strip()
                        ticket_data = json.loads(json_str)
                        
                        author = ticket_data.get("author", "Unknown Player")
                        uid = ticket_data.get("uid", "Unknown UID")
                        title = ticket_data.get("title", "No Title")
                        desc = ticket_data.get("description", "No Description")
                        
                        # Create a unique hash for this exact ticket to avoid duplicates
                        import hashlib
                        ticket_hash = hashlib.md5(f"{uid}:{title}:{desc}".encode()).hexdigest()
                        
                        if ticket_hash in synced_hashes:
                            continue # Already synced
                            
                        # Format the GitHub issue body
                        issue_body = f"**Reporter:** {author} (UID: `{uid}`)\n\n**Description:**\n{desc}\n\n---\n*This ticket was automatically generated from the A3M In-Game Bug Reporter via RPT logs.*"
                        
                        # Run GitHub CLI
                        cmd = [
                            "gh", "issue", "create",
                            "--repo", f"{REPO_OWNER}/{REPO_NAME}",
                            "--title", f"[Player Ticket] {title}",
                            "--body", issue_body,
                            "--label", "bug"
                        ]
                        
                        print(f"[A3M Sync] Pushing ticket '{title}' to GitHub...")
                        subprocess.run(cmd, check=True)
                        
                        # Mark as synced
                        save_synced_hash(ticket_hash)
                        synced_hashes.add(ticket_hash)
                        success_count += 1
                        
                    except Exception as e:
                        print(f"[A3M Sync] ERROR parsing line: {line.strip()}\nException: {e}")
        except Exception as e:
            print(f"[A3M Sync] Could not read file {log_file}: {e}")

    print(f"[A3M Sync] Successfully synced {success_count} new tickets.")

if __name__ == "__main__":
    main()
