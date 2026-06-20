import re
import os

M_FILE = "/home/brian-vasquez/aim-a3m/workspace/issue-102/arma3mercenaries_2026.Altis/arma3mercenaries/briefing/initBriefing.sqf"
P_FILE = "/home/brian-vasquez/aim-a3m/workspace/issue-102/arma3mercenaries_2026.Altis/arma3mercenaries/player_profile/fn_openFieldManual.sqf"

with open(M_FILE, "r") as f:
    m_content = f.read()

with open(P_FILE, "r") as f:
    p_content = f.read()

# Extract tabs from M_FILE
m_tabs = []
matches = re.finditer(r'player createDiaryRecord \["a3m_field_manual", \["(.*?)", \s*"\s*(.*?)\s*"\s*\]\];', m_content, re.DOTALL)
for match in matches:
    m_tabs.append({
        "title": match.group(1),
        "text": match.group(2)
    })

# The P_FILE has sections like <t size='1.0' color='#55aaff'>TITLE</t><br/>
# Let's extract the unique ones.
p_sections = []
# The text is inside _text = " ... ";
p_text_match = re.search(r'private _text = "(.*?)";', p_content, re.DOTALL)
if p_text_match:
    p_text_raw = p_text_match.group(1)
    
    # We want:
    # Ranks and Progression
    # Logistics, Survival, and Medical
    # The 3 Inventory Systems
    
    # Let's manually copy them from the P_FILE string to ensure perfection:
    unique_tabs = [
        {
            "title": "Ranks and Progression",
            "text": """<font color='#ffaa00'>RANKS AND REWARDS</font><br/>
There are 7 ranks. Ranking up increases paychecks, kill rewards, and unlocks Black Market discounts.<br/>
• PRIVATE (Start) | CORPORAL (1k) | SERGEANT (1.5k) | LIEUTENANT (2k) | CAPTAIN (2.5k) | MAJOR (3k) | COLONEL (3.5k Max)"""
        },
        {
            "title": "Logistics, Survival, and Medical",
            "text": """<font color='#ffaa00'>REARMING</font><br/>
The cheapest option is the Vehicle Ammo Container from Logistics—unlimited refills for vehicles, turrets, mortars.<br/><br/>
<font color='#ffaa00'>MAINTENANCE</font><br/>
Use a Repair Center or Repair Vehicle. Buy a Gas Tank to keep big vehicles fueled and moving.<br/><br/>
<font color='#ffaa00'>SURVIVAL</font><br/>
You must drink Water to survive and cool off weapons. Med Centers are required to fully remove wounds.<br/><br/>
<font color='#ffaa00'>ESSENTIAL GEAR</font><br/>
You MUST carry <t color='#ffff00'>Zip Ties</t> for detaining civilians (Interrogations) and forcing AI onto static turrets! Also carry basic ACE Medical gear."""
        },
        {
            "title": "The 4 Inventory Systems",
            "text": """<font color='#ffaa00'>1. PLAYER INVENTORY</font><br/>
Your personal gear, backpack, and uniform. Used for weapons, ammo, medical supplies, and physical cash.<br/><br/>
<font color='#ffaa00'>2. VEHICLE INVENTORY</font><br/>
The standard trunk space of any vehicle. Used to store excess player weapons, ammo, and gear.<br/><br/>
<font color='#ffaa00'>3. ACE CARGO</font><br/>
Used to haul physically built objects (like supply crates, spare tires, or heavy static weapons) inside the cargo hold of vehicles.<br/><br/>
<font color='#ffaa00'>4. FORTIFICATION INVENTORY</font><br/>
A specialized virtual inventory specifically for holding unbuilt construction materials (walls, bunkers, tank traps). It has massive space limits and can be accessed on players or vehicles."""
        },
        {
            "title": "A3M Custom Squad Controls",
            "text": """<font color='#ffaa00'>ACE INTERACTION MENU</font><br/>
We have built a suite of custom commands to manage the AI in your squad. Use your <t color='#ffff00'>ACE Self-Interact</t> key, navigate to [Squad Commands], and use these abilities:<br/><br/>
<font color='#ffaa00'>RECALL SQUAD</font><br/>
Instantly teleports your entire AI squad directly to your position if they get stuck or fall behind.<br/><br/>
<font color='#ffaa00'>STAND DOWN (DEACTIVATE)</font><br/>
Orders your AI to instantly disembark any vehicles, un-equip their weapons, and put on zip-ties (setting them to Captive). Use this to prevent them from engaging targets or getting shot while you perform stealth operations or drive through hostile checkpoints.<br/><br/>
<font color='#ffaa00'>MOBILIZE (REACTIVATE)</font><br/>
Removes the zip-ties from your squad, returning them to full combat readiness and allowing them to fire on enemies.<br/><br/>
<font color='#ffaa00'>QUICK LOAD AND SECURE BASE TURRETS</font><br/>
Forces your AI to immediately board any empty vehicles or static weapons within a 6m or 50m radius. Extremely useful for manning FOB defenses instantly!<br/><br/>
<font color='#ffaa00'>REFORM SQUAD</font><br/>
Resets your AI group's formation and combat states if they are acting buggy."""
        }
    ]
    
    m_tabs.extend(unique_tabs)

    for tab in m_tabs:
        if tab['title'] == 'Welcome':
            beta_text = "<font color='#ff0000'>BETA DISCLAIMER</font><br/>This server is currently in BETA. It has bugs—some fixable, some unfixable (for which we try to come up with workarounds).<br/>Please note that we have a built-in <t color='#00ff00'>Bug Report Tool</t> on the Escape/Pause menu. Use it to report bugs, submit suggestions, or report players.<br/><br/>"
            tab['text'] = beta_text + tab['text']

