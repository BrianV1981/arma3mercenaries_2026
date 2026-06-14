#!/usr/bin/env python3
"""
sync_tickets_to_github.py
Author: A.I.M.
Description: Reads the extDB3 A3M_Tickets log file and pushes new tickets natively to GitHub.
"""
import os
import sys
import json
import subprocess
import shutil

# Paths
EXTDB3_LOG_PATH = "/home/brian-vasquez/arma3server/@extDB3/logs/A3M_Tickets.log"
BACKUP_LOG_PATH = "/home/brian-vasquez/arma3server/@extDB3/logs/A3M_Tickets.bak.log"
REPO_OWNER = "BrianV1981"
REPO_NAME = "arma3mercenaries_2026"

def main():
    if not os.path.exists(EXTDB3_LOG_PATH):
        print(f"[A3M Sync] No ticket log found at {EXTDB3_LOG_PATH}. Nothing to sync.")
        return

    # Read and process the log file
    with open(EXTDB3_LOG_PATH, 'r') as f:
        lines = f.readlines()

    if not lines:
        print("[A3M Sync] Ticket log is empty. Nothing to sync.")
        return

    print(f"[A3M Sync] Found {len(lines)} raw log lines. Parsing...")
    
    success_count = 0
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        # extDB3 logs are prefixed with timestamps. We need to extract the JSON.
        # Format: [HH:MM:SS] extDB3: A3M_Tickets: {"author":"...", ...}
        if "A3M_Tickets:" not in line:
            continue
            
        try:
            json_str = line.split("A3M_Tickets:", 1)[1].strip()
            ticket_data = json.loads(json_str)
            
            author = ticket_data.get("author", "Unknown Player")
            uid = ticket_data.get("uid", "Unknown UID")
            title = ticket_data.get("title", "No Title")
            desc = ticket_data.get("description", "No Description")
            
            # Format the GitHub issue body
            issue_body = f"**Reporter:** {author} (UID: `{uid}`)\n\n**Description:**\n{desc}\n\n---\n*This ticket was automatically generated from the A3M In-Game Bug Reporter.*"
            
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
            success_count += 1
            
        except Exception as e:
            print(f"[A3M Sync] ERROR processing line: {line}\nException: {e}")

    # Backup the log and clear it so we don't process them again
    try:
        shutil.copy2(EXTDB3_LOG_PATH, BACKUP_LOG_PATH)
        open(EXTDB3_LOG_PATH, 'w').close()
        print(f"[A3M Sync] Successfully synced {success_count} tickets. Log cleared and backed up.")
    except Exception as e:
        print(f"[A3M Sync] ERROR clearing log file: {e}")

if __name__ == "__main__":
    main()
