import shutil
import os

src = '/home/brian-vasquez/aim-arma/skills'
dest = '/home/brian-vasquez/aim-arma3/.agents/skills'

print(f"Attempting to copy {src} to {dest}...")

if not os.path.exists(dest):
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    try:
        shutil.copytree(src, dest)
        print("Success! Skills folder cloned.")
    except Exception as e:
        print(f"Error copying directory: {e}")
else:
    print("The .agents/skills directory already exists!")