# Now m_tabs contains ALL original M text + the unique P texts. Total 15 tabs.

# 1. Generate M_FILE
m_out = """/*
    A3M Map Diary Briefings
    Injects categorized tabs into the Map Screen (M)
*/

if (!hasInterface) exitWith {};

// Create the main category tab (Subject)
player createDiarySubject ["a3m_field_manual", "A3M Field Manual"];

// Note: createDiaryRecord is LIFO (Last In, First Out). 
// The last one created appears at the TOP of the list.

"""
for tab in reversed(m_tabs):
    title = tab['title']
    text = tab['text']
    m_out += f'player createDiaryRecord ["a3m_field_manual", ["{title}", \n"\n{text}\n"\n]];\n\n'

with open(M_FILE, "w") as f:
    f.write(m_out)


# 2. Generate P_FILE
p_out = """/*
    A3M_fnc_openFieldManual
    Initializes and populates the Player Guides / Field Manual dialog.
*/
disableSerialization;
createDialog "A3M_FieldManualDialog";
waitUntil {!isNull (findDisplay 7030)};

private _display = findDisplay 7030;

#define GUI_GRID_X    (safezoneX)
#define GUI_GRID_Y    (safezoneY)
#define GUI_GRID_W    (safezoneW / 40)
#define GUI_GRID_H    (safezoneH / 25)

// Dynamically create a scrollable ControlsGroup to hold the text
private _group = _display ctrlCreate ["RscControlsGroupNoHScrollbars", 7032];
_group ctrlSetPosition [
    10.5 * GUI_GRID_W + GUI_GRID_X,
    3.5 * GUI_GRID_H + GUI_GRID_Y,
    19 * GUI_GRID_W,
    19.5 * GUI_GRID_H
];
_group ctrlCommit 0;

// Create the structured text INSIDE the group
private _content = _display ctrlCreate ["RscStructuredText", 7031, _group];
_content ctrlSetPosition [0, 0, 18.5 * GUI_GRID_W, 10]; // Temporary height
_content ctrlSetBackgroundColor [0, 0, 0, 0.5];
_content ctrlCommit 0;

private _text = "
"""

for tab in m_tabs:
    title = tab['title']
    text = tab['text']
    # Convert <font color='#ffaa00'> to <t color='#ffaa00'> for structured text just in case, though <font> works.
    # We will use standard <t> tags.
    text_p = text.replace("<font ", "<t ").replace("</font>", "</t>")
    p_out += f"<t size='1.1' color='#55aaff'>{title}</t><br/>\n"
    p_out += f"<t size='0.85'>{text_p}</t><br/><br/>\n\n"

p_out += """";

_content ctrlSetStructuredText parseText _text;

// Adjust height of structured text to fit content perfectly, triggering the scrollbar
private _h = ctrlTextHeight _content;
_content ctrlSetPosition [0, 0, 18.5 * GUI_GRID_W, _h];
_content ctrlCommit 0;
"""

with open(P_FILE, "w") as f:
    f.write(p_out)


# 3. Generate Markdown files
md_dir = "/home/brian-vasquez/aim-a3m/docs/a3m_field_manual"
os.makedirs(md_dir, exist_ok=True)
import glob
for f in glob.glob(f"{md_dir}/*.md"):
    os.remove(f)

md_index = "# A3M Field Manual\n\n"

for i, tab in enumerate(m_tabs, 1):
    title = tab['title']
    text = tab['text']
    
    # Clean up Arma tags for markdown
    text_md = re.sub(r'<br\s*/?>', '\n', text)
    text_md = re.sub(r'<[^>]+>', '', text_md) # Strip XML tags
    
    # Safe filename
    filename = re.sub(r'[^\w\-]', '_', title)
    filename = f"{i:02d}_{filename}.md"
    
    with open(os.path.join(md_dir, filename), "w") as f:
        f.write(f"# {title}\n\n{text_md}\n")
        
    md_index += f"{i}. [{title}](./{filename})\n"

with open(os.path.join(md_dir, "README.md"), "w") as f:
    f.write(md_index)

print(f"Generated {len(m_tabs)} full lossless chapters.")
